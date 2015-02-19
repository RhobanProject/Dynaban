clear all;
close all;
clc;
%-----------------------------------------------
% switches de configuration
%---------------------------------------------------
switch_draw_temp=1; %indique si tracés temporels
switch_draw_freq=0; %indique si tracés temporels
switch_affiche_result=1;
switch_trace_bode=0;
ECHELLE_CONSIGNE=1/100;
N_FFT=8192; % taille des FFT ( zero padding)
tetabli_s=1; % temps attente régime établi
%--------------------------------------------------
% Parametres du moteur
max_torqueNm = 7.3;
torque_limitNm = 7.3;
% Initialisation de la structure de données
all_data=cell();i_cell=1;
test_06_02_2015_16h_12mn_30s_CoupleCte50mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_06_02_2015_16h_13mn_42s_CoupleCte100mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_06_02_2015_16h_14mn_27s_CoupleCte100mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_06_02_2015_16h_15mn_16s_CoupleCte100mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_06_02_2015_16h_16mn_12s_CoupleCte200mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_06_02_2015_16h_17mn_21s_CoupleCte200mA;all_data{i_cell}=data;i_cell=i_cell+1;

% Récupération des données



NUM_FICHIER=[1:length(all_data)]; % fichiers à traiter
NUM_FICHIER=[3,4,5,6]; % fichiers à traiter, Pb avec 1 et 2, je ne sais ps pourquoi


%all_data{i_cell}=data;i_cell=i_cell+1;



values=[];
for i_cell= 1:length(all_data),
%for i_cell=1:length(all_data),
  vi=all_data{i_cell}.values;
  [m,n] = size(vi);
% suppression des sauts de position  
  posInc = vi(:,data.col_position);
  p1=posInc(2:m);
  p0=posInc(1:(m-1));
  deltaPos=max(posInc)-min(posInc);
  i_mod=find(abs(p1-p0)>deltaPos/2);
  SCALE_POS_INC=4096;
  for k=1:length(i_mod),
    id=i_mod(k)+1;
    s=sign(p1(id)-p0(id));
    posInc(id:end) =posInc(id:end)+SCALE_POS_INC*s;
  end
  vi(:,data.col_position)=posInc;
% ajout du numero de fichier  
  numFile = ones(m,1)*i_cell;
  vi = [vi,numFile];
  values=[values;vi];
end

% Extraction et mise en forme des données
t_us = values(:,data.col_time);

consigne = values(:,data.col_consigne);
I_A = 4.5e-3 * ( values(:,data.col_current) - 2048 );

load_inc = values(:,data.col_load);
j = find(load_inc >= 1024);
loadNm = load_inc;
loadNm(j) = -(load_inc(j) - 1024);
loadNm = loadNm * torque_limitNm/1024;

posInc = values(:,data.col_position);
posDeg = posInc * 360/4096;
posRad = posDeg * pi/180;

speedInc = values(:,data.col_vitesse);
j = find(speedInc >= 1024);
speedRpm = speedInc;
speedRpm(j) = (speedInc(j) - 1024);
speedRpm = speedRpm * 117/1024;
speedRads = speedRpm * 2*pi/60;


% Sélection de(s) fichier(s) qui nous intéresse(nt) 
numFile = values(:,end);
for kf=1:length(NUM_FICHIER),
  result=struct();
  nf=NUM_FICHIER(kf);
  result.num_file=nf;
  if (nf==3)|(nf==4) ,
    result.CoupleMesureNm=0.4*0.170*9.81; % mesure manuelle à 100mA
  end
  if (nf==5)|(nf==6) ,
    result.CoupleMesureNm=0.4*0.340*9.81; % mesure manuelle à 200mA
  end
  i_f=find(numFile==nf);
  % Restriction des données à ce fichier
  consigne_i = consigne(i_f);
  t_us_i = t_us(i_f);
  I_A_i = I_A(i_f);
  loadNm_i = loadNm(i_f);
  posInc_i = posInc(i_f);
  posDeg_i = posDeg(i_f);
  posRad_i = posRad(i_f);
  speedRpm_i = speedRpm(i_f);
  speedRads_i = speedRads(i_f);

  % Sélection du régime établi
  i_etab = find(t_us_i > tetabli_s*1e6);
  consigne_i = consigne_i(i_etab);
  t_us_i = t_us_i(i_etab);
  t_s_i=t_us_i*1e-6;
  dt_us_i=t_us_i(2:end)-t_us_i(1:(end-1));
  dt_us_i=[0;dt_us_i];
  I_A_i = I_A_i(i_etab);
  loadNm_i = loadNm_i(i_etab);
  posInc_i = posInc_i(i_etab);
  posDeg_i = posDeg_i(i_etab);
  posRad_i = posRad_i(i_etab);
  speedRpm_i = speedRpm_i(i_etab);
  speedRads_i= speedRads_i(i_etab);
  % suppression pente et offset position Radians
  l=length(posRad_i);
  H_i=[ones(l,1),t_s_i];
  X_i=pinv(H_i)*posRad_i;
  posRadEst_i=H_i*X_i;
  posRadErr_i=posRad_i-posRadEst_i;
  result.meanSpeedEstRad_s=X_i(2); % pente estimée de la position en Rad
  result.meanSpeedEstRpm=result.meanSpeedEstRad_s*60/(2*pi);
  % suppression offset consigne
  result.mean_consigne=mean(consigne_i);
  consigne_i=consigne_i-mean(consigne_i);
  % moyenne charge en Nm
  result.mean_loadNm=mean(loadNm_i);
  % suppression offset courant
  result.mean_I_A=mean(I_A_i);
  I_A_i=I_A_i-mean(I_A_i);
  %interpolation donnees a Tech fixe, pour analyse par fft
  t_s_i=t_s_i-min(t_s_i);
  Tech_s_i=(max(t_s_i)-min(t_s_i))/(length(t_s_i)-1);
  t_interp_s_i=Tech_s_i*(0:(length(t_s_i)-1)).';
  posRadErr_interp_i=interp1(t_s_i,posRadErr_i,t_interp_s_i);
  I_A_interp_i=interp1(t_s_i,I_A_i,t_interp_s_i);
  loadNm_interp_i=interp1(t_s_i,loadNm_i,t_interp_s_i);
  consigne_interp_i=interp1(t_s_i,consigne_i,t_interp_s_i);
  result.Tech_s=Tech_s_i;  
  % calcul et tracé fft
  %amelioration resolution par zero padding, sélection f entre 0 et fe/2 
  fech_hz_i=1/Tech_s_i;
  bin_hz_i=fech_hz_i/N_FFT;
  result.fech_hz=fech_hz_i;
  f_hz_i=bin_hz_i*(0:(N_FFT-1)).';
  k=find(f_hz_i<fech_hz_i/2);
  f_hz_i=f_hz_i(k);
  %fft consigne  
  l=min([N_FFT,length(consigne_interp_i)]);
  consignePadded_i=zeros(N_FFT,1);
  consignePadded_i(1:l)=consigne_interp_i(1:l);
  fft_consigne_i= fft(consignePadded_i)*2/l;
  fft_consigne_i= fft_consigne_i(k);
  %fft posRad  
  l=min([N_FFT,length(posRadErr_interp_i)]);
  posPadded_i=zeros(N_FFT,1);
  posPadded_i(1:l)=posRadErr_interp_i(1:l);
  fftPos_i= fft(posPadded_i)*2/l; % normalisation en 2/l : max(fft)= approx amplitude
  fftPos_i=fftPos_i(k);
  %fft I_A  
  l=min([N_FFT,length(I_A_interp_i)]);
  I_APadded_i=zeros(N_FFT,1);
  I_APadded_i(1:l)=I_A_interp_i(1:l);
  fft_I_A_i= fft(I_APadded_i)*2/l;
  fft_I_A_i= fft_I_A_i(k);
  %fft loadNm  
  l=min([N_FFT,length(loadNm_interp_i)]);
  loadNmPadded_i=zeros(N_FFT,1);
  loadNmPadded_i(1:l)=loadNm_interp_i(1:l);
  fft_loadNm_i= fft(loadNmPadded_i)*2/l;
  fft_loadNm_i= fft_loadNm_i(k);
  % estimation gain,déphasage, et fréquence 
  [tmp,k_max_fft_i]=max(abs(fft_consigne_i));  
  fft_posRad_kmax_i=fftPos_i(k_max_fft_i);
  fft_I_A_kmax_i=fft_I_A_i(k_max_fft_i);
  fft_loadNm_kmax_i=fft_loadNm_i(k_max_fft_i);
  fft_consigne_kmax_i=fft_consigne_i(k_max_fft_i);
  freq_hz_kmax_i =f_hz_i(k_max_fft_i);
  % calcul manuel fft vitesse 
  jw=sqrt(-1)*2*pi*freq_hz_kmax_i;
  fft_vitRadS_kmax_i=jw*fft_posRad_kmax_i;

  result.freq_hz_from_fft=freq_hz_kmax_i;
  result.arg_fft_posRad_deg=arg(fft_posRad_kmax_i)*180/pi;
  result.abs_fft_posRad=abs(fft_posRad_kmax_i);
  result.arg_fft_I_A_deg=arg(fft_I_A_kmax_i)*180/pi;
  result.abs_fft_I_A=abs(fft_I_A_kmax_i);
  result.arg_fft_loadNm_deg=arg(fft_loadNm_kmax_i)*180/pi;
  result.abs_fft_loadNm=abs(fft_loadNm_kmax_i);
  result.arg_fft_vitRadS_deg=arg(fft_vitRadS_kmax_i)*180/pi;
  result.abs_fft_vitRadS=abs(fft_vitRadS_kmax_i);
  result.arg_fft_consigne_deg=arg(fft_consigne_kmax_i)*180/pi;
  result.abs_fft_consigne=abs(fft_consigne_kmax_i);

  % posRad/I_A
  result.absTfposRad_from_I_A =result.abs_fft_posRad/result.abs_fft_I_A;
  result.argTfposRad_from_I_A_deg =result.arg_fft_posRad_deg-result.arg_fft_I_A_deg;
  % loadNm/I_A
  result.absTfloadNm_from_I_A =result.abs_fft_loadNm/result.abs_fft_I_A;
  result.argTfloadNm_from_I_A_deg =result.arg_fft_loadNm_deg-result.arg_fft_I_A_deg;
  % visRad_s/I_A
  result.absTfvitRadS_from_I_A =result.abs_fft_vitRadS/result.abs_fft_I_A;
  result.argTfvitRadS_from_I_A_deg =result.arg_fft_vitRadS_deg-result.arg_fft_I_A_deg;
  if (result.argTfvitRadS_from_I_A_deg >=0),
    result.argTfvitRadS_from_I_A_deg=result.argTfvitRadS_from_I_A_deg-360;
  end
  if (result.argTfvitRadS_from_I_A_deg <=-360),
    result.argTfvitRadS_from_I_A_deg=result.argTfvitRadS_from_I_A_deg+360;
  end
  
  
  
  % tracés frequentiel
  if (switch_draw_freq==1) ,
    figure ();
    clf ();
    subplot(2,1,1);
    plot(f_hz_i,abs(fftPos_i),'b',freq_hz_kmax_i,abs(fft_posRad_kmax_i),'r+');
    s=["à f=",num2str(freq_hz_kmax_i),"hz, |pos|=",num2str(abs(fft_posRad_kmax_i)),"rad.Te ,arg( pos)=",num2str(180/pi*arg(fft_posRad_kmax_i)),"°"];
    title(s);
    xlabel('freq hz'); 
    ylabel('fft (pos)');
    subplot(2,1,2);
    plot(f_hz_i,abs(fft_I_A_i),'b',freq_hz_kmax_i,abs(fft_I_A_kmax_i),'r+');
    s=["à f=",num2str(freq_hz_kmax_i),"hz, |I|=",num2str(abs(fft_I_A_kmax_i))," A.Te ,arg( I)=",num2str(180/pi*arg(fft_I_A_kmax_i)),"°"];
    title(s);
    xlabel('freq hz'); 
    ylabel('fft (I_A)');
  end  %if (switch_draw_freq==1) ,
  % tracés temporels
  if (switch_draw_temp==1) ,
    figure ();
    clf ();
    plot ( t_s_i, consigne_i *ECHELLE_CONSIGNE); hold on;
    xlabel('Time (s)'); 
    ylabel(' (Rpm)');
    plot ( t_s_i, speedRpm_i , "r"); 
    title(["consigne.",num2str(ECHELLE_CONSIGNE)," bleu, vitesse mes rouge) "]);


    % Affichage des données

    figure ();
    clf ();
    plot ( t_s_i, consigne_i*ECHELLE_CONSIGNE,'b' ); hold on;
    xlabel('Time (s)'); 
    ylabel(' vit Rpm');
    title(["consigne.",num2str(ECHELLE_CONSIGNE)," bleu, vitesse mes rouge) "]);
    plot ( t_s_i, speedRpm_i , "r"); 

    figure ();
    clf ();
    plot ( t_s_i, I_A_i ); 
    xlabel('Time (s)'); 
    ylabel('Current (mA)');

    figure ();
    clf ();
    subplot(3,1,1);
    plot ( t_s_i, posRad_i ,'b',t_s_i,posRadEst_i,'r');
    xlabel('Time (s)'); 
    title('posRad (blue), posRad est (red)');
    subplot(3,1,2);
    plot ( t_s_i, posRadErr_i ,'b',t_interp_s_i,posRadErr_interp_i,'r');
    xlabel('Time (s)'); 
    title('ErrPos(blue), ErrPosInterp(red)');
    subplot(3,1,3);
    plot ( t_s_i, dt_us_i ,'b');
    xlabel('Time (s)'); 
    title('dt us');
  end %  if (switch_draw_temp==1) ,
% stockage resultats
  all_data{nf}.result =result;  
end %for kf=1:length(NUM_FICHIER),
if (switch_affiche_result==1) ,
  for kf=1:length(NUM_FICHIER),
    disp("MESURE MANUELLE : distance = 0.4 m");
    nf=NUM_FICHIER(kf);
    ri=all_data{nf}.result;
    disp('//---------------------------------------------------------------------'); 
    s=["// fichier :",num2str(nf), " frequence mesure = ", num2str(ri.freq_hz_from_fft) ," hz"];disp(s);
    disp('//---------------------------------------------------------------------'); 
    s=[" [ moyenne load Nm(Soft) =", num2str(ri.mean_loadNm) ," ]/ [moyenne I_A =", num2str(ri.mean_I_A)," A]= ",num2str(ri.mean_loadNm/ri.mean_I_A)];disp(s);

    s=[" [ Couple mesure Nm(manuel) =", num2str(ri.CoupleMesureNm) ," ]/ [moyenne I_A =", num2str(ri.mean_I_A)," A]= ",num2str(ri.CoupleMesureNm/ri.mean_I_A)];disp(s);
    s=[" [ moyenne vitRpm =", num2str(ri.meanSpeedEstRpm) ," ]/ [moyenne I_A =", num2str(ri.mean_I_A)," A]= ",num2str(ri.meanSpeedEstRpm/ri.mean_I_A)];disp(s);
    
    
    
  end %for kf=1:length(all_data),
end
if (switch_trace_bode==1) ,
  tmp=struct();
  tmp.freq_hz=zeros(length(NUM_FICHIER),1);
  tmp.amp_I_A=zeros(length(NUM_FICHIER),1);
  tmp.amp_consigne=zeros(length(NUM_FICHIER),1);
  tmp.amp_posRad=zeros(length(NUM_FICHIER),1);
  tmp.amp_vitRadS=zeros(length(NUM_FICHIER),1);
  tmp.ampTfvitRadS_from_I_A=zeros(length(NUM_FICHIER),1);
  tmp.arg_I_A_deg=zeros(length(NUM_FICHIER),1);
  tmp.arg_consigne_deg=zeros(length(NUM_FICHIER),1);
  tmp.arg_posRad_deg=zeros(length(NUM_FICHIER),1);
  tmp.arg_vitRadS_deg=zeros(length(NUM_FICHIER),1);
  tmp.argTfvitRadS_from_I_A_deg=zeros(length(NUM_FICHIER),1);
  for kf=1:length(NUM_FICHIER),
    nf=NUM_FICHIER(kf);
    ri=all_data{nf}.result;
    tmp.freq_hz(kf)=ri.freq_hz_from_fft;
    tmp.amp_I_A(kf)=  ri.abs_fft_I_A;
    tmp.amp_consigne(kf)=  ri.abs_fft_consigne;
    tmp.amp_posRad(kf)=  ri.abs_fft_posRad;
    tmp.amp_vitRadS(kf)=ri.abs_fft_vitRadS;
    tmp.ampTfvitRadS_from_I_A(kf)=ri.absTfvitRadS_from_I_A;
    tmp.arg_I_A_deg(kf)=  ri.arg_fft_I_A_deg;
    tmp.arg_consigne_deg(kf)=  ri.arg_fft_consigne_deg;
    tmp.arg_posRad_deg(kf)=  ri.arg_fft_posRad_deg;
    tmp.arg_vitRadS_deg(kf)=ri.arg_fft_vitRadS_deg;
    tmp.argTfvitRadS_from_I_A_deg(kf)=ri.argTfvitRadS_from_I_A_deg;      
  end %for kf=1:length(all_data),
  [f,i]=sort(  tmp.freq_hz);
  tmp.freq_hz=tmp.freq_hz(i);
  tmp.amp_I_A=tmp.amp_I_A(i);
  tmp.amp_consigne=tmp.amp_consigne(i);
  tmp.amp_posRad=tmp.amp_posRad(i);
  tmp.amp_vitRadS=tmp.amp_vitRadS(i);
  tmp.ampTfvitRadS_from_I_A=tmp.ampTfvitRadS_from_I_A(i);
  tmp.arg_I_A_deg=tmp.arg_I_A_deg(i);
  tmp.arg_consigne_deg=tmp.arg_consigne_deg(i);
  tmp.arg_posRad_deg=tmp.arg_posRad_deg(i);
  tmp.arg_vitRadS_deg=tmp.arg_vitRadS_deg(i);
  tmp.argTfvitRadS_from_I_A_deg=tmp.argTfvitRadS_from_I_A_deg(i);
%----------------------------------------------------
% estimation  retard de phase : -T .(2pi .f ) +ofs
%--------------------------------------------------- 
  l=length(tmp.freq_hz);
  H=[360*tmp.freq_hz,ones(l,1)];
  Y=tmp.argTfvitRadS_from_I_A_deg;
  X=pinv(H)*Y;
  tmp.retard_s=X(1);

  result_bode=tmp;
  figure();clf();
  subplot(2,1,1);
  semilogx(2*pi*tmp.freq_hz,20*log10(tmp.ampTfvitRadS_from_I_A),'bo');hold on;
  semilogx(2*pi*tmp.freq_hz,20*log10(tmp.ampTfvitRadS_from_I_A),'b');
  xlabel('freq en hz');
  ylabel('gain (rad/s)/A, en db ');
  title('bode de vitesse / courant ');
  subplot(2,1,2);
  semilogx(2*pi*tmp.freq_hz,tmp.argTfvitRadS_from_I_A_deg,'bo');hold on;
  semilogx(2*pi*tmp.freq_hz,argTfvitRadS_from_I_A_deg,'b');
  xlabel('pulsation en rd/s');
  ylabel('argument en degres');
 
 
end

