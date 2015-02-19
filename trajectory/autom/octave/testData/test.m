clear all; close all; clc;
% Récupération des données : sous un terminal : ls test*.m, puis CTrl Shift V , 
% puis coller sur éditeur , puis remplacer .m , par ;all_data{i_cell}=data;i_cell=i_cell+1;
test_13_02_2015_10h_57mn_41s_VitesseSinus3000mHz_m1000rpmX100_1000rpmX100;
new_data=struct();
new_data.t=1e-6*data.t_us;
new_data.namecol=cell;
new_data.values=[];
switch_trace_temp=1;
switch_compare=1;
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
  if( min(new_data.name_data{i}=="CURRENT_L")==1) ,
    new_data.values(:,i)=4.5e-3 * ( new_data.values(:,i) - 2048 );
    new_data.name_data{i}="CURRENT_A";
  end
  if( min(new_data.name_data{i}=="PRESENT_LOAD_L")==1) ,
    torque_limitNm
    new_data.values(:,i)=new_data.torque_limitNm * ( new_data.values(:,i) /1024 );
    new_data.name_data{i}="PRESENT_LOAD_NM";
  end
  if( min(new_data.name_data{i}=="PRESENT_POSITION_L")==1) ,
  
    new_data.values(:,i)=2*pi/4096 * ( new_data.values(:,i) /1024 );
    new_data.name_data{i}="PRESENT_POSITION_RAD";
  end
  

end
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
  
  
%-----------------------------------------------
% tracés temporels
%-----------------------------------------------
if (switch_trace_temp==1) , 
  for i=1:new_data.nb_data,
     figure();clf();
     plot(new_data.t,new_data.values(:,i));
     title([new_data.name_data{i},": new_data.values(:,",num2str(i),")"]);
  end
end
 
%-----------------------------------------------
% comparaison de données
%-----------------------------------------------
if (switch_compare==1) , 
  k1=6;
  k2=7;
  H=[new_data.values(:,k1),ones(new_data.nbech,1)];
  Y=new_data.values(:,k2);
  X=pinv(H)*Y;
  E=Y-H*X;
  rms_E=sqrt((E'*E)/new_data.nbech);
  delta_Y=Y-mean(Y);
  sd_Y=sqrt((delta_Y'*delta_Y)/new_data.nbech);
  disp(["modele : [sortie =",new_data.name_data{k2},"]= [",num2str(X(1)),"] . ", new_data.name_data{k1} ," + [",num2str(X(2)),"]"]);
  disp(["  [  erreur rms: ",num2str(rms_E),"] / [ ecart-type sortie : ",num2str(sd_Y),"] = ",num2str(rms_E/sd_Y)]);
end
 
 
 
 
 