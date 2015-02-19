clear all;
close all;
clc;
%-----------------------------------------------
% switches de configuration
%---------------------------------------------------
switch_draw_temp=0; %indique si tracés temporels
switch_draw_freq=0; %indique si tracés fréquentiels [abcisse = position en ?]
switch_affiche_result=0;
switch_trace_vitesse_courant=1;
N_FFT=8192; % taille des FFT ( zero padding)
NUM_FICHIER=1:11; % fichiers à traiter
tetabli_s=1; % temps attente régime établi
%--------------------------------------------------
% Parametres du moteur
max_torqueNm = 7.3;
torque_limitNm = 7.3;
% Initialisation de la structure de données
all_data=cell();i_cell=1;
% Récupération des données : sous un terminal : ls test*.m, puis CTrl Shift V , 
% puis coller sur éditeur , puis remplacer .m , par ;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_10h_08mn_49s_CoupleCte50mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_10h_13mn_37s_CoupleCte100mA;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_00mn_49s_VitesseCte50rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_08h_57mn_49s_VitesseCte100rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_03mn_14s_VitesseCte200rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_08h_56mn_11s_VitesseCte500rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_05mn_28s_VitesseCte1000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_06mn_33s_VitesseCte3000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_07mn_31s_VitesseCte5000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_07mn_59s_VitesseCte6000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_08mn_29s_VitesseCte7000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_08mn_56s_VitesseCtem7000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_09mn_23s_VitesseCtem6000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_09mn_50s_VitesseCtem5000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_10mn_17s_VitesseCtem4000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_10mn_45s_VitesseCtem3000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_11mn_14s_VitesseCtem2000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_11mn_40s_VitesseCtem1000rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_12mn_11s_VitesseCtem500rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
test_04_02_2015_09h_14mn_36s_VitesseCtem100rpmX100;all_data{i_cell}=data;i_cell=i_cell+1;
NUM_FICHIER=1:length(all_data); % fichiers à traiter
%NUM_FICHIER=14;




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
  % mesure pente et offset position Radians
  l=length(posRad_i);
  H_i=[ones(l,1),t_s_i];
  X_i=pinv(H_i)*posRad_i;
  posRadEst_i=H_i*X_i;
  posRadErr_i=posRad_i-posRadEst_i;
  result.meanSpeedEstRad_s=X_i(2); % pente estimée de la position en Rad
  result.meanSpeedEstRpm=result.meanSpeedEstRad_s*60/(2*pi);
  % suppression offset consigne
  result.mean_consigne=mean(consigne_i);
  %consigne_i=consigne_i-mean(consigne_i);
  % non suppression offset courant
  result.mean_I_A=mean(I_A_i);
  result.mean_loadNm=mean(loadNm_i);
  %I_A_i=I_A_i-mean(I_A_i);
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
    figure (1);
    clf ();
    subplot(2,1,1);
    plot ( t_s_i, posDeg_i ); hold on;
    xlabel('Time (s)'); 
    ylabel('posDeg_i');
    subplot(2,1,2);
    plot ( t_s_i, I_A_i ); 
    xlabel('Time (s)'); 
    ylabel('Current (mA)');

    figure (2);
    plot ( t_s_i, posRad_i ,'b',t_s_i,posRadEst_i,'r');
    plot ( posDeg_i, I_A_i);
    xlabel('Time (s)'); 
    title('current(A)=f(pos(°)');
    
  end %  if (switch_draw_temp==1) ,
% stockage resultats
  all_data{nf}.result =result;  
end %for kf=1:length(NUM_FICHIER),
if (switch_affiche_result==1) ,
  for kf=1:length(NUM_FICHIER),
    nf=NUM_FICHIER(kf);
    ri=all_data{nf}.result;
    disp('//---------------------------------------------------------------------'); 
    s=["// fichier :",num2str(nf), " frequence mesure = ", num2str(ri.freq_hz_from_fft) ," hz"];disp(s);
    disp('//---------------------------------------------------------------------'); 
    s=[" amplitude I_A     = ", num2str(ri.abs_fft_I_A) ];disp(s);
    s=[" amplitude loadNm  = ", num2str(ri.abs_fft_loadNm) ];disp(s);
    s=[" amplitude vitRadS = ", num2str(ri.abs_fft_vitRadS) ];disp(s);
    s=[" amplitude posRad  = ", num2str(ri.abs_fft_posRad) ];disp(s);
    s=[" amplitude consigne= ", num2str(ri.abs_fft_consigne) ];disp(s);
    s=[" transfert vitRadS/I_A : module = ", num2str(ri.absTfvitRadS_from_I_A) ," , argument =", num2str(ri.argTfvitRadS_from_I_A_deg)," deg"];disp(s);
    s=[" [ moyenne consigne =", num2str(ri.mean_consigne) ];disp(s);

    s=[" [ moyenne vitRadS =", num2str(ri.meanSpeedEstRad_s) ," ]/ [moyenne I_A =", num2str(ri.mean_I_A)," A]= ",num2str(ri.meanSpeedEstRad_s/ri.mean_I_A)];disp(s);
    s=[" [ moyenne vitRpm =", num2str(ri.meanSpeedEstRpm) ," ]/ [moyenne I_A =", num2str(ri.mean_I_A)," A]= ",num2str(ri.meanSpeedEstRpm/ri.mean_I_A)];disp(s);
    
    
    
    
  end %for kf=1:length(all_data),
end
if (switch_trace_vitesse_courant==1) ,
   figure();
   clf();
  mean_i_A=zeros(length(NUM_FICHIER),1);
  mean_loadNm=zeros(length(NUM_FICHIER),1);
  mean_speed_rpm=zeros(length(NUM_FICHIER),1);
  
  for kf=1:length(NUM_FICHIER),
    nf=NUM_FICHIER(kf);
    ri=all_data{nf}.result;
    mean_i_A(kf)=ri.mean_I_A;
    mean_loadNm(kf)=ri.mean_loadNm;    
    mean_speed_rpm(kf)=ri.meanSpeedEstRpm;
  end
 %-----------------------------------------------
 % modélisation par Mc
 %----------------------------------------------- 
  k=find((mean_speed_rpm>5)&(mean_speed_rpm<40));
  H=[mean_i_A(k),ones(length(k),1)];
  X=pinv(H)*mean_speed_rpm(k);
  gain_est_rpm_A=X(1);
  ofs_est_rpm=X(2);
  mean_speed_rpm_est=H*X;
  mean_i_est=mean_i_A(k);
  [s,i]=sort(mean_speed_rpm );
  plot(  mean_i_A(i),mean_speed_rpm(i));hold on;
  plot(  mean_i_A,mean_speed_rpm,'r+');
  plot(  mean_i_est,mean_speed_rpm_est,'gv');
  plot(  mean_i_est,mean_speed_rpm_est,'g--');
  title(["v =fct(I ),à vide : modèle en vert : v rpm =[",num2str(gain_est_rpm_A),"].I A + [",num2str(ofs_est_rpm),"]"]);
  xlabel("I en A");
  ylabel("vitesse en tours /mn");
  grid on;  

  end


