clear all;clear global;
close all;
clc;
dd_28=struct();
dd_64=struct();
%Servo motor speed constant
 dd_28.kw_rads_volt=100.7;
 dd_64.kw_rads_volt=74.9;
%Servo motor torque constant
 dd_28.Ki_Nm_A=9.9e-3;
 dd_64.Ki_Nm_A=13.4e-3;
% Armature inertia
 dd_28.Im_kgm2=86.4/1e9;
 dd_64.Im_kgm2=217.0/1e9;
%Armature inductance
 dd_28.Lm_mH=0.2e-3;
 dd_64.Lm_mH=0.2e-3;
%Armature resistance
 dd_28.rrotor_ohm=8.3;
 dd_64.rrotor_ohm=6.3;
%Gearbox inertia
 dd_28.gearbox_inertia_kgm2=79.6e-6;
 dd_64.gearbox_inertia_kgm2=154.9e-6;
%Gearbox ratio
 dd_28.gearbox_ratio=192.6;
 dd_64.gearbox_ratio=199.6;
%Gearbox backlash
 dd_28.gearbox_backslash_rad=5.0e-3;
 dd_64.gearbox_backslash_rad=5.0e-3;
%Sensor resolution
 dd_28.resolution_rad=2*pi*2^(-12);
 dd_64.resolution_rad=2*pi*2^(-12);
%Sensor noise variance
 dd_28.noise_variance_rad2=0.3e-6;
 dd_64.noise_variance_rad2=0.3e-6;
%Static friction constant
 dd_28.static_friction_Nm=78.1e-3;
 dd_64.static_friction_Nm=186.8e-3;
%Kinetic friction constant
 dd_28.kinetic_friction_Nm=13.0e-3;
 dd_64.kinetic_friction_Nm=31.1e-3;
%Viscous friction constant
 dd_28.viscous_friction_Nm_s=4.1e-3;
 dd_64.viscous_friction_Nm_s=9.9e-3;
%%-------------------------------------------------------
%% coeffs moteur en USI
%%-------------------------------------------------------
  dd_28.ke_volt_rads=1/dd_28.kw_rads_volt;
  dd_64.ke_volt_rads=1/dd_64.kw_rads_volt;
%%-------------------------------------------------------
%% coeffs en sortie de reducteur
%%-------------------------------------------------------
  dd_28.ke_red_volt_rads=dd_28.ke_volt_rads*dd_28.gearbox_ratio;
  dd_64.ke_red_volt_rads=dd_64.ke_volt_rads*dd_64.gearbox_ratio;
  dd_28.I_red_kgm2=dd_28.Im_kgm2/dd_28.gearbox_ratio^2+ dd_28.gearbox_inertia_kgm2;
  dd_64.I_red_kgm2=dd_64.Im_kgm2/dd_64.gearbox_ratio^2 + dd_64.gearbox_inertia_kgm2;
  dd_28.Ki_red_Nm_A= dd_28.Ki_Nm_A*dd_28.gearbox_ratio;
  dd_64.Ki_red_Nm_A= dd_64.Ki_Nm_A*dd_64.gearbox_ratio;
  
  



