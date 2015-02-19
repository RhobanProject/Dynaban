clear all; close all; clc;
% Récupération des données : sous un terminal : ls test*.m, puis CTrl Shift V , 
% puis coller sur éditeur , puis remplacer .m , par ;all_data{i_cell}=data;i_cell=i_cell+1;
test_18_02_2015_09h_52mn_28s_PosCte_30_degree;
new_data=struct();
new_data.t=1e-6*data.t_us;
new_data.values=[];
switch_trace_temp=1;
num_data=[1,2,11]; % position rad and current A, see new_data.name_data
switch_estim=1;
T_DEBUT_ESTIM=6; % tps minimum pour estimation en s
%-----------------------------------------------
% traitement du data sur 2 octets
%-----------------------------------------------
k_all=0;
cols=data.col;
names=fieldnames(cols);
nb_cols=size (names,1);
for k_col=1:nb_cols,
  name_col=names{k_col};
  num_col=getfield(cols,name_col);
  if ((num_col>=data.col_deb)&&(num_col+1<=data.col_fin)),
    ku_L=num_col-(data.col_deb-1);
    ku_H=ku_L+1;
    h=data.values(:,ku_H);
    l=data.values(:,ku_L);
    s=find(h>=128);
    h(s)=h(s)-256;
    data_i=h*256+ l;
    k_all=k_all+1;
    new_data.name_data{k_all}=name_col;
    new_data.values=[new_data.values,data_i];
  end 
  [new_data.nbech,new_data.nb_data]=size(new_data.values);
end
%-----------------------------------------------
% traitement du data sur 2 octets, avec saut en 1024
%-----------------------------------------------
cols=data.col1024;
names=fieldnames(cols);
nb_cols=size (names,1);
for k_col=1:nb_cols,
  name_col=names{k_col};
  num_col=getfield(cols,name_col);
  if ((num_col>=data.col_deb)&&(num_col+1<=data.col_fin)),
    ku_L=num_col-(data.col_deb-1);
    ku_H=ku_L+1;
    h=data.values(:,ku_H);
    l=data.values(:,ku_L);
    s=find(h>=128);
    h(s)=h(s)-256;
    data_i=h*256+ l;
    k=find(data_i<1024);
    data_i(k)=-data_i(k);
    k=find(data_i>=1024);
    data_i(k)=data_i(k)-1024;    
    k_all=k_all+1;
    new_data.name_data{k_all}=name_col;
    new_data.values=[new_data.values,data_i];
  end 
  [new_data.nbech,new_data.nb_data]=size(new_data.values);
end

%-----------------------------------------------
% traitement du data sur 1 octet
%-----------------------------------------------
cols=data.col8;
names=fieldnames(cols);
nb_cols=size (names,1);
for k_col=1:nb_cols,
  name_col=names{k_col};
  num_col=getfield(cols,name_col);
  if ((num_col>=data.col_deb)&&(num_col<=data.col_fin)),
    ku_L=num_col-(data.col_deb-1);
    data_i=data.values(:,ku_L);
    k_all=k_all+1;
    new_data.name_data{k_all}=name_col;
    new_data.values=[new_data.values,data_i];
  end 
end
%-----------------------------------------------
% taille du data
%-----------------------------------------------
  [new_data.nbech,new_data.nb_data]=size(new_data.values);
%-----------------------------------------------
% mise a l'echelle
%-----------------------------------------------
for i=1:new_data.nb_data,
  if( strcmp(new_data.name_data{i},"CURRENT_L")==1) ,
    new_data.values(:,i)=4.5e-3 * ( new_data.values(:,i) - 2048 );
    new_data.name_data{i}="CURRENT_A";
  end
  if( strcmp(new_data.name_data{i},"PRESENT_POSITION_L")==1) ,  
    new_data.values(:,i)=2*pi/4096 * ( new_data.values(:,i) );
    new_data.name_data{i}="PRESENT_POSITION_RAD";
  end
  if( strcmp(new_data.name_data{i},"GOAL_POSITION_L")==1) ,  
    new_data.values(:,i)=2*pi/4096 * ( new_data.values(:,i) );
    new_data.name_data{i}="GOAL_POSITION_RAD";
  end
  if( strcmp(new_data.name_data{i},"PRESENT_SPEED_L")==1) ,  
    new_data.values(:,i)= 2 *pi /60 * 117 /1024 * new_data.values(:,i) ;
    new_data.name_data{i}="PRESENT_SPEED_RADS";
  end
end
  
  
%-----------------------------------------------
% tracés temporels
%-----------------------------------------------
if (switch_trace_temp==1) , 
  for k=1:length(num_data),
    i=num_data(k);
    figure();clf();
    plot(new_data.t,new_data.values(:,i));hold on;grid on;
    title([new_data.name_data{i},": new_data.values(:,",num2str(i),")"]);
  end
end
 
%-----------------------------------------------
% comparaison de données
%-----------------------------------------------
if (switch_estim==1) , 
  k_estim=find(new_data.t>T_DEBUT_ESTIM); % only time > T_DEBUT_ESTIM
  nb_ech=length(k_estim);
  kY=11; % sortie = courant en Ampere
  kE=1; % entree = position en radians
  posRad=new_data.values(k_estim,1); % col 1 = position en radians 
  consigneRad=new_data.values(k_estim,2); % col 2 = consigne en rad
  entree=consigneRad-posRad;
  H=[entree,ones(nb_ech,1)];
  Y=new_data.values(k_estim,kY);
  X=pinv(H)*Y;
  Y_estim=H*X;
  E=Y-Y_estim;
  rms_E=sqrt((E'*E)/nb_ech);
  delta_Y=Y-mean(Y);
  sd_Y=sqrt((delta_Y'*delta_Y)/nb_ech);
   if (switch_trace_temp==1) , , 
     k=find(num_data==kY);
     figure(k);
     plot(new_data.t(k_estim),Y_estim,'r');
   end  
  disp(["modele : [sortie =",new_data.name_data{kY},"]= [",num2str(X(1)),"] . ", new_data.name_data{kE} ," + [",num2str(X(2)),"]"]);
  disp(["  [  erreur rms: ",num2str(rms_E),"] / [ ecart-type sortie : ",num2str(sd_Y),"] = ",num2str(rms_E/sd_Y)]);
    figure();clf();
    hold on;
    subplot(2,1,1);
    plot(entree,Y_estim,'r');hold on;
    plot(entree,Y,'b');
    title(["modele r: [sortie =",new_data.name_data{kY},"]= [",num2str(X(1)),"] . ", new_data.name_data{kE} ," + [",num2str(X(2)),"]"]);
    grid on; 

%----------------------------------------------------------------
% estimation resistance , en supposant echelle gain ci-dessous 
%--------------------------------------------------------------
  Umax_volt=12;
  Kp_volt_rad= (Umax_volt/3000) * data.Kp * (4096/(2*pi)); % coversion de Kp en volt / rad
  uVolt=Kp_volt_rad*(posRad-consigneRad); % tension en volt
  entree2=Y; % I en amperes
  nb_ech2=length(entree2);
  H2=[entree2,ones(nb_ech2,1)];
  Y2=uVolt; % tension en volts
  X2=pinv(H2)*Y2;
  Y2_estim=H2*X2;
  E2=Y2-Y2_estim;
  rms_E2=sqrt((E2'*E2)/nb_ech2);
  delta_Y2=Y2-mean(Y2);
  sd_Y2=sqrt((delta_Y2'*delta_Y2)/nb_ech2);
  disp(["modele : [I(A)= ]= [",num2str(X2(1)),"] . U Volt + [",num2str(X2(2)),"]"]);
  disp(["  [  erreur rms: ",num2str(rms_E2),"] / [ ecart-type sortie : ",num2str(sd_Y2),"] = ",num2str(rms_E2/sd_Y2)]);
  subplot(2,1,2);
  plot(entree2,Y2,'b');hold on;
  plot(entree2,Y2_estim,'r');
  title(["modele r: [sortie = U(volt)]= [",num2str(X2(1)),"] . I(A) + [",num2str(X2(2)),"]"]);
  grid on;  
end
 
 
 
 
 