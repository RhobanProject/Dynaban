//--------------------------------------------
//  entete standard
//--------------------------------------------  
  clear; // effacementdes variables et fonctions
  lines(0);funcprot(0); // affichage sans pause, pas de ptompt a la redefinition des fonctions
  rep=get_absolute_file_path("fir.sce");chdir(rep); // on se place sous le repertoire contenant le fichier 'fir.sce'
  stacksize(10000000); // take 10MO of stacksize
// chargement des fonctions ecrites par le prof pour vous simplifier la vie
  exec("functions.sce");
  exec("functions_scaling.sce");
  exec("functions_statespace.sce");
  exec("functions_allpass.sce");
  exec("functions_direct_forms.sce");
  exec("functions_gene_code.sce");
//-----------------------------------
// description du filtre
//-------------------------------------
  fe=1000;    // frequence d'echantillonnage en Hz
  te=1/fe;     // periode d'echantillonnage en secondes
  fc_low=100;  // frequence de coupure basse  en Hz
  fc_hig=fc_low*1.1;  // frequence de coupure haute  en Hz, inutilisee ici
  NG=32;    // nombre de coeffs du filtre;
  NB_BITS=8;       // nombre de bits de codage
//---------------------------------------------------------
// utilisations fonction wfir de scilab
// pour calculer les coeffs gn du filtre de fct de transfert
// G(z) =somme gn.z^-n ,
// et de reponse frequentielle Gf(f) = G(z), en z=exp(i.2.pi.f/fe)
//-------------------------------------------------------
  freq_cut=[fc_low/fe,fc_hig/fe];
  type_window="hm";//'re','tr','hm','hn','kr','ch'
  unused_pars=[0,0];
  type_filtre="lp"; //"lp => lowpass","bp" =>bandpass,"hp"=>higpass;"sb"=>stop band
  [gn,Gf,fr]=wfir("lp",NG,freq_cut,type_window,unused_pars);
  gn=gn.'; // on transpose gn pour en fabriquer un vecteur colonne;
//-----------------------------------------------------------------------
//0- calcul de la somme des modules de gn dans la variable sum_modules_gn
//-----------------------------------------------------------------------
  sum_modules_gn=sum(abs(gn));
//-----------------------------------------------------------------------
//1- DETERMINATION DE LAMBDA_SIGNAL=2^L_SIGNAL
//completer les lignes ci-dessous
// permettant de determiner le facteur d'echelle de signal
// LAMBDA_SIGNAL = 2^L_SIGNAL,
// et le decalage L_SIGNAL associe,
// a partir de sum_modules_gn et de NB_BITS
//-----------------------------------------------------------------------
  LAMBDA_SIGNAL=1; // facteur d'echelle de signal par defaut
// MAX_ENTREE=; // a calculer en fonction de NB_BITS
// MAX_V=;      // a calculer en fonction de NB_BITS
// LAMBDA_SIGNAL=;// a calculer en fonction de sum_modules_gn,MAX_ENTREE,MAX_SORTIE
  L_SIGNAL=floor(log2(LAMBDA_SIGNAL));  // determination de L_SIGNAL
  LAMBDA_SIGNAL=2^L_SIGNAL;
//--------------------------------------------------------
// 2- QUANTIFICATION DES COEFFS sur NB_BITS ,
//---------------------------------------------------------
//--------------------------------------------------------------
// 2.1- quantification de chaque coeff avec son propre facteur d echelle
// meme methode et meme notation que dans le travail preparatoire,
//  voir eventuellement fonction get_scaled_coeffs,
//  dans le fichier functions_scaling.sce
//--------------------------------------------------------
  gn_N=zeros(NG,1) ; // coeffs entiers initialises a zero NG lignes,1 col
  gn_q=zeros(NG,1) ; // coeffs quantifies initialises a zero NG lignes,1 col
  Lg=zeros(NG,1) ; // decal a droite initialises a zero NG lignes,1 col
  for i=1:NG,  // pour i allant de 1 a NG
    gn_i=gn(i);
    [Lg_i,gn_N_i,gn_q_i]=get_scaled_coeffs(gn(i),NB_BITS); // voir functions_scaling.sce
    gn_N(i)=gn_N_i;
    gn_q(i)=gn_q_i;
    Lg(i)=Lg_i;
  end
//--------------------------------------------------------------------
// 2.2- decommenter eventuellement la ligne suivante
// pour quantifier tous les coeffs a la meme echelle 2^Lg
// avec Lg entier le plus grand possible
//------------------------------------------------------------------------
//  [Lg,gn_N,gn_q]=get_scaled_coeffs(gn,NB_BITS);Lg=Lg*ones(gn);
//-----------------------------------------------------------------------
// 2.3- decommenter eventuellement les 4 lignes suivantes
// pour quantifier tous les coeffs
// a la meme echelle Lg, imposee par vous
//---------------------------------------------------------------
//  Lg=11;// a modifier eventuellement
//  gn_N=round(2^Lg * gn);
//  gn_q=2^(-Lg)*gn_N;
//  Lg=Lg*ones(gn);
//------------------------------------------------------------------
// 3-calcul de la reponse frequentielle Gf par transformee de fourier rapide
// soif F=fft(sn);
// alors F(k)=S(z), en z= exp(i.2pi.fk) , et fk= (k-1)/N_FFT
// N_FFT est le nb d'echantillons de F, en puissance entiere de 2
//------------------------------------------------------------------

  N_FFT=16*NG; // nb echantillons for fft;
  L_FFT=ceil(log2(N_FFT)); // L_FFT =plus petit entier plus grand que log2(N_FFT)
  N_FFT=round(2^L_FFT);
  zn=zeros(N_FFT-NG,1); // zn= vecteur de zeros, a N_FFT-NG lignes,1 colonne
  sn=[gn;zn]; // sn = gn au dessus de zn
  Gf=fft(sn); // calcul de la fft de sn dans le vecteur Gf
  abs_Gf=abs(Gf); // module de Gf
// empeche le calcul de log(0)
  i=find(abs_Gf<=1e-20); // i = indices / abs_Gf(i)<1e-20;
  Gf(i)=1e-20*ones(Gf(i)); // Gf(i) = 1e-20 . 1, de meme taille que Gf(i);
  abs_Gf=abs(Gf); // module de Gf
  abs_Gf_db=20*log10(abs_Gf);
  arg_Gf_rad=imag(log(Gf)); // argument de Gf
//---------------------------------------------------
// 4-calcul reponse frequentielle de G quantifie
//------------------------------------------------------
  sn_q=[gn_q;zn]; // sn_q = gn_q au dessus de zn
  Gf_q=fft(sn_q); // calcul de la fft de sn dans le vecteur Gf_q
  abs_Gf_q=abs(Gf_q); // module de Gf_q
// empeche le calcul de log(0)
  i=find(abs_Gf_q<=1e-20); // i = indices / abs_Gf_q(i)<1e-20;
  Gf_q(i)=1e-20*ones(Gf_q(i)); // Gf_q(i) = 1e-20 . 1, de meme taille que Gf_q(i);
  abs_Gf_q=abs(Gf_q); // module de Gf_q
  abs_Gf_q_db=20*log10(abs_Gf_q);
  arg_Gf_q_rad=imag(log(Gf_q)); // argument de Gf_q

//------------------------------------------------------------------
// 5-trace des reponses impulsonnielles = coefficients gn,gnq en fct de n
//------------------------------------------------------------------
  n_ech=0:(NG-1); // echantillons de 0 a NG-1
  n_ech=n_ech.'; // on transpose n_ech pour fabriquer un vecteur colonne
  figure(0);clf("reset");         // ouvre figure 0 et efface tout
  subplot(2,1,1); // trace en haut
  plot2d(n_ech,[gn,gn_q]); // trace de gn=f(n) (noir) gn_q=f(n) (bleu)
  xtitle("reponse impulsionnelle de G(z) et Gq(z)");
  xgrid(1); // trace quadrillage en noir
  subplot(2,1,2); // trace en bas
  plot2d(n_ech,[gn-gn_q]); // trace de gn=f(n) (noir) gn_q=f(n) (bleu)
  xtitle("erreur gn-gnq");
  xgrid(1); // trace quadrillage en noir
//-----------------------------------------------------
// 6-Trace des reponses frequentielles G(f) Gq(f)
//-----------------------------------------------------
// calcul des frequences fk pour lesquelles G(fk) a ete evaluee
  fk=(0:N_FFT-1)/N_FFT;//frequences fk de la  fft su N_FFT echantillons
  fk=fe*fk;// on passe en frequences reelles
  fk=fk.';// on transpose pour fabriquer un vecteur colonne
  i_f=find(fk<=fe/2); // i_f= indices pour lesquels fk<= fe/2
  fk=fk(i_f); // fk = partie de fk correspondant a ces indices
  Gf=Gf(i_f); // et ainsi de suite
  Gf_q=Gf_q(i_f);
  abs_Gf=abs_Gf(i_f);
  abs_Gf_q=abs_Gf_q(i_f);
  figure(1);clf("reset");// active figure 1 , et efface son contenu
  subplot(2,1,1); // partitionne la fenetre en 2 lignes, 1 col et trace en haut
  plot2d(fk,[abs_Gf,abs_Gf_q]); // trace modules
  xtitle("G(f), noir et Gfq(bleu)")
  xgrid(1); // trace quadrillage en noir
  subplot(2,1,2); // trace erreur
  plot2d(fk,abs(Gf-Gf_q),1);// erreur
  xtitle("erreur G(f))-Gq(f)");
  xgrid(1); // trace quadrillage en noir
//--------------------------------------------------------
// 7-GENERE LE CODE C DE DECLARATION DES COEFFS DANS LE PROGRAMME toto.c
// voir detail des fonctions dans le fichier functions_gene_code.sce
//--------------------------------------------------------
// 7.1- cree les declarations des tableaux de coeffs
  type_int_N="int_"+string(NB_BITS);
  type_int_2N="int_"+string(2*NB_BITS);
  l_gN=get_list_array_coeffs(type_int_N,"gn_N",gn_N);
  l_LG=get_list_array_coeffs("short int","Lg_moins_L",Lg-L_SIGNAL);
  l_g=get_list_array_coeffs("double","gn",gn);
// 7.2- cree l'entete du programme
  l=list();i=0;
  i=i+1;l(i)="#define "+type_int_N+" short int";
  i=i+1;l(i)="#define "+type_int_2N+" long int";
  i=i+1;l(i)="/* stdio may be useful if you use printf */";
  i=i+1;l(i)="#include <stdio.h>";
  i=i+1;l(i)="/* stdlib is needed for malloc declaration */";
  i=i+1;l(i)="#include <stdlib.h>";
  i=i+1;l(i)="/* math is needed for trigonometric functions, dont forget -lm at linckage */";
  i=i+1;l(i)="#include <math.h>";

  i=i+1;l(i)="const long int NG="+string(NG) +";";
  i=i+1;l(i)="const      int L_SIGNAL="+string(L_SIGNAL) +";";
// 7.3- juxtapose ( concatene ) les listes
  l=lstcat(l,l_gN); // lstcat= concatenation de listes
  l=lstcat(l,l_LG);
  l=lstcat(l,l_g);
  write_list_to_file(l,"toto.c");
// 7.3 affichage eventuel des resultats, en decommentant la ligne suivante
//  [gn,gn_q,Lg,gn_N]
//----------------------------------------------------------
// 8-détermination de f0 et f1 ( a adapter et completer)
//----------------------------------------------------------
// determination de f0, a adapter
  i=find(abs_Gf>=0.95); // i= indices pour lesquelles abs_Gf>=0.9
  i=max(i);            // i= plus grande valeur de i
  f0=fk(i);            // f0=frequence correspondante
  disp(" |Gf|=0.95, lorsque f=" +string(f0)); // affichage a l'ecran
// determination de f1, a adapter
  i=find(abs_Gf<=0.5); // i= indices pour lesquelles abs_Gf>=0.9
  i=min(i);            // i= plus grande valeur de i
  f1=fk(i);            // f0=frequence correspondante
  disp(" |Gf|=0.5, lorsque f=" +string(f1)); // affichage a l'ecran
//-------------------------------------------------------------
// 9-DETERMINATION SYSTEMATIQUE DE NG
// f0=frequence / |G(f0)|=0.8,f1=frequence / |G(f1)|=0.2,
// a determiner avec la fonction find de scilab si pas deja fait
//--------------------------------------------------------------
  delta_f=abs(f1-f0); // delta_f=|f1-f0|
  P=NG*te*delta_f;
//  f0_desiree=;// a completer, voir gabarit
//  f1_desiree=;// a completer, voir gabarit
//  delta_f_desire=f1_desiree-f0_desiree;
//  NG_necessaire= ;   // a completer NG=fct(P,te,delta_f_desire);
//  NG_necessaire=ceil(NG_necessaire);// arrondit a l'entier superieur
//  disp("choisir NG="+string(NG_necessaire)+" pour repondre au gabarit");
