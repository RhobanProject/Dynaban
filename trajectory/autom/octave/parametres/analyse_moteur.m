clear all;clear global;
close all;
clc;
mot=struct();
mot.r_induit=3; % aucune idee
mot.K_Nm_amp=1.6; % mesure manuellement
mot.K_Volt_rads=1.6; % deduit de K_Nm_amp
mot.f_Nm_rds =  0.17622;
mot.I_kgm2 =  0.0035244;
mot.Umax_volt=24;
mot.kp_u2700_posStep=32;
mot.kp_uVolt_rad= (mot.Umax_volt/3000) * mot.kp_u2700_posStep * (4096/(2*pi));
%--------------------------------------------------------
% fcts de transfert du moteur, generee depuis maxima
%---------------------------------------------------------
p=tf([1,0],1);
KcI=mot.K_Nm_amp;
R=mot.r_induit;
KEw=mot.K_Volt_rads;
f=mot.f_Nm_rds;
Inert=mot.I_kgm2;
mot.H_w_U = KcI/((Inert*p+f)*R+KEw*KcI);
mot.H_w_Cr = -R/((Inert*p+f)*R+KEw*KcI);
mot.H_E_U = KEw*KcI/((Inert*p+f)*R+KEw*KcI);
mot.H_E_Cr = -KEw*R/((Inert*p+f)*R+KEw*KcI);
mot.H_I_U = (Inert*p+f)/((Inert*p+f)*R+KEw*KcI);
mot.H_I_Cr = KEw/((Inert*p+f)*R+KEw*KcI);
mot.H_Cm_U = (Inert*KcI*p+f*KcI)/((Inert*p+f)*R+KEw*KcI);
mot.H_Cm_Cr = KEw*KcI/((Inert*p+f)*R+KEw*KcI);
mot.H_pos_U = mot.H_w_U/p;
mot.H_pos_Cr =mot.H_w_Cr/p;
mot.FTBO = mot.H_pos_U * mot.kp_uVolt_rad;

%--------------------------------------------------------
% bode transfert position rad/ U (volt)
%---------------------------------------------------------
figure();clf();
bode (mot.H_pos_U);
figure();clf();
bode (mot.FTBO);