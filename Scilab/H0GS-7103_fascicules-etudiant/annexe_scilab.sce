//--------------------------------------------
//  entete standard
//--------------------------------------------  
  clear; // effacementdes variables et fonctions
  lines(0);funcprot(0); // affichage sans pause, pas de ptompt a la redefinition des fonctions
  rep=get_absolute_file_path("annexe_scilab.sce");chdir(rep); // on se place sous le repertoire contenant le fichier 'iir.sce'
  stacksize(10000000); // take 10MO of stacksize
//ce programme contient le code des exemples en annexe scilab
// penser a finir les lignes par des points-virgule,
//  pour eviter l'affichage, lorsque vous les recopierez
   clear
   lines(0);
// integration des differentes fonctions ecrites par l'enseignant
   exec("functions.sce");
   exec("functions_scaling.sce");
   exec("functions_statespace.sce");
   exec("functions_allpass.sce");
   exec("functions_direct_forms.sce");
   exec("functions_gene_code.sce");
//-----------------------------------------------------
// 3.1 polynomes et fractions rationnelles
//-----------------------------------------------------
// 3.1.1, 3.1.2 creation, les quantites en majuscules et en minuscules sont egales 
  p=poly(0,"p")     // polynome p= (p-0)
  P=poly([0,1],"p","coeffs") // polynome P= 0+1.p;
  r1=1+2*p
  R1=poly([1,2],"p","coeffs")
  r2=(p-1)*(p-2)
  R2=poly([1,2],"p")
// 3.2 calcul
  x=(p+1)*(p+7) / (p+8)^3
// 3.3, analyse
// 3.3.1 numerateur et denominateur
  num_x=numer(x)
  den_x=denom(x)
// 3.3.2 racines
  racines_num_x=roots(num_x)
  racines_den_x=roots(den_x)
// 3.3.3 coeffs
  coeffs_num_x=coeff(num_x)
  coeffs_den_x=coeff(den_x)
  degre_num=degree(num_x)
// 3.3.4 fonction horner ( ne pas employer pour des changements de variable)
  x0=25; x1=%i*3;
  x_de_x0=horner(x,x0) // calcul de la valeur de x(x0)
  x_de_x1=horner(x,x1) // calcul de la valeur de x(x1)
  x01=[x0,x1] // creation du vecteur ligne x01=[x0,x1]
  x_de_x01=horner(x,x01) // calcul du vecteur des valeurs [x(x0),x(x1)]
//--------------------------------------------------------------------
// 3.4 gestion de listes de fractions rationnelles
//-------------------------------------------------------------------
// 3.4.1- exemple de creation de liste
  l=list();
  l(3)=25
  l(7)="salut les gars"
  indice_max=length(l) // plus grand indice defini de l
  indices_de_l=definedfields(l)// indices_de_l=vecteur des indices definis
  for i=definedfields(l), 
    element_i=l(i);
    disp("l("+string(i)+") est egal a :"+string(element_i));
  end
// 3.4.2 creation d'une liste de fractions rationnelles
  z=poly(0,"z"); 
  F_de_z=list(); // creation d'une liste vide F(z)
  F_de_z(1)=(z+0.9)/(z+0.91); // premier element
  F_de_z(2)=(z-0.9)/(z-0.91);  // deuxieme element

  F_de_z                     // pour afficher F_de_z
// 3.4.3 evaluation et changements de variable
// 3.4.3.1 changement de variable hornerij,horner11_inv
  w=poly(0,"w") // polynome w
  z=poly(0,"z") // polynome z
  z_1=poly(0,"q") // polynome z_1=z^(-1) , on note z^-1=q
  z_1_de_z=1/z // definition de z-1(z) = 1/z
  // calcul de z(z^-1), connaissant z^-1(z),
  //  il faut preciser le nom "q", que scilab ne peut pas deviner
  z_de_z_1=horner11_inv(z_1_de_z,"q")
  z_de_w=(1+w)/(1-w) // definition de z(w)
  w_de_z=horner11_inv(z_de_w,"z") // calcul de w(z), connaissant z(w)
  w_de_z_1=hornerij(w_de_z,z_de_z_1) // calcul de w(z-1), connaissant w(z) et z(z^-1)
  z_1_de_w=horner11_inv(w_de_z_1,"w") // calcul de z^-1(w) , connaissant w(z^-1)
  // 3.4.3.2 normalisations
  // la fonction hornerij permet de normaliser a 1 un des termes du resultat
  // en l'appelant avec un 3eme parametre
  // w(z^-1) en normalisant a 1 low denom term => "ld"
   w_de_z_1=hornerij(w_de_z,z_de_z_1,"ld")
  // normalisation de z_de_w ( terme de plus haut degre denom =1)
   z_de_w=normalize(z_de_w,"hd") //"hd","hn","ld","ln" au choix
  // 3.4.3.3 chgt de variable et evaluation sur des listes
  F_de_w=hornerij(F_de_z,z_de_w,"hd")
  // retour en z pour verifier si erreur
  F2_de_z=hornerij(F_de_w,w_de_z,"hd")
// 3.4.4 gestion des sommes et produits get_as_sum,get_as_product
  z0=%i*%pi/4
// methode 1 a proscrire
  F_de_z_globale=get_as_product(F_de_z) // fraction rationnelle globale en z
  F_de_z0_glob=horner(F_de_z_globale,z0)// forcement horner, car degre(F(z)) peut etre grand
// methode 2 a employer
  F_de_z0=hornerij(F_de_z,z0) // liste des valeurs de chaque element
  F_de_z0_glob=get_as_product(F_de_z0) // produit des valeurs
//--------------------------------------------------------------------------------
// 3.4.5 evaluation de reponses frequentielles sur des listes de fractions rationnelles
//--------------------------------------------------------------------------------
//3.4.5.1 creation de vecteurs
  f0=0;f1=100;nb_points=3; // 3 points en frequences de 0hz a 100 hz
  fi=linspace(f0,f1,nb_points); // fi=vecteur ligne de nb_points points entre f0 et f1
  // fi=logspace(log10(f0),log10(f1), nb_points) pour echelle log
  fi=fi.'; // on transpose fi pour en fabriquer un vecteur colonne
//----------------------------------------
// 3.4.6 reponse frequentielle de F(z)
//----------------------------------------
  fe=1000; // frequ echantillonnage = 1000hz
  zi=exp(%i*2*%pi*fi/fe); // points zi correspondant pour calcul reponse frequentielle
  F_de_zi=hornerij(F_de_z,zi) // evaluation de la liste des Fz(zi)
  F_de_zi_globale=get_as_product(F_de_zi)
// calcul module reel, module en db et argument en degre
  module=abs( F_de_zi_globale)
  [module_db,arg_degres]=get_module_arg(F_de_zi_globale)
//----------------------------------------
// 3.4.7 reponse frequentielle de F(w)
//----------------------------------------
  vi=tan(%pi*fi/fe)  // pseudo -pulsation v
  wi=%i*vi           // calcul des valeurs wi=i.v
  // on aurait pu directement ecrire  wi=hornerij(w_de_z,zi); 
  F_de_wi=hornerij(F_de_w,wi)// evaluation de la liste des  Fw(wi)
  F_de_wi_globale=get_as_product(F_de_wi)// valeur globale en w
//----------------------------------------
// 3.4.8 evaluation module et argument
//----------------------------------------
  module_reel=abs(F_de_wi_globale); // absolute value of F_de_wi_globale 
  [module_db,arg_degres]=get_module_arg(F_de_wi_globale) // mod db and arg degres
//------------------------------------------------------------
// 3.4.9 calcul de la reponse impulsionelle de F(z) fonction impulse_Fz
//---------------------------------------------------------
  type_de_liste="cascade"; // "cascade","paralell" ou "matrix" selon le cas
  NB_ECH=30; // 30 echantillons
// calcul des NB_ECH premiers echantillons de la reponse impulsionnelle de fn
// vecteur ligne
//  fn=impulse_Fz(F_de_z,NB_ECH,type_de_liste);
//  fn=fn.'; // on transpose parce-que le prof prefere les vecteurs colonne
//------------------------------------------------------------
// 3.4.10 reponse de F(z) a une entree quelconque fonction filter_Fz
//---------------------------------------------------------
  type_de_liste="cascade"; // "cascade","paralell" ou "matrix" selon le cas
  NB_ECH=30; // 30 echantillons
  en=ones(1,30); //en = vecteur ligne ne contenant que des 1  
  sn=filter_Fz(F_de_z,en,type_de_liste); // sn=rep de F(z) a l'entree en
  sn=sn.'; // on transpose parce-que le prof prefere les vecteurs colonne
//------------------------------------------------------------
// 3.4.11 calcul de normes, fonction norme_Fz
//---------------------------------------------------------
  type_norme=1;type_de_liste="cascade";NB_ECH=1000;
  norme1_Fz=norme_Fz(F_de_z,type_de_liste,type_norme,NB_ECH)
  type_norme=2;type_de_liste="cascade";NB_ECH=1000;
  norme2_Fz=norme_Fz(F_de_z,type_de_liste,type_norme,NB_ECH)
  type_norme=%inf;type_de_liste="cascade";NB_ECH=1000;
  normeHinf_Fz=norme_Fz(F_de_z,type_de_liste,type_norme,NB_ECH)
//---------------------------------------------------------------------
// 4-graphiques
//---------------------------------------------------------------------
// 4.1 code standard de lancement
  num_fig=2; 
  figure( num_fig); // cree ou active figure num_fig
  clf("reset"); // efface tout dans figure num_fig
  subplot(2,3,5); // selection zone de trace
// 4.2 trace de courbes
  x=linspace(-1,1,100); // x= vct ligne, 100 points entre -1 et 1
  x=x.'; // on transpose x pour en fabriquer un vecteur colonne;
  // on cree 2 vecteurs y1,y2,y3 pour exemples
  y1=x^2;
  y2=x^3;
  y3=x^4;
//4.2.1 trace y=f(x)
  subplot(2,4,1); // selection zone de trace
  plot2d(y1);
  xtitle("4.2.1"); // titre pour s'y retrouver
//4.2.2 trace y=f(x)
  subplot(2,4,2); // selection zone de trace
  plot2d(x,y1);
  xtitle("4.2.2"); // titre pour s'y retrouver
//4.2.3 trace y=f(x)
  subplot(2,4,3); // selection zone de trace
  plot2d(x,[y1,y2,y3]);
  xtitle("4.2.3"); // titre pour s'y retrouver
//4.2.3 trace y=f(x)
  subplot(2,4,4); // selection zone de trace
  plot2d("nl",x,[y1,y2,y3]); // echelles x=normal<=>lineaire, y=logarithmique
  xtitle("4.2.4"); // titre pour s'y retrouver
//4.3 personnalisation des graphiques
// 4.3.1
  subplot(2,1,2); // selection zone de trace en bas
  plot2d(x,[y1,y2,y3],[3,1,2]); // y1,y2,y3 en couleurs 3,1,2
// 4.3.2 ajout de legendes
  legends(["y1","y2","y3"],[3,1,2],"lr"); // en bas a droite , low-right
  legends(["y1","y2","y3"],[3,1,2],"ul"); // en haut  a gauche , up-left
// quadrillage et titre
  xgrid(4); // quadrillage en couleur 4
  xtitle(" y1,y2,y3=f(x)","axe des y"," axe des x");


