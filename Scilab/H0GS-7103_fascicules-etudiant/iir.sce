//--------------------------------------------
//  entete standard
//--------------------------------------------  
  clear; // effacementdes variables et fonctions
  lines(0);funcprot(0); // affichage sans pause, pas de ptompt a la redefinition des fonctions
  rep=get_absolute_file_path("iir.sce");chdir(rep); // on se place sous le repertoire contenant le fichier 'iir.sce'
  stacksize(10000000); // take 10MO of stacksize
// ce programme genere le code c d'implementation d'un filtre iir defini par l'utilisateur
// integration des differentes fonctions utilisees
   exec("functions.sce");
   exec("functions_scaling.sce");
   exec("functions_statespace.sce");
   exec("functions_allpass.sce");
   exec("functions_direct_forms.sce");
   exec("functions_gene_code.sce");
   exec("functions_gene_vhdl.sce");
   exec("functions_gene_pcaxe.sce");
//-----------------------------------------------------
// definition des parametres de la generation de code
//----------------------------------------------------
   params.i_norm_scaling=1; // 1, 2 or %inf, norme pour le calcul des facteurs d'echelle
   params.i_norm_analysis=2;// 1, 2 or %inf, norme pour l'analyse des bruits
//------------------------------------------------------------------------------
// params.NBECHS_NORM est le nombre d'echantillons employe
//  pour le calcul des normes 1 ou 2
// ce parametre est optionnel, et il vaut mieux
// laisser le programme decider seul de la valeur a employer
//------------------------------------------------------------------------------
   params.NBECHS_NORM=100000; // nombre d'echantillons pour l'evaluation des normes
   params.NB_BITS=16; // nombre de bits de codage 

//-------------------------------------------------------
// forme de programmation analysee
// la generation de code en c est limitee aux formes df2 et state-space 
// par contre l'analyse et le scaling sur le schema standard
// sont effectuees pour toutes les formes
//-------------------------------------------------------
   params.switch_form="df2";// "df1","df1t","df2","df2t","state-space"

//-------------------------------------------------------------------------
// un filtre d'ordre eleve est structure sour la forme de
// filtres (ou cellules) elementaires d'ordre 1 ou 2
// le switch params.switch_structure ci-dessous decide de la programmation employee
// "cascade" : le filtre F(z) est decrit sous la forme de cellule cascade Fi(z)
//           F(z) =produit des Fi(z)
// "paralell" : le filtre F(z) est decrit sous la forme de cellule paralelles Fi(z)
//           F(z) =somme des Fi(z)
// "cascade-to-paralell" : Le filtre F(z) est decrit sous forme de cellules cascade
//         F(z) =produit Fi(z)
// et doit etre programme sous la forme de celulles paralelles Gi(z)
//         F(z) = somme Gi(z), les Gi(z) sont calculees par le programme
//-----------------------------------------------------------------------------
   params.switch_structure="cascade";//"cascade","paralell","cascade-to-paralell"
//-------------------------------------------------------------
// il est possible de coder les celulles directement en q=z^-1
// ou avec un operateur x=q(z^-1), mieux adapte
// dans le cas de frequences de
// coupure faibles devant la frequence d'echantillonnage
//----------------------------------------------------------------
   params.switch_operateur="z_1"; // "z_1" ou "x"
//-------------------------------------------
// parametres specifiques a la generation de code
//-------------------------------------------
// nom des fichiers generes en langage c
   params.file_name="toto"; // will generate toto.c,toto_int.c,toto_float.c
// nom des fonctions
   params.name_filter="Fz"; // specifc functions for this filter will end with _Fz
//--------------------------------------------------------------
// le parametre suivant specifie
// la maniere de quantifier les sorties des decalages a droite
// dans le code en langage c
//--------------------------------------------------------------
   params.switch_round="floor"; // "floor","round", "fix","round only at key points"
//--------------------------------------------------------------
// le parametre suivant specifie si l'on insere des saturations
// pour empecher les depassements d'echelle dans
// le code en langage c
//-------------------------------------------------------------------
   params.switch_saturate="no saturate"; // "saturate","no saturate"


//--------------------------------------------------------------------------
// DEBUT DU PROGRAMME
//---------------------------------------------------------------------------
//-------------------------------------------------------------
// 1- changements de variables divers de z en w ou en z^-1
//-------------------------------------------------------------
  w=poly(0,"w");          // polynome w
  z=poly(0,"z");          // polynome z
  z_1=poly(0,"z_1");          // polynome z_1=z^-1=1/z ( operateur retard z_1)
  w_de_z  =(z-1)/(z+1);   // w    =f( z  )
  z_1_de_z=1/z;             // z_1 =f( z)
  z_de_w  =horner11_inv(w_de_z  ,"w");    // z=f( w  ), en inversant w=f(z) avec horner11_inv
  z_de_w=normalize(z_de_w,"ld"); // normalisation / coeff plus bas degre denominateur
  z_de_z_1=horner11_inv(z_1_de_z,"z_1");  // z=f(z_1), en inversant z_1=f(z) avec horner11_inv
  z_1_de_w=hornerij(z_1_de_z,z_de_w,"ld");// z_1=f(w),=z_1(z(w)) avec hornerij
  w_de_z_1=hornerij(w_de_z,z_de_z_1,"ld");// w=f(z_1),=w(z(z_1)) avec hornerij

//-------------------------------------------------
// Frequence et periode d'echanillonnage
//-------------------------------------------------
  fe=20000; // frequence d'echantillonnage
  te=1/fe; // periode d'echantillonnage
//---------------------------------------------------
// 1- DEFINITION DU GABARIT DU FILTRE PASSE-BAS EN FREQUENCES REELLES
//---------------------------------------------------
  f0=90; // frequence de coupure basse f0 en hertz
  f1=110; // frequence de coupure basse f0 en hertz
  G0_db=20*log10(0.9); // Gain minimum pour f<=f0, en decibels
  G1_db=20*log10(0.01); // Gain maximum pour f>=f1, en decibels
  modele_flt="ellip"; // "butt","cheb1","cheb2","ellip" selon le modele voulu
//-------------------------------------------------------
// 2- TRADUCTION DU GABARIT DANS LE PLAN W ( EN PSEUDO-PULSATIONS)
//-------------------------------------------------------
  v0=tan(%pi*f0/fe);// pseudo-pulsation de coupure v0 associee a f0
  v1=tan(%pi*f1/fe);// pseudo-pulsation de coupure v1 associee a f1
//-------------------------------------------------------
// 3- CALCUL D'UN FILTRE REPONDANT AU GABARIT DANS LE PLAN W
// F(w) =K . F_de_w(1).F_de_w(2)... => decomposition cascade
// F_de_w est une liste
//-------------------------------------------------------
// 3.1-emploi de la fonction low_pass_en_p, comme si c'etait un filtre continu
  [K,F_de_w] = low_pass_en_p(modele_flt,v0,v1,G0_db,G1_db);
// 3.2-repartition du gain K entre toutes les cellules cascade
  F_de_w=distribute_gain(K,F_de_w);

//-------------------------------------------------------
// 4- CALCUL DU FILTRE EN z et en z^-1
//-------------------------------------------------------
  F_de_z=hornerij(F_de_w,w_de_z,"hd");// calcul de F(z) sous forme de liste
  F_de_z_1=hornerij(F_de_w,w_de_z_1,"ld");// calcul de F(z^-1) sous forme de liste
//-----------------------------------------------------
// 5-CARACTERISTIQUES TRACE DES REPONSES FREQUENTIELLES
//------------------------------------------------------
  v0_aff=v0/100; // pseudo pulsation minimum pour trace rep frequentielle
  v1_aff=10; // pseudo pulsation maximum pour trace rep frequentielle
  nb_points_aff=1000; // nombre de points d'affichage
// creation de la liste F_de_w ,
// des cellules d'ordre 1 our 2, decrivant le filtre dans le plan W
// ( cascade ou paralelles selon params.switch_structure)
//----------------------------------------------------------
// 6-CALCUL DU FILTRE EN NOMBRES ENTIERS,
// QUANTIFICATION,SCALING ET ANALYSE SUR LA BASE DU SCHEMA STANDARD
// ASSOCIE A LA FORME ETUDIEE (df1,df1t,df2,df2t,...)
// output est une structure scilab 
// contenant toutes les informations pertinentes
//----------------------------------------------------------
  output=compute_c_filter(F_de_w,params);
//----------------------
// 7-GENERATION DE CODE ET AFFICHAGE DES RESULTATS
//----------------------
  if (typeof(output)~="list" ) then
    liste_outputs=list();
    liste_outputs(1)=output;
  else
    liste_outputs=output;
  end
  code_to_write=[];

  for i=1:length(liste_outputs),
    output_i=liste_outputs(i);
    params_i=output_i.params;
    disp("-----caracteristics of filter :"+params_i.name_filter+"---");
    if params_i.switch_form=="df2" then
      code_to_write=append_filter_to_c_code(code_to_write,output_i);
    else
      disp(" NO CODE GENERATED, CODE GENERATION ONLY FOR switch_form=df2 ");
    end 
    nb_cels=length(output_i.F_z);
    s=string(nb_cels)+" "+params_i.switch_structure;
    s=s+"  cels of type : "+params_i.switch_form;
    if params_i.switch_form=="state-space" then
      s =s+"("+params_i.switch_ss+")"
    end
    [degree_n,degree_d]=order_filter(output_i.F_z);
    disp("  degree numer="+string(degree_n)+",degree denom="+string(degree_d));

  // niveaux de sortie dus a e( calcules dans functions_gene_code,compute_filter)
    F_z_qtf=output_i.F_z_qtf;
    NBECHS_NORM=params_i.NBECHS_NORM;
    [N_z_qtf,D_z_qtf]=make_as_ND(F_z_qtf);
    max_s=output_i.output_levels.max_module_s;
    max_val_eff_s=output_i.output_levels.max_val_eff_s;
    ecart_type_s=output_i.output_levels.ecart_type_s;

// affichage des resultats
    disp(" 1-  "+s);
    disp(" 2-  scaling norm= "+string(params_i.i_norm_scaling));
    if (params_i.is_paralell==%f) then
    // bug, cette info n'est valable que pour des structures cascade
      disp(" 3.1 max sortie utile ="+string(max_s));
      disp(" 3.2 max val eff sortie utile ="+string(max_val_eff_s));
      disp(" 3.3 ecart-type sortie utile  ="+string(ecart_type_s));
    end
    disp(" 4-  output noise (norme "+string(params_i.i_norm_analysis)+")="+string(output_i.output_noise));
    disp(" 5-  operator ="+params_i.switch_operateur);
  end //for i=1:length(liste_outputs),
  if (params_i.switch_form=="df2") then
    file_name=liste_outputs(1).params.file_name;
    write_list_to_file(code_to_write.all_code,file_name+".c");
    write_list_to_file(code_to_write.int_code.all_code,file_name+"_int.c");
    write_list_to_file(code_to_write.float_code.all_code,file_name+"_float.c");
  end
//-----------------------------------------------------------
// 8-TRACE DES RESPONSES FREQUENTIELLES
//-----------------------------------------------------------
  v_aff=logspace(log10(v0_aff),log10(v1_aff),nb_points_aff);
  f_aff=atan(v_aff)/%pi;
  z_aff=exp(%i*2*%pi*f_aff);
  for io=1:length(liste_outputs),
    output_i=liste_outputs(io);
    params_i=output_i.params;
    if (params_i.is_paralell==%t) then
      rep_F_ideal=get_as_sum(hornerij(output_i.F_z,z_aff)).';
      rep_F_qtf  =get_as_sum(hornerij(output_i.F_z_qtf,z_aff)).';
    else
      rep_F_ideal=get_as_product(hornerij(output_i.F_z,z_aff)).';
      rep_F_qtf  =get_as_product(hornerij(output_i.F_z_qtf,z_aff)).';
    end
    if (max(size(rep_F_ideal))>1) then
      rep_F=[rep_F_ideal,rep_F_qtf];
      md_F=abs(rep_F);
      mx_F=max(md_F);
      i=find(md_F<=1e-9*mx_F);
      md_F(i)=1e-9*mx_F*ones(md_F(i));
      figure(io);clf("reset");
      subplot(2,1,1);
      xtitle("ideal and quantified responses of filter :"+params_i.name_filter);
      plot2d(f_aff*fe,20*log10(md_F));
      rep_DF=rep_F-[rep_F_ideal,rep_F_ideal];
      md_DF=abs(rep_DF);
      i=find(md_DF<=1e-9*mx_F);
      md_DF(i)=1e-9*mx_F*ones(md_DF(i));
      subplot(2,1,2);
      plot2d(f_aff*fe,20*log10(md_DF));
      xtitle("difference between ideal and quantified "+string(params_i.NB_BITS)+" bits responses","frequency Hz","gain dB");
    end
  end
//----------------------------------------------------------------
// AFFICHAGE DES STRUCTURES
// DECOMMENTER POUR AFFICHER LES CHAMPS
//---------------------------------------------------------------  
// output_i         // affichage sortie
// output_i.params // affichage parametres
