clear all;close all;
% creation de la liste all_data de toutes les donnees de toutes le experiences
data=cell();
tmp=struct();
%------------------------------------------------------------------
% appel de get_data_1, qui recupere les donnees
% integration du data de la premiere experience aux donnees
%----------------------------------------------------------------
get_data_1;
tmp.pos_rad=position_degree*pi/180;
tmp.speed_rad_s=speed_rpm*(pi/180)/60;
tmp.load_Nm=0.01* load_Ncm;
tmp.timeS=timeUs*1e-6;
%Identification par moindre carre de la pente de la vitesse en regime transitoire
tmp.i = find ( timeUs > 250000 & timeUs <= 750000 );
%Identification par moindre carre de la vitesse en regime etabli, acceleration = 0
tmp.j = find ( timeUs > 900000 & timeUs <= 1400000 );
data{1}=tmp;
%------------------------------------------------------------------------------
% appel de get_data_2, qui recupere les donnees de la deuxieme experience
% integration du data de la premiere experience aux donnees
%----------------------------------------------------------------------------
get_data_2;
tmp.pos_rad=position_degree*pi/180;
tmp.speed_rad_s=speed_rpm*(pi/180)/60;
tmp.load_Nm=0.01* load_Ncm;
tmp.timeS=timeUs*1e-6;
%Identification par moindre carre de la pente de la vitesse en regime transitoire
tmp.i = find ( timeUs > 250000 & timeUs <= 750000 );
%Identification par moindre carre de la vitesse en regime etabli, acceleration = 0
tmp.j = find ( timeUs > 900000 & timeUs <= 1400000 );
data{2}=tmp;
%--------------------------------------------------------------------------------
% traitement des donnees de toutes les experiences
%------------------------------------------------------------------------------------

for id=1:length(data),

%on range data{i} dans di
  di=data{id};
%on recupere et on traite les donnees
  
  i=di.i;
  t= di.timeS ( i );
  s= di.speed_rad_s ( i );
  l= di.load_Nm ( i );
  p= di.pos_rad ( i );
  j=di.j;
  t2= di.timeS ( j );
  s2= di.speed_rad_s( j );
  l2= di.load_Nm( j );
  p2= di.pos_rad ( j );
%Cree un vecteur de 1 du bon nombre de ligne
  un = ones ( size ( t ) ( 1 ), 1 );
  un2 = ones ( size ( t2 ) ( 1 ), 1 );

%Concaténation parrallele de vecteur verticaux
  H = [ t, un ];
  H2 = [ t2, un2 ];

  ab_est = pinv ( H ) * s;
  a_est = ab_est ( 1, 1 );
  b_est = ab_est ( 2, 1 );
  s_est = H * ab_est;

  ab_est2 = pinv ( H2 ) * s2;
  a_est2 = ab_est2 ( 1, 1 );
  b_est2 = ab_est2 ( 2, 1 );
  s_est2 = H2 * ab_est2;
  figure (1);
  subplot ( 4, 1, 1 )
  plot ( timeUs, load_Ncm ); hold on;
  subplot ( 4, 1, 2 )
  plot ( timeUs, speed_rpm ); hold on;
  subplot ( 4, 1, 2 )
  plot ( t, s_est, "r" ); hold on;
  plot ( t2, s_est2, "g" )
  subplot ( 4, 1, 3 )
  plot ( timeUs, position_degree, "b" )
%Estimation des frottements visqueux
  Cm_Nm = -l2;
  W_rad_s = s2;
  zero2 = zeros ( size ( t2 ) ( 1 ), 1 ); %Cree un vecteur de 0 du bon nombre de ligne
  H3 = [ W_rad_s, zero2 ];
  F = pinv ( H3 ) * Cm_Nm;
  fv = F ( 1, 1 );
  di.fv=fv; % sauvegarde fv estime
%Estimation de l'acceleration en degree/s2 => il faudrait une acceleration en rad/s2 pour estimer l'inertie...
  acceleration_dps2 = a_est*1000000*360/60;
  acc_rad_s2=acceleration_dps2 *pi/180; % modif ygorra
%Estimation de l'inertie (Le bot )
  di.Cm_Nm1 = -l/100;
  W_rad_s1 = s*(2*pi)/60;
  J = (di.Cm_Nm1 - di.fv*W_rad_s1)/acc_rad_s2; % modif ygorra
  di.Jm = mean ( J );
%on stocke di modifie dans le data
  data{id}=di;
end



%-----------------------------------------------
% trace vitesse en fonction du couple (load)
% objectif : estimer le frottement sec 
%-----------------------------------------------
figure(2);clf;

plot(W_rad_s1,Cm_Nm1);
xlabel('vitesse en rpm');
ylabel('Cm en Ncm'); 
H = [ Cm_Nm1, ones(size ( Cm_Nm1 , 1 ),1)];
ab_est=pinv(H)*W_rad_s1;
W_rad_est=H*ab_est;
hold on;
plot(W_rad_est,Cm_Nm1,"r");
%frottement sec tq w =0 <=> a.FrSec+b =0 => FrSec=-b/a
a=ab_est(1);b=ab_est(2);
Frsec_Nm =-b/a;
W_FrSec_rad_s=[Frsec_Nm,1]* ab_est;
plot(W_FrSec_rad_s,Frsec_Nm,'or');



