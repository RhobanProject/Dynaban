//--------------------------------------------
//  entete standard
//--------------------------------------------  
  clear; // effacementdes variables et fonctions
  lines(0);funcprot(0); // affichage sans pause, pas de ptompt a la redefinition des fonctions
  rep=get_absolute_file_path("seance3_exemple_53.sce");chdir(rep); // on se place sous le repertoire contenant le fichier
  stacksize(10000000); // take 10MO of stacksize
// switchs de configuration
//-------------------------------------------------------------
// switch_z_1=%t pour forcer une programmation en q=z^-1
// switch_z_1=%f pour programmation avec opérateur q(z^-1)
//-------------------------------------------------------------
  switch_z_1=%t;
//-------------------------------------------------------------
// switch_same_scale_bi=%t pour que b0_N,b1_N soient a la meme echelle
// switch_same_scale_bi=%f autrement
//-------------------------------------------------------------
  switch_same_scale_bi=%t; 
//-------------------------------------------------------------
// NOMBRE DE BITS DE CODAGE
//-------------------------------------------------------------
  NB_BITS=8;
//-------------------------------------------------------------
// NOMBRE D'E BITS D'ECHANTILLONS POUR LE CALCUL DES NORMES
//-------------------------------------------------------------
  NBECH_NORM=10000; 
//-----------------------------------
// integration des differentes fonctions ecrites par l'enseignant
//-----------------------------------
   exec("functions.sce");
   exec("functions_scaling.sce");
   exec("functions_statespace.sce");
   exec("functions_allpass.sce");
   exec("functions_direct_forms.sce");
   exec("functions_gene_code.sce");
//-----------------------------------
// changements de variables divers
//-----------------------------------
  w=poly(0,'w');
  z=poly(0,'z');
  z_1=poly(0,'z_1');
  z_1_de_w=(1-w)/(1+w);
  w_de_z_1=(1-z_1)/(1+z_1);
  z_de_w=(1+w)/(1-w);
  w_de_z=(z-1)/(z+1);
  z_1_de_z=1/z;
  z_de_z_1=1/z_1;
//-----------------------------------
// 531 definition de F(w)
//-----------------------------------
  f0_sur_fe=0.001;
  f1_sur_fe=0.01;
  v0=tan(f0_sur_fe*%pi);
  v1=tan(f1_sur_fe*%pi);
  F_de_w=(1+w/v1)/(1+w/v0);
  f0_sur_fe=100/8000;
  v0=tan(f0_sur_fe*%pi);
  F_de_w=1/(1+w/v0);

//-----------------------------------
//532 calcul de vq,Lq,aq a partir de v0
//-----------------------------------
  vq_ideal=v0;
  aq=2*vq_ideal/(vq_ideal+1);
  Lq=-log2(aq);
  Lq1=floor(Lq); Lq2=ceil(Lq);
  aq1=2^(-Lq1);  aq2=2^(-Lq2);
  vq1=aq1/(2-aq1);  vq2=aq2/(2-aq2);
  Lq=[Lq1,Lq2];
  vq=[vq1,vq2];
  aq=[aq1,aq2];
  log_vq_sur_vp=abs(log2(vq/vq_ideal));
  [unused,i]=min(log_vq_sur_vp);
  vq=vq(i);
  Lq=Lq(i);
  aq=aq(i);
//-----------------------------------
// forcage des valeurs si programmation en z-1
//-----------------------------------
  if switch_z_1==%t then
    vq=1;lq=0;aq=1;
  end
// connaissant vq, on en deduit w(q) et q(w)
  q=poly(0,"q");
  w_de_q=(1-q)/(1+q/vq);
  q_de_w=(1-w)/(1+w/vq);
// connaissant  w(q) on en deduit F(q) =F(w(q))
  F_de_q=hornerij(F_de_w,w_de_q,"ld");  // F(q) =F(w(q))
  num_F_de_q=numer(F_de_q);
  den_F_de_q=denom(F_de_q);

  F_de_z_1=hornerij(F_de_w,w_de_z_1,"ld");  // F(z_1) =F(w(z_1))
//-----------------------------------
// quantification des coeffs de F(q)
//-----------------------------------
  if (switch_same_scale_bi==%t) then
   bi=coeff(num_F_de_q);[Lbi,bi_8,bi_q] = get_scaled_coeffs(bi,NB_BITS);
   b0=bi(1);Lb0=Lbi;b0_8=bi_8(1);b0_q=bi_q(1);
   b1=bi(2);Lb1=Lbi;b1_8=bi_8(2);b1_q=bi_q(2);
  else
    b0=coeff(num_F_de_q,0);[Lb0,b0_8,b0_q] = get_scaled_coeffs(b0,NB_BITS);
    b1=coeff(num_F_de_q,1);[Lb1,b1_8,b1_q] = get_scaled_coeffs(b1,NB_BITS);
  end
  a1=coeff(den_F_de_q,1);
  [La1,a1_8,a1_q] = get_scaled_coeffs(a1,NB_BITS);
  num_Fq_de_q=b0_q+b1_q*q;
  den_Fq_de_q=1+a1_q*q;
  Fq_de_q=num_Fq_de_q/den_Fq_de_q;
//-----------------------------------
// calcul des transformes en w correspondantes
//-----------------------------------
  num_F_de_w =hornerij(num_F_de_q ,q_de_w,"ld");
  num_Fq_de_w=hornerij(num_Fq_de_q,q_de_w,"ld");
  den_F_de_w =hornerij(den_F_de_q ,q_de_w,"ld");
  den_Fq_de_w=hornerij(den_Fq_de_q,q_de_w,"ld");
  Fq_de_w=hornerij(Fq_de_q,q_de_w,"ld");
//--------------------------------------------------------
// scaling ( forme df2)
//--------------------------------------------------------
  Hex_de_q=1/den_Fq_de_q;
  Hex_de_w=hornerij(Hex_de_q,q_de_w,"hd");
  Hex_de_z=hornerij(Hex_de_w,w_de_z,"hd");
  Hex_de_z_1=hornerij(Hex_de_z,z_de_z_1,"ld");
  norme1_Hex=norme_Fz(Hex_de_z,"cascade',1,NBECH_NORM)
  norme2_Hex=norme_Fz(Hex_de_z,"cascade',2,NBECH_NORM)
  normeHinf_Hex=norme_Fz(Hex_de_z,"cascade',%inf,NBECH_NORM)
  lambda_max=1/norme1_Hex;
  L=floor(log2(lambda_max))
  lambda=2^L;

//----------------------------------------------------------
// analyse du bruit de sortie
//----------------------------------------------------------
// normes de Fq(z))
  Fq_de_z=hornerij(Fq_de_w,w_de_z,"hd");
  norme1_Fq=norme_Fz(Fq_de_z,"cascade",1,NBECH_NORM);
  norme2_Fq=norme_Fz(Fq_de_z,"cascade",2,NBECH_NORM);
  normeHinf_Fq=norme_Fz(Fq_de_z,"cascade",%inf,NBECH_NORM);
// normes de -a1. Fq(z).Hq(z)
  if (vq~=1) then
    Hq_de_w=w/(w+vq);
    Hq_de_z=hornerij(Hq_de_w,w_de_z,"hd");
    Hq_de_z_1=hornerij(Hq_de_w,w_de_z_1,"ld");
  else
   Hq_de_w=0;
   Hq_de_z=0;
   Hq_de_z_1=0;
  end
  a1FHq_de_z=list();
  a1FHq_de_z(1)=Fq_de_z;
  a1FHq_de_z(2)=-a1* Hq_de_z;
  norme1_a1FHq=norme_Fz(a1FHq_de_z,"cascade",1,NBECH_NORM);
  norme2_a1FHq=norme_Fz(a1FHq_de_z,"cascade",2,NBECH_NORM);
  normeHinf_a1FHq=norme_Fz(a1FHq_de_z,"cascade",%inf,NBECH_NORM);
  max_module_bruit=1;
  max_s_due_au_bruits= max_module_bruit*(norme1_a1FHq+norme1_Fq) /lambda
//-------------------------------------------
// C'EST TERMINE, TRACES ET AFFICHAGES DIVERS
//-------------------------------------------
// calcul des reponses frequentielles
//-----------------------------------
  nb_points=1000;v0_aff=v0/10;v1_aff=10;
  v_aff=logspace(log10(v0_aff),log10(v1_aff),nb_points).'; // v_aff=vct colonne des pseudos pulsations
  w_aff=%i*v_aff;
//-----------------------------------
// F,Fq,F-Fq
//-----------------------------------
  rep_F =horner(F_de_w ,w_aff);
  rep_Fq=horner(Fq_de_w,w_aff);
  [db_F ,phi_F ]=get_module_arg(rep_F );
  [db_Fq,phi_Fq]=get_module_arg(rep_Fq);
  [db_delta_F,phi_delta_F]=get_module_arg(rep_F-rep_Fq);
//-----------------------------------
// NF,NFq,NF-NFq
//-----------------------------------
  rep_num_F =horner(num_F_de_w ,w_aff);
  rep_num_Fq=horner(num_Fq_de_w,w_aff);
  [db_num_F ,phi_num_F ]=get_module_arg(rep_num_F );
  [db_num_Fq,phi_num_Fq]=get_module_arg(rep_num_Fq);
  [db_delta_num_F,phi_delta_num_F]=get_module_arg(rep_num_F-rep_num_Fq);
// DF,DFq,DF-DFq
  rep_den_F =horner(den_F_de_w ,w_aff);
  rep_den_Fq=horner(den_Fq_de_w,w_aff);
  [db_den_F ,phi_den_F ]=get_module_arg(rep_den_F );
  [db_den_Fq,phi_den_Fq]=get_module_arg(rep_den_Fq);
  [db_delta_den_F,phi_delta_den_F]=get_module_arg(rep_den_F-rep_den_Fq);
//-----------------------------------
// trace des reponses frequentielles
//-----------------------------------
  nb_marks=7;
  i_marks=1+round(linspace(0,1,nb_marks)*(length(v_aff)-1));
  figure(0);clf("reset");
//-----------------------------------
// trace F,Fq,F-Fq
//-----------------------------------
  subplot(3,1,1);
  M_aff=[db_F,db_Fq,db_delta_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);
  legends(["F(jv)","Fq(jv)","[F-Fq](jv)"],[-2,-3,-4],"lr");
  xtitle("reponses frequentielles pour vq="+string(vq),"","gain en db");
//-----------------------------------
// trace NF,NFq,NF-NFq
//-----------------------------------
  subplot(3,1,2);
  M_aff=[db_num_F,db_num_Fq,db_delta_num_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);

  xtitle("","","gain en db");
  legends(["NF(jv)","NFq(jv)","[NF-FNq](jv)"],[-2,-3,-4],"lr");
// trace DF,DFq,DF-DFq
  subplot(3,1,3);
  M_aff=[db_den_F,db_den_Fq,db_delta_den_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);
  legends(["DF(jv)","DFq(jv)","[DF-FDq](jv)"],[-2,-3,-4],"lr");
  xtitle("","pseudo pulsation v","gain en db");




