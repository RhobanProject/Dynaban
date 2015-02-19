clear all;clear global;
close all;
clc;
c_constant=struct();

%------------------------------------------------------------------
%1-Couple constant à une distance de 50 cm, mesure avec balance 
%------------------------------------------------------------------
c_constant.G=9.81; % 1KgF = 9.81 N 
c_constant.distance=0.5; % force mesuree à 0.5 m de centre de rotation
c_constant.mes_Kgf  =[0.12;0.16;0.2  ;0.270;0.370;0.44;0.6 ;0.77 ]-0.07; %mesures en Kgf - mesure a vide
c_constant.refI_mA =[50  ;100 ;200  ;500  ;750  ;1000;1500;2000 ];%ref courant en mA
c_constant.meanI_mA=[43  ;91.5;189.5;485  ;731  ;981 ;1478;1980 ];%moyenne mesure courant en mA [ 2 secondes ]
c_constant.sdI_mA  =[11  ;17.3;35   ;53   ;69   ;83  ;115 ;134 ];%ecart type estimé sur mesure courant en mA [ 2 secondes ]
c_constant.mesNm=c_constant.mes_Kgf*c_constant.distance*c_constant.G; % couple en Nm
c_constant.nb_data=length(c_constant.meanI_mA);
%------------------------------------------------
% estimation par moindres carrés: C= A.I + B
%------------------------------------------------
H=[c_constant.meanI_mA,ones(c_constant.nb_data,1)];
X=pinv(H)*c_constant.mesNm;
C_est=H*X;
c_constant.K_Nm_mA=X(1);
c_constant.K_Nm_A=1000*c_constant.K_Nm_mA;

c_constant.C0_Nm=X(2);
figure();clf();
plot(c_constant.meanI_mA,c_constant.mesNm,'b');hold on;
plot(c_constant.meanI_mA,c_constant.mesNm,'b+');
plot(c_constant.meanI_mA,C_est,'r');hold on;
plot(c_constant.meanI_mA,C_est,'ro');
xlabel ('I mA ');
ylabel ('C Nm ');
title(["C (Nm) = f(I mA) mes blue, est. red : C Nm = [",num2str(c_constant.K_Nm_A)," ]. I A + [",num2str(c_constant.C0_Nm),"]"]);
grid on;

%------------------------------------------------------------------
%2-résultats analyse harmonique w/I = A/(tau.p+1 ) = K /(I.p+f)   
%------------------------------------------------------------------
  harmo=struct();
  harmo.A_rds_Amp=9.068;
  harmo.A_rpm_Amp=harmo.A_rds_Amp* 60/2/pi;
 
  harmo.tau_s=0.02;
  harmo.K_Nm_Amp=c_constant.K_Nm_A;
  harmo.f_Nm_rds=harmo.K_Nm_Amp/harmo.A_rds_Amp; % K/f=A <=> f=K/A
  harmo.I_kgm2 =  harmo.tau_s * harmo.f_Nm_rds ;  % I/f =tau <=> I =tau *f 
  