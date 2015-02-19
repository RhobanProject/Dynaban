% effacement variables, fenetres, console
  clear all;
  close all;
  clc;
% configuration programme et parametres moteur
  switch_least_squares = 1;
  switch_echelon = 0;
  max_torqueNm = 7.3;
  torque_limitNm = 7.3;
  files=[4:7,10:13]; % numeros des fichiers à traiter, 2 à 13 <=> rampes de position
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
      pos_end  =posDeg(max(kf));
      pos_start=posDeg(min(kf));
      seuil_0=pos_start+0.6*(pos_end-pos_start);
      seuil_1=pos_start+0.95*(pos_end-pos_start);
      if (seuil_1>seuil_0),
         kf=find((indice_file==nf)&(posDeg>seuil_0)&(posDeg<seuil_1));
      else 
         kf=find((indice_file==nf)&(posDeg>seuil_1)&(posDeg<seuil_0));
      end
      sign_vitesse=sign(posDeg(max(kf))-posDeg(min(kf)));% signe=sign( position finale -position initiale)
      if (sign_vitesse >0) ,
        H=[H;[speedRpm(kf),ones(length(kf),1),zeros(length(kf),1)]];
      else
        H=[H;[speedRpm(kf),zeros(length(kf),1),ones(length(kf),1)]];
      end  
      kf_est=[kf_est;kf];
      ind_file_est=[ind_file_est;ones(length(kf),1)*nf];
    end  
    %----------------------------------------------------------------------------------- 
    % Identification ( I_mA = X(1). V_rpm [+ X(2) si v_rpm>0] [ +X(3) (si v_rpm<0)] )
    %-----------------------------------------------------------------------------------
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
    % Identification ( load_Nm = X(1). V_rpm [+ X(2) si v_rpm>0] [ +X(3) (si v_rpm<0)] )
    %-----------------------------------------------------------------------------------
    Y=loadNm(kf_est);
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
    loadNm_est=Y_est;
    X2=X;
    sd_X2=sd_X;
  %----------------------------------------------------------------------------------- 
  % Identification ( load_Nm = X(1). I_ma + X(2)  )
  %-----------------------------------------------------------------------------------
    Y=loadNm(kf_est);
    H=[I_mA(kf_est),ones(length(Y),1)];
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
    loadNm_est2=Y_est;
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
    if (switch_least_squares==1),
      plot ( t_us(kfe), posDeg(kfe),col_est );
    end
    xlabel('Time (Us)'); 
    ylabel('Position (degree)');
    subplot(2,1,2);plot ( t_us(kf), speedRpm(kf),col ); hold on;
    xlabel('Time (Us)'); 
    ylabel('Speed (Rpm)');
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
      plot ( t_us(kfe), loadNm(kfe),col_est );
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
    disp( [" ------------ mesures courant -vitesse en régime établi ---------- "]);
    disp( [" F visqueux estimé = ",num2str(X1(1))," mA/Rpm, ecart-type: " , num2str(sd_X1(1))," ma/rPm"]);
    disp( [" Fsec v>0 estimé      = ",num2str(X1(2))," mA    , ecart-type: " , num2str(sd_X1(2))," ma    "]);
    disp( [" Fsec v<0 estimé      = ",num2str(X1(3))," mA    , ecart-type: " , num2str(sd_X1(3))," ma    "]);
    disp( [" ------------ mesures load Nm -vitesse en régime établi ---------- "]);
    disp( [" F visqueux estimé = ",num2str(X2(1))," Nm/Rpm, ecart-type: " , num2str(sd_X2(1))," Nm/rPm"]);
    disp( [" Fsec v>0 estimé      = ",num2str(X2(2))," Nm    , ecart-type: " , num2str(sd_X2(2))," Nm    "]);
    disp( [" Fsec v<0 estimé      = ",num2str(X2(3))," Nm    , ecart-type: " , num2str(sd_X2(3))," Nm    "]);
    disp( [" ------------ mesures courant -loadNm en régime établi ---------- "]);
    disp( [" Ki      = ",num2str(1000*X3(1))," Nm/A, ecart-type: " , num2str(sd_X3(1)*1000)," Nm/A"]);
    disp( [" Offset  = ",num2str(X3(2))     ," Nm  , ecart-type: " , num2str(sd_X3(2))     ," Nm    "]);
  end


