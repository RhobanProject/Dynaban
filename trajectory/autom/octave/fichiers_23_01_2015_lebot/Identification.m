clear all;
close all;
clc;

% Parametres du moteur
switch_least_squares = 1;
switch_echelon = 0;
max_torqueNm = 7.3;
torque_limitNm = 7.3;

% Initialisation de la structure de données
all_data=cell();i_cell=1;

% Récupération des données
Experience1k15h12;
all_data{i_cell}=data;i_cell=i_cell+1;
%Experience1Rpm;
%all_data{i_cell}=data;i_cell=i_cell+1;
%Experience2Rpm;
%all_data{i_cell}=data;i_cell=i_cell+1;
Experience4Rpm;
all_data{i_cell}=data;i_cell=i_cell+1;
Experience6Rpm;
all_data{i_cell}=data;i_cell=i_cell+1;
Experience8Rpm;
all_data{i_cell}=data;i_cell=i_cell+1;
Experience10Rpm;
all_data{i_cell}=data;i_cell=i_cell+1;
%ExperienceNeg1Rpm;
%all_data{i_cell}=data;i_cell=i_cell+1;
%ExperienceNeg2Rpm;
%all_data{i_cell}=data;i_cell=i_cell+1;
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
  [m,n] = size(vi);
  numFile = ones(m,1)*i_cell;
  vi = [vi,numFile];
  values=[values;vi];
end

% Exctraction et mise en forme des données
t_us = values(:,data.col_time);

consigneDeg = values(:,data.col_consigne);
consigneRad = consigneDeg * pi/180;
I_mA = 4.5 * ( values(:,data.col_current) - 2048 );

load_inc = values(:,data.col_load);
j = find(load_inc >= 1024);
loadNm = load_inc;
loadNm(j) = -(load_inc(j) - 1024);
loadNm = loadNm * torque_limitNm/1024;

% Dans cette experience, les données sont déjà en degrees
if ( switch_echelon == 1 ),
posDeg = values(:,data.col_position); 
end
if ( switch_echelon == 0 ),
posInc = values(:,data.col_position);
posDeg = posInc * 360/4096;
end
posRad = posDeg * pi/180;

speedInc = values(:,data.col_vitesse);
j = find(speedInc >= 1024);
speedRpm = speedInc;
speedRpm(j) = - (speedInc(j) - 1024);
speedRpm = speedRpm * 117/1024;
speedRads = speedRpm * 2*pi/60;


% Sélection de(s) fichier(s) qui nous intéresse(nt) 
numFile = values(:,end);
i_f = find(numFile == 6 );
% Restriction des données à ce fichier
consigneDeg = consigneDeg(i_f);
consigneRad = consigneRad(i_f);
t_us = t_us(i_f);
I_mA = I_mA(i_f);
loadNm = loadNm(i_f);
posDeg = posDeg(i_f);
posRad = posRad(i_f);
speedRpm = speedRpm(i_f);
speedRads = speedRads(i_f);

% Identification des parametres
if ( switch_least_squares == 1 ),

if ( switch_echelon == 1 ),
% On s'intéresse au régime établi
consignePrev = consigneDeg;
consigneNext = ones(length(consignePrev),1);
for i=1:(length(consigneDeg) - 1),
  consigneNext(i) = consignePrev(i+1);
end
% On cherche une variation de la consigne
i_pic = find (consignePrev != consigneNext);
% On récupère les indices précédent cette variation 
% correspondant au régime établi
i_etab = i_pic;
for i=0:length(all_data),
  % regime etabli
  i_etab = [i_etab;i_pic-i];
  % Restriction des données à ce régime
  consigneDeg = consigneDeg(i_etab);
  consigneRad = consigneRad(i_etab);
  t_us = t_us(i_etab);
  I_mA = I_mA(i_etab);
  loadNm = loadNm(i_etab);
  posDeg = posDeg(i_etab);
  posRad = posRad(i_etab);
  speedRpm = speedRpm(i_etab);
  speedRads = speedRads(i_etab);
end

% Définition de la matrice de mesure
sinPos = sind(consigneDeg);
cosPos = cosd(consigneDeg);
Mesures = [sinPos,cosPos,ones(length(posDeg),1),speedRads];

% Identification ( Cm = A.sin(o) + B.sin(o) + C + D.w )
X = pinv(Mesures) * loadNm;
Aest = X(1,1);
Best = X(2,1);
Cest = X(3,1);
Dest = X(4,1);

% Mesure de l'erreur pour validation des résultats
loadNmest = Mesures * X;

erreur_est = loadNm - loadNmest;
mean_erreur_est = mean ( erreur_est );
pow_err_est = mean ( erreur_est .* erreur_est );
var_err_est = pow_err_est - ( mean_erreur_est .* mean_erreur_est );

cov_X = var_err_est * pinv ( Mesures' * Mesures );

end

% Affichage des données
if ( switch_echelon == 1 ),
  figure (1)
  clf ()
  plot ( t_us, consigneDeg , "." ); hold on;
  xlabel('Time (Us)'); 
  ylabel('Consigne (degree)');
  plot ( t_us, posDeg , "r."); 

  figure (2)
  clf ()
  plot ( t_us, I_mA , "."); 
  xlabel('Time (Us)'); 
  ylabel('Current (mA)');

  figure (3)
  clf ()
  plot ( t_us, loadNm , "." ); hold on;
  xlabel('Time (Us)'); 
  ylabel('Load (Nm)');
  plot ( t_us, loadNmest , "r." ); 

  figure (4)
  clf ()
  plot ( t_us, erreur_est , "."); 
  xlabel('Time (Us)'); 
  ylabel('Erreur (Nm)');
end

if ( switch_echelon == 0 ),
  figure (1)
  clf ()
  plot ( t_us, posDeg );
  xlabel('Time (Us)'); 
  ylabel('Position (degree)');

  figure (2)
  clf ()
  plot ( t_us, speedRpm ); 
  xlabel('Time (Us)'); 
  ylabel('Speed (Rpm)');

  figure (3)
  clf ()
  plot ( t_us, loadNm ); hold on;
  xlabel('Time (Us)'); 
  ylabel('Load (Nm)');
  plot ( t_us, loadNmest , "g" );

  figure (4)
  clf ()
  plot ( t_us, erreur_est , "g"); 
  xlabel('Time (Us)'); 
  ylabel('Erreur (Nm)');
end


