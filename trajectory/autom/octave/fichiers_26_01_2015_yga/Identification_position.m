% effacement variables, fenetres, console
  clear all;
  close all;
  clc;
% configuration programme et parametres moteur
  switch_least_squares = 1;
  switch_echelon = 1;
  max_torqueNm = 7.3;
  torque_limitNm = 7.3;
  files=[1]; % numeros des fichiers à traiter, 1 <=> echelon de position
% Initialisation de la structure de données
  all_data=cell();i_cell=1;

% Récupération des données
  Experience1k15h12;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience1Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience2Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience4Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience6Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience8Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  Experience10Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg1Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg2Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg4Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg6Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg8Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  ExperienceNeg10Rpm;
  all_data{i_cell}=data;i_cell=i_cell+1;
  values=[];
  for i_cell=1:length(all_data),
    vi=all_data{i_cell}.values;
    if (i_cell==1),
    % Dans l'experience 1, la position est déjà en degrees
    % on la convertit en inc pour homogénéité de traitement avec les autres fichiers
      pos_Deg = vi(:,data.col_position);
      pos_Inc = pos_Deg / (360/4096);
      vi(:,data.col_position)=pos_Inc;
    end
    [m,n] = size(vi);
    numFile = ones(m,1)*i_cell;
    vi = [vi,numFile];
    values=[values;vi];
  end

% Extraction et conversion des données dans différentes unités
  t_us = values(:,data.col_time);
  consigneDeg = values(:,data.col_consigne);
  consigneRad = consigneDeg * pi/180;
  I_mA = 4.5 * ( values(:,data.col_current) - 2048 );

  load_inc = values(:,data.col_load);
  j = find(load_inc >= 1024);
  loadNm = load_inc;
  loadNm(j) = -(load_inc(j) - 1024);
  loadNm = loadNm * torque_limitNm/1024;

  posInc = values(:,data.col_position);
  posDeg = posInc * 360/4096;
  posRad = posDeg * pi/180;
  posTours=posDeg /360;
  speedInc = values(:,data.col_vitesse);
  j = find(speedInc >= 1024);
  speedRpm = speedInc;
  speedRpm(j) = - (speedInc(j) - 1024);
  speedRpm = speedRpm * 117/1024;
  speedRads = speedRpm * 2*pi/60;

% Sélection de(s) fichier(s) qui nous intéresse(nt)
  numFile = values(:,end);
  i_f=[];indice_file=[];
  for i=1:length(files),
    fi=files(i);
    kf=find(numFile == fi );
    i_f = [i_f;kf];
    indice_file=[indice_file;i*ones(length(kf),1)];
  end
% Restriction des données à ces fichiers
  consigneDeg = consigneDeg(i_f);
  consigneRad = consigneRad(i_f);
  t_us = t_us(i_f);
  I_mA = I_mA(i_f);
  loadNm = loadNm(i_f);
  posDeg = posDeg(i_f);
  posRad = posRad(i_f);
  speedRpm = speedRpm(i_f);
  speedRads = speedRads(i_f);
% Identification des parametres en vitesse
  if ( switch_least_squares == 1 ),
    kf_est=[];ind_file_est=[];H=[];
    for nf=1:length(files),
      kf=find(indice_file==nf);
      kf0=kf(1:length(kf)-1);
      kf1=kf(2:length(kf));
      deltaCons=consigneDeg(kf1)-consigneDeg(kf0);
      i=find(deltaCons>0);  
      t_end_us=t_us(kf0(i));
      t_end_us=[t_end_us;max(t_us(kf))];
      for k=1:length(t_end_us),
        ki=find((indice_file==nf)&(t_us>t_end_us(k) - 300000) &(t_us<t_end_us(k)) );
        kf_est=[kf_est;ki];
        ind_file_est=[ind_file_est;ones(length(ki),1)*nf];
      end
    end  
    
    %----------------------------------------------------------------------------------- 
    % Identification : I_mA = X(1) *cos(Pos)+ X(2)*sin(Pos) + X(3) :
    %-----------------------------------------------------------------------------------
    posRdEst=pi/180*posDeg(kf_est);
    H=[cos(posRdEst),sin(posRdEst),ones(length(posRdEst),1)];
    Y=I_mA(kf_est);
    % Mesure de l'erreur pour validation des résultats
    X = pinv(H) * Y;
    Y_est = H * X;
    erreur_est = Y - Y_est;
    mean_erreur_est = mean ( erreur_est );
    pow_err_est = mean ( erreur_est .* erreur_est );
    var_err_est = pow_err_est - ( mean_erreur_est .* mean_erreur_est );
    cov_X = var_err_est * pinv ( H' * H ); 
    var_X=diag(cov_X);
    sd_X=sqrt(var_X);
    I_mA_est=Y_est;
    X1=X;
    sd_X1=sd_X;
    %----------------------------------------------------------------------------------- 
    % Identification : load_Nm = X(1) *cos(Pos)+ X(2)*sin(Pos) + X(3) :
    %-----------------------------------------------------------------------------------
    Y=loadNm(kf_est);
    % Ls + Mesure de l'erreur pour validation des résultats
    X = pinv(H) * Y;
    Y_est = H * X;
    erreur_est = Y - Y_est;
    mean_erreur_est = mean ( erreur_est );
    pow_err_est = mean ( erreur_est .* erreur_est );
    var_err_est = pow_err_est - ( mean_erreur_est .* mean_erreur_est );
    cov_X = var_err_est * pinv ( H' * H ); 
    var_X=diag(cov_X);
    sd_X=sqrt(var_X);
    loadNm_est=Y_est;
    X2=X;
    sd_X2=sd_X;
  %----------------------------------------------------------------------------------- 
  % Identification  : load_Nm = X(1). I_ma + X(2)  
  %-----------------------------------------------------------------------------------
    Y=loadNm(kf_est);
    H=[I_mA(kf_est),ones(length(posRdEst),1)];
    % Ls + Mesure de l'erreur pour validation des résultats
    X = pinv(H) * Y;
    Y_est = H * X;
    erreur_est = Y - Y_est;
    mean_erreur_est = mean ( erreur_est );
    pow_err_est = mean ( erreur_est .* erreur_est );
    var_err_est = pow_err_est - ( mean_erreur_est .* mean_erreur_est );
    cov_X = var_err_est * pinv ( H' * H ); 
    var_X=diag(cov_X);
    sd_X=sqrt(var_X);
    loadNm_est=Y_est;
    X3=X;
    sd_X3=sd_X;
    
  end


% Affichage des données

  figure (1);
  clf ();
  figure (2);
  clf ();
  figure (3);
  clf ();
  for nf=1:length(files),
  % def des couleurs selon les fichiers
    kf=find(indice_file==nf);
    if (switch_least_squares==1),
      i_est=find(ind_file_est==nf);
      kfe=kf_est(i_est);        
    end
    if (mod(nf,4) ==0),
      col='c';col_est='co';
    end
    if (mod(nf,4) ==1),
      col='b';col_est='bo';
    end
    if (mod(nf,4) ==2),
      col='r';col_est='ro';
    end
    if (mod(nf,4) ==3),
      col='g';col_est='go';
    end
  %tracé  position et vitesse
    figure (1);
    subplot(2,1,1);plot ( t_us(kf), posDeg(kf),col );hold on;
    plot ( t_us(kf), consigneDeg(kf),'r' );hold on;
    if (switch_least_squares==1),
      plot ( t_us(kfe), posDeg(kfe),col_est );
    end
    xlabel('Time (Us)'); 
    ylabel('Position (degree)');
    subplot(2,1,2);plot ( t_us(kf), I_mA(kf),col); hold on;
    xlabel('Time (Us)'); 
    ylabel('courant mA');
  %tracé vitesse et courant
    figure (2);
    subplot(2,1,1);plot ( t_us(kf), speedRpm(kf),col); hold on;
    xlabel('Time (Us)'); 
    ylabel('Speed (Rpm)');
    subplot(2,1,2);plot ( t_us(kf), I_mA(kf),col); hold on;
    xlabel('Time (Us)'); 
    ylabel('courant mA');
    if (switch_least_squares==1),
      plot ( t_us(kfe), I_mA_est(i_est),col_est );
      ylabel('courant mA , mesuré, et estimé (ronds)');
    end
  %tracé courant et loadNm courant
    figure (3);
    subplot(2,1,1);plot ( t_us(kf), loadNm(kf),col); hold on;
    xlabel('Time (Us)'); 
    ylabel('load(Nm)');
    if (switch_least_squares==1),
      plot ( t_us(kfe), loadNm_est(i_est),col_est );
      ylabel('load(Nm) et estimée');
    end
    subplot(2,1,2);plot ( t_us(kf), I_mA(kf),col); hold on;
    xlabel('Time (Us)'); 
    ylabel('courant mA');
    if (switch_least_squares==1),
      plot ( t_us(kfe), I_mA_est(i_est),col_est );
      ylabel('courant mA , mesuré, et estimé (ronds)');
    end
  end % for nf=1:length(files)
  if (switch_least_squares==1),
    Acos_mA=X1(1);
    Asin_mA=X1(2);
    ofs_mA=X1(3);
    thetaI_rad=atan2(Acos_mA,Asin_mA);
    thetaI_deg=180/pi*thetaI_rad;
    Amp_mA=abs(Asin_mA+sqrt(-1)*Acos_mA);
    disp( [" ------------ mesures courant -position en régime établi ---------- "]);
    disp( [" Ai estimée = ",num2str(Acos_mA)," mA, ecart-type: " , num2str(sd_X1(1))," ma"]);
    disp( [" Bi      = ",num2str(Asin_mA)," mA    , ecart-type: " , num2str(sd_X1(2))," ma    "]);
    disp( [" ofs I estimé      = ",num2str(ofs_mA)," mA    , ecart-type: " , num2str(sd_X1(3))," ma    "]);
    disp( ["en posant im= Acos = Amp.sin(theta), et Re=Asin = Amp.cos(theta), on obtient donc :"]);
    disp( ["Amp = ",num2str(Amp_mA)," Nm"]);
    disp( ["theta = ",num2str(thetaI_deg)," degrés"]);

    disp( [" ------------ mesures loadNm-position en régime établi ---------- "]);
    Acos_Nm=X2(1);
    Asin_Nm=X2(2);
    ofs_Nm=X2(3);
    thetaL_rad=atan2(Acos_Nm,Asin_Nm);
    thetaL_deg=180/pi*thetaL_rad;
    Amp_Nm=abs(Asin_Nm+sqrt(-1)*Acos_Nm);
    disp( [" Im= Acos estimée = ",num2str(Acos_Nm)," Nm, ecart-type: " , num2str(sd_X2(1))," Nm"]);
    disp( [" Re=Asin estimée = ",num2str(Asin_Nm)," Nm, ecart-type: " , num2str(sd_X2(2))," Nm    "]);
    disp( [" ofs  estimé      = ",num2str(ofs_Nm)," Nm    , ecart-type: " , num2str(sd_X2(3))," Nm    "]);
    disp( ["en posant im= Acos = Amp.sin(theta), et Re=Asin = Amp.cos(theta), on obtient donc :"]);
    disp( ["Amp = ",num2str(Amp_Nm)," Nm"]);
    disp( ["theta = ",num2str(thetaL_deg)," degrés"]);
     
  end


