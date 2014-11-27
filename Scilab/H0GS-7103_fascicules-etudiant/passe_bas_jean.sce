//clear;lines(0);chdir("/home/ygorra/ygorra_windows/tp/leea/eea631_sytemes_embarques/");exec("passe_bas_jean.sce");
//--------------------------------------------
//  entete standard
//--------------------------------------------  
  clear; // effacementdes variables et fonctions
  lines(0);funcprot(0); // affichage sans pause, pas de ptompt a la redefinition des fonctions
  rep=get_absolute_file_path("passe_bas_jean.sce");chdir(rep); // on se place sous le repertoire contenant le fichier 'iir.sce'
  stacksize(10000000); // take 10MO of stacksize
// switchs de configuration
//-------------------------------------------------------------
// switch_ns=%t pour employer le noise shaping
// switch_ns=%f pour pour ne pas employer le noise shaping
//-------------------------------------------------------------
  switch_ns=%f;
//-------------------------------------------------------------
// switch_same_scale_bi=%t pour que b0_N,b1_N soient a la meme echelle
// switch_same_scale_bi=%f autrement
//-------------------------------------------------------------
  switch_same_scale_bi=%f; 
//-------------------------------------------------------------
// NOMBRE DE BITS DE CODAGE
//-------------------------------------------------------------
  NB_BITS=8;
//-------------------------------------------------------------
// NOMBRE D'ECHANTILLONS POUR LE CALCUL DES NORMES
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
// 1- changements de variables divers de z en w ou en z^-1
//-----------------------------------
  w=poly(0,"w");          // polynome w
  z=poly(0,"z");          // polynome z
  q=poly(0,"q");          // polynome q=z^-1=1/z ( operateur retard q)
  w_de_z  =(z-1)/(z+1);   // w    =f( z  )
  q_de_z=1/z;             // q =f( z)
  z_de_w  =horner11_inv(w_de_z  ,"w");    // z=f( w  ), en inversant w=f(z) avec horner11_inv
  z_de_w=normalize(z_de_w,"ld"); // normalisation / coeff plus bas degre denominateur
  z_de_q=horner11_inv(q_de_z,"q");  // z=f(q), en inversant q=f(z) avec horner11_inv
  q_de_w=hornerij(q_de_z,z_de_w,"ld");// q=f(w),=q(z(w)) avec hornerij
  w_de_q=hornerij(w_de_z,z_de_q,"ld");// w=f(q),=w(z(q)) avec hornerij
//---------------------------------------------------
// 2- frequence et periode d'echantillonnage
//---------------------------------------------------
  fe=8000;   // frequence d'echantillonnage en hertz
  te=1/fe; // periode d'echantillonnage en secondes
//-----------------------------------
// 3- definition de F(w) ( correcteur avance de phase)
//-----------------------------------
  fu=250; 
  wu_reelle=2*%pi*fu;               // pulsation wu reelle en rad/s
  vu=tan(wu_reelle*te/2); // pseudo-pulsation vu associee a wu_reelle
  c0=1;                     // gain statique c0
  F_de_w=c0*(1)/(1+w/vu); // fonction de transfert en w du regulateur
// connaissant  w(q) on en deduit F(q) =F(w(q))
  F_de_q=hornerij(F_de_w,w_de_q,"ld");  // F(q) =F(w(q)), normalisation lower den
  num_F_de_q=numer(F_de_q); // numerateur de la fct de transfert en q
  den_F_de_q=denom(F_de_q); // denominateur de la fct de transfert en q

//-------------------------------------------------------------------------
// 4- quantification des coeffs de F(q) memes notations que pour la seance 1
//-------------------------------------------------------------------------
// coefficients b0,b1 du numerateur
  if (switch_same_scale_bi==%t) then
  // tous les coeffs bi a la meme echelle
   bi=coeff(num_F_de_q);[Lbi,bi_N,bi_q] = get_scaled_coeffs(bi,NB_BITS);
   b0=bi(1);Lb0=Lbi;b0_N=bi_N(1);b0_q=bi_q(1);
   b1=bi(2);Lb1=Lbi;b1_N=bi_N(2);b1_q=bi_q(2);
  else
  // chaque coeff bi a sa propre echelle
    b0=coeff(num_F_de_q,0);[Lb0,b0_N,b0_q] = get_scaled_coeffs(b0,NB_BITS);
    b1=coeff(num_F_de_q,1);[Lb1,b1_N,b1_q] = get_scaled_coeffs(b1,NB_BITS);
  end
// coefficient a1 du denominateur
  a1=coeff(den_F_de_q,1);
  [La1,a1_N,a1_q] = get_scaled_coeffs(a1,NB_BITS);
  num_F_qtf_de_q=b0_q+b1_q*q;
  den_F_qtf_de_q=1+a1_q*q;
// fonction de transfert quantifiee en fonction de q
  F_qtf_de_q=num_F_qtf_de_q/den_F_qtf_de_q
//-----------------------------------
// 5- calcul des transformes en w correspondantes
//-----------------------------------
  num_F_de_w =hornerij(num_F_de_q ,q_de_w);
  num_F_qtf_de_w=hornerij(num_F_qtf_de_q,q_de_w);
  den_F_de_w =hornerij(den_F_de_q ,q_de_w);
  den_F_qtf_de_w=hornerij(den_F_qtf_de_q,q_de_w);
  F_qtf_de_w=hornerij(F_qtf_de_q,q_de_w,"hd");
//-----------------------------------
// 6- calcul des transformes en z correspondantes
//-----------------------------------
  num_F_de_z =hornerij(num_F_de_q ,q_de_z);
  num_F_qtf_de_z=hornerij(num_F_qtf_de_q,q_de_z);
  den_F_de_z =hornerij(den_F_de_q ,q_de_z);
  den_F_qtf_de_z=hornerij(den_F_qtf_de_q,q_de_z);
  F_qtf_de_z=hornerij(F_qtf_de_q,q_de_z,"hd");
//--------------------------------------------------------
// 7- scaling,
// sur la base du schema standard de la forme df2t
// en 3.1 du travail preparatoire
//-------------------------------------------------------------------
// determination de H_e_x, sur la base du schema d'analyse standard
// de la forme df2t
//---------------------------------------------------------------------
// fct de transfert en q entree-> variable interne
  H_e_x_de_q=num_F_qtf_de_q/den_F_qtf_de_q;  // a modifier si forme df2
  H_e_x_de_w=hornerij(H_e_x_de_q,q_de_w,"hd"); // H(w)=H(q(w))
  H_e_x_de_z=hornerij(H_e_x_de_w,w_de_z,"hd"); // H(z)=H(q(z))
  H_e_x_de_q=normalize(H_e_x_de_q,"ld"); // normalise lower denom coeff
// calcul des normes 1,2 et H infini de H_e_x
  norme1_H_e_x=norme_Fz(H_e_x_de_z,"cascade",1,NBECH_NORM);
  norme2_H_e_x=norme_Fz(H_e_x_de_z,"cascade",2,NBECH_NORM);
  normeHinf_H_e_x=norme_Fz(H_e_x_de_z,"cascade",%inf,NBECH_NORM);
// determination du facteur d'echelle lambda=2^L, scaling en norme 1
  lambda_max=1/norme1_H_e_x;
  L=floor(log2(lambda_max));
  lambda=2^L;
  // lambda = a vous de voir ;//decommenter pour imposer une valeur de lambda
  L=round(log2(lambda));// mise a jour de L sur la valeur imposee de lambda
  disp("facteur d echelle lambda="+string(lambda)+"=2^"+string(L));

//----------------------------------------------------------------
// 8- determination des caracteristiques de la variable interne x
// pour la valeur finalement retenue de lambda
//----------------------------------------------------------------
// 8.1-caracteristiques de l'entree
  max_e=2^(NB_BITS-1);
  max_val_eff_e=max_e; // valeur efficace maximale de e
  variance_e=(max_e^2)/12; // variance de e si uniforme
  moyenne_e=0;                     // moyenne E( e ) si uniforme
  power_e=moyenne_e^2+variance_e;  //puissance = variance + moyenne^2
  ecart_type_e=sqrt(variance_e);   // ecart-type=sqrt(variance)
  val_eff_e=sqrt(power_e);         // valeur efficace = sqrt( puissance )
// 8.2- caracteristiques de la variable interne x
  max_x_de_e=max_e * (lambda*norme1_H_e_x);
  variance_x_de_e=variance_e * (lambda*norme2_H_e_x)^2;
  ecart_type_x_de_e=ecart_type_e * (lambda*norme2_H_e_x);
  max_power_x_de_e=power_e * (lambda * normeHinf_H_e_x)^2;
  max_val_eff_x_de_e_unif=val_eff_e * (lambda *normeHinf_H_e_x);
  max_val_eff_x_de_e=max_val_eff_e * (lambda *normeHinf_H_e_x);
  disp("module maximal de la variable interne x="+string(max_x_de_e));
  disp("val. efficace max de x ="+string(max_val_eff_x_de_e));
  disp("val. efficace max de x si entree unif.="+string(max_val_eff_x_de_e_unif));
  disp("ecart-type de x si e blanche et unif.="+string(ecart_type_x_de_e));

//----------------------------------------------------------
// 9- analyse du bruit de sortie
// sur la base du schema standard de la forme df2t
// en 3.1 du travail preparatoire
//--------------------------------------------------------
// 9.1-fonction de transfert H_bx_s entre le bruit bx et la sortie
  if (switch_ns==%t) then
  // expression de H_bx_s pour lambda=1, avec noise shaping
  //  H_bx_s_de_q=; // a completer pour forme df2 avec noise shaping

  else
  // expression de H_bx_s pour lambda=1, sans noise shaping
    H_bx_s_de_q=(1 /den_F_qtf_de_q ) * q;// a modifier si forme df2 (pas de noise shaping)
  end
  H_bx_s_de_w=hornerij(H_bx_s_de_q,q_de_w,"hd");
  H_bx_s_de_z=hornerij(H_bx_s_de_q,q_de_z,"hd");
// calcul des normes de H_bx_s
  norme1_H_bx_s=norme_Fz(H_bx_s_de_z,"cascade",1,NBECH_NORM);
  norme2_H_bx_s=norme_Fz(H_bx_s_de_z,"cascade",2,NBECH_NORM);
  normeHinf_H_bx_s=norme_Fz(H_bx_s_de_z,"cascade",%inf,NBECH_NORM);
//-----------------------------------------------------------------------------
// 9.2- caracteristiques du bruit bx ( dependent de la methode de quantification)
//----------------------------------------------------------------------------
  max_bx=1;
  max_val_eff_bx=max_bx;
  variance_bx=1/12; // variance de bx si uniforme
  moyenne_bx=0.5; // moyenne E( bx ) si uniforme
  power_bx=moyenne_bx^2+variance_bx; //puissance = variance + moyenne^2
  ecart_type_bx=sqrt(variance_bx); // ecart-type=sqrt(variance)
  val_eff_bx_unif=sqrt(power_bx);  // valeur efficace = sqrt( puissance )
//-----------------------------------------------------------------------------
// 9.3- analyse des caracteristiques du bruit de sortie engendre par le bruit bx
//----------------------------------------------------------------------------
  max_s_de_bx=max_bx * (norme1_H_bx_s / lambda );
  variance_s_de_bx=variance_bx * (norme2_H_bx_s/ lambda )^2;
  ecart_type_s_de_bx=ecart_type_bx * (norme2_H_bx_s/ lambda );
  max_power_s_de_bx=power_bx * (normeHinf_H_bx_s / lambda )^2;
  max_val_eff_s_de_bx_unif=val_eff_bx_unif * ( normeHinf_H_bx_s / lambda );
  max_val_eff_s_de_bx=max_val_eff_bx * ( normeHinf_H_bx_s / lambda );

  disp("module maximal de s due a bx="+string(max_s_de_bx));
  disp("val. efficace max de s due a bx ="+string(max_val_eff_s_de_bx));
  disp("val. efficace max de s due a bx unif.="+string(max_val_eff_s_de_bx_unif));
  disp("ecart-type de s due a bx blanc et unif.="+string(ecart_type_s_de_bx));
//----------------------------------------------
// C'EST TERMINE , ON PASSE AUX AFFICHAGES DIVERS
//----------------------------------------------
// calcul des reponses frequentielles
//-----------------------------------
  nb_points=1000;v0_aff=vu/10;v1_aff=10;
  v_aff=logspace(log10(v0_aff),log10(v1_aff),nb_points).'; // v_aff=vct colonne des pseudos pulsations
  w_aff=%i*v_aff;
//-----------------------------------
// F,F_qtf,F-F_qtf
//-----------------------------------
  rep_F =horner(F_de_w ,w_aff);
  rep_F_qtf=horner(F_qtf_de_w,w_aff);
  [db_F ,phi_F ]=get_module_arg(rep_F );
  [db_F_qtf,phi_F_qtf]=get_module_arg(rep_F_qtf);
  [db_delta_F,phi_delta_F]=get_module_arg(rep_F-rep_F_qtf);
//-----------------------------------
// NF,NF_qtf,NF-NF_qtf
//-----------------------------------
  rep_num_F =horner(num_F_de_w ,w_aff);
  rep_num_F_qtf=horner(num_F_qtf_de_w,w_aff);
  [db_num_F ,phi_num_F ]=get_module_arg(rep_num_F );
  [db_num_F_qtf,phi_num_F_qtf]=get_module_arg(rep_num_F_qtf);
  [db_delta_num_F,phi_delta_num_F]=get_module_arg(rep_num_F-rep_num_F_qtf);
// DF,DF_qtf,DF-DF_qtf
  rep_den_F =horner(den_F_de_w ,w_aff);
  rep_den_F_qtf=horner(den_F_qtf_de_w,w_aff);
  [db_den_F ,phi_den_F ]=get_module_arg(rep_den_F );
  [db_den_F_qtf,phi_den_F_qtf]=get_module_arg(rep_den_F_qtf);
  [db_delta_den_F,phi_delta_den_F]=get_module_arg(rep_den_F-rep_den_F_qtf);
// H_bx_s 
  rep_H_bx_s =horner(H_bx_s_de_w ,w_aff);
  [db_H_bx_s ,phi_H_bx_s ]=get_module_arg(rep_H_bx_s );
// lambda*H_e_x 
  rep_H_e_x =horner(H_e_x_de_w ,w_aff);
  [db_H_e_x ,phi_H_e_x ]=get_module_arg(rep_H_e_x );

//-----------------------------------
// trace des reponses frequentielles
//-----------------------------------
  nb_marks=7;
  i_marks=1+round(linspace(0,1,nb_marks)*(length(v_aff)-1));
  figure(0);clf("reset");
//-----------------------------------
// trace F,F_qtf,F-F_qtf
//-----------------------------------
  subplot(3,1,1);
  M_aff=[db_F,db_F_qtf,db_delta_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);
  legends(["F(jv)","F_qtf(jv)","[F-F_qtf](jv)"],[-2,-3,-4],"lr");
  xtitle("reponses frequentielles ","","gain en db");
//-----------------------------------
// trace NF,NF_qtf,NF-NF_qtf
//-----------------------------------
  subplot(3,1,2);
  M_aff=[db_num_F,db_num_F_qtf,db_delta_num_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);
  xtitle("","","gain en db");
  legends(["NF(jv)","NF_qtf(jv)","[NF-NF_qtf](jv)"],[-2,-3,-4],"lr");
// trace DF,DF_qtf,DF-DF_qtf
  subplot(3,1,3);
  M_aff=[db_den_F,db_den_F_qtf,db_delta_den_F];
  plot2d("ln",v_aff,M_aff,[1,2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3,-4]);
  legends(["DF(jv)","DF_qtf(jv)","[DF-DF_qtf](jv)"],[-2,-3,-4],"lr");
  xtitle("","pseudo pulsation v","gain en db");
//----------------------------------------------
// trace du gain de H_e_x .lambda
//----------------------------------------------
  figure(1);clf("reset");
  subplot(2,1,1);
  M_aff=[db_H_e_x,db_H_bx_s];
  plot2d("ln",v_aff,M_aff,[2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3]);
  xtitle("","","gain en db");
  legends(["H_e_x pour lambda=1","H_bx_s pour lambda=1"],[-2,-3],"lr");
//----------------------------------------------
// trace du gain de H_bx_s
//----------------------------------------------
  subplot(2,1,2);
  M_aff=[db_H_e_x+20*log10(lambda),db_H_bx_s-20*log10(lambda)];
  plot2d("ln",v_aff,M_aff,[2,3]);
  plot2d("ln",v_aff(i_marks,:),M_aff(i_marks,:),[-2,-3]);
  xtitle("","","gain en db");
  legends(["H_e_x pour lambda="+string(lambda),"H_bx_s pour lambda="+string(lambda)],[-2,-3],"lr");







