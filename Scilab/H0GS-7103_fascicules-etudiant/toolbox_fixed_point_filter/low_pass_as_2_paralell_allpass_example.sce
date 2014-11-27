//-------------------------------------------------------------
// entete standard
//-------------------------------------------------------------
   clear
   lines(0);funcprot(0);
   rep=get_absolute_file_path("low_pass_as_2_paralell_allpass_example.sce");
   chdir(rep);
// integration of my specific functions 
   exec("functions.sce");
   exec("functions_scaling.sce");
   exec("functions_statespace.sce");
   exec("functions_allpass.sce");
   exec("functions_direct_forms.sce");
   exec("functions_gene_code.sce");
   exec("functions_gene_vhdl.sce");
   exec("functions_gene_pcaxe.sce");
//-----------------------------------------------------
// code generation parameters
//----------------------------------------------------
//-------------------------------------------------------------------
// PARAMETER 1 : scaling norm fixed by params.i_norm_scaling
//     1    for l1 norm ( sum of absolute values of impulse response)
//     2    for l2 norm ( sqrt of ( sum of square values of impulse response)
//     %inf for Hinfinity norm (max modulus of frequency response)
//-------------------------------------------------------------------
   params.i_norm_scaling=1; // 1, 2 or %inf
//-------------------------------------------------------------------
// PARAMETER 2 : noise analysis norm fixed by params.i_norm_scaling
//     1    for l1 norm ( sum of absolute values of impulse response)
//           => max noise on output
//     2    for l2 norm ( sqrt of ( sum of square values of impulse response)
//           => standard deviation of noise on output,
//              for independant uniform white quantization noises
//     %inf for Hinfinity norm (max modulus of frequency response)
//-------------------------------------------------------------------
   params.i_norm_analysis=2;// 1, 2 or %inf
//------------------------------------------------------------------------------
// params.NBECHS_NORM is the number of samples for norms evaluation
// it is automatically setted by the software if you don't precise it
//------------------------------------------------------------------------------
//   params.NBECHS_NORM=100000; // nombre d'echantillons pour l'evaluation des normes
//------------------------------------------------------------------------------
// params.NB_BITS fix the number of bits used for code generation and coefficients quantization
//------------------------------------------------------------------------------
   params.NB_BITS=16; // nombre de bits de codage 

//-------------------------------------------------------
// FORM USED FOR CELS REALIZATION
// the filter or transfer function
// is realized as a product ( cascade ) or sum ( paralell)
// of first and second order cels.
//---------------------------------------------------------------------
// params.switch_form sets the implementation form used each cel
// df1 for direct form 1
// df2 for direct form 2
// df1t for direct form 1 transposed
// df2t for direct form 2 transposed
// state-space for state-space form
//   in this last case you have to specify what state-space form you want to use
//   with the extra-parameter :    params.switch_ss='hwang';
//   "hwang"  for noise optimal mullis-roberts-hwang state-space realization
//   "normal" for normal noise optimal state-space realization
//-------------------------------------------------------------------------
// BE CAREFUL :
// the quantization, scaling and analysis is performed for any form
// THE C CODE GENERATION ONLY WORKS FOR DF2 AND STATE-SPACE FORMS
//-------------------------------------------------------
   params.switch_form="df2";// "df1","df1t","df2","df2t","state-space"
   if (params.switch_form=="state-space") then
     params.switch_ss="hwang" ;
   end
//-------------------------------------------------------------------------
// CHOICE OF CELS DECOMPOSITION
// params.switch_structure decide of the way the filter will be realized
//-------------------------------------------------------------------------
// The base filter or transfer function is described by a list in w plane F_of_w
// wich can be a product (cascade) : F(w) =F_of_w(1).F_of_w(2)...
//          or a sum     (paralell): F(w) =F_of_w(1)+F_of_w(2)+...
// of 0, 1st or 2nd order cels in the w plane (bilinear transform)
// -------------------------------------------------------------------------
// params.switch_structure decide how the filter is to be implemented
// 1-params.switch_structure="cascade" means that
//   F(w) is described as a product, and will be implemented as a product
// 2-params.switch_structure="paralell" means that
//   F(w) is described as a sum, and will be implemented as a sum
// 3-params.switch_structure="cascade-to-paralell" means that
//   F(w) is described as a product, and will be implemented as a sum
//   ( a partial fraction decomposition will be internally performed)
//---------------------------------------------------------------------------
   params.switch_structure="paralell";//"cascade","paralell","cascade-to-paralell"
//---------------------------------------------------------------------------
// CHOICE OF OPERATOR
// params.switch_operateur defines the used operator to code filter
// the main work of the author is to realize the filter
// with an non classic operator, adapted to the dynamics of each cel
// the use of this operator ( named x) dramatically improve
// the perfomance ( ouput noise level, and frequency response sensitivity)
// when the cutting frequencies of the cels
//   are closed to 0 (negligeable in regard of the sampling frequency fs)
//   are closed to nyquist frequency (half of sampling frequency fs)
//----------------------------------------------------------------------------
// you can impose a classic coding of the filter, with delay operator q=z^-1
// by fixing
//    params.switch_operateur="z_1";
// you can impose a improved coding of the filter, with special operator
//    x(z^-1)=2^-Lx.z^-1 /(1 -/+ [1 -/+ 2^-Lx] .z^-1)
// by fixing
//    params.switch_operateur="x";
// in this case you will use 4 additions and 2 shifts more by cel of order 2
//    than in the q=z^-1 case
// but for cut off frequencies closed to zero, noise and sensitivity behaviours
// will be dramatically improved...
//----------------------------------------------------------------
   params.switch_operateur="x"; // "z_1" ou "x"
//-------------------------------------------
// C CODE GENERATION PARAMETERS
//-------------------------------------------
//--------------------------------------------------------
// NAME OF C FILES
// params.file_name define the name of generated c files
// for exemple
//   params.file_name="toto"; will generate 3 c files
//   1-toto.c     containing filter implementation for integer and floating point numbers
//   2-toto_int.c,containing filter implementation only for integer numbers
//   3-toto_float.c,containing filter implementation only for floating points numbers
//------------------------------------------------------
   params.file_name="two_allpass"; // will generate two_allpass.c,two_allpass_int.c,two_allpass_float.c
//---------------------------------------------------------------------------------
// NAME OF FUNCTIONS IN C FILES
// params.name_filter defines the postfix in C files, corresponding to the filter
// for example if params.name_filter="Fz";
// All functions specific to the filter will end with the character string _Fz
//--------------------------------------------------------------------------------
   params.name_filter="Fz"; // specifc functions for this filter will end with _Fz
//--------------------------------------------------------------
// ROUNDING, TRUNCATE OR FIX
// params.switch_round sets the way results are truncated in the C code
//   params.switch_round="floor"; truncate to inf integer
//   params.switch_round="round"; truncate to nearest integer
//  params.switch_round="fix";truncate to integer nearest 0
//  params.switch_round=round only at key points"; round results only at important points
//--------------------------------------------------------------
   params.switch_round="round"; // "floor","round", "fix","round only at key points"
//--------------------------------------------------------------
// SATURATE INTERNAL VARIABLES TO AVOID OVREFLOW
// params.switch_saturate defines if you use internal variables saturation
// to avoid overflow.
// typically
//     params.switch_saturate="no saturate";
//     for 1-norm (never overflow)and Hinfinity (rare overflow)norm scaling
// and
//     params.switch_saturate="saturate";
//     for 2-norm ( frequent overflow) scaling

//-------------------------------------------------------------------
  if (params.i_norm_scaling==1)|(params.i_norm_scaling==%inf) then
     params.switch_saturate="no saturate"; // "saturate","no saturate"
  else
     params.switch_saturate="saturate"; // "saturate","no saturate"
  end

//-------------------------------------------------------------
// VARIABLES DEFINITIONS ( DON'T MODIFY)
// 1- variables z , w , z^-1 and mappings (don't modify)
//-------------------------------------------------------------
  w=poly(0,"w");          // polynome w
  z=poly(0,"z");          // polynome z
  z_1=poly(0,"z_1");          // polynome z_1=z^-1=1/z ( operateur retard z_1)
  w_of_z  =(z-1)/(z+1);   // w    =f( z  )
  z_1_of_z=1/z;             // z_1 =f( z)
  z_of_w  =horner11_inv(w_of_z  ,"w");    // z=f( w  ), en inversant w=f(z) avec horner11_inv
  z_of_w=normalize(z_of_w,"ld"); // normalisation / coeff plus bas degre denominateur
  z_of_z_1=horner11_inv(z_1_of_z,"z_1");  // z=f(z_1), en inversant z_1=f(z) avec horner11_inv
  z_1_of_w=hornerij(z_1_of_z,z_of_w,"ld");// z_1=f(w),=z_1(z(w)) avec hornerij
  w_of_z_1=hornerij(w_of_z,z_of_z_1,"ld");// w=f(z_1),=w(z(z_1)) avec hornerij

//-------------------------------------------------------------
// FILTER DEFINITION ( MODIFIY AS YOUR CONVENIENCE)
//-------------------------------------------------------------
//-------------------------------------------------
// Sampling Frequency and period
//-------------------------------------------------
  fs=20000; // frequence d'echantillonnage
  ts=1/fs; // periode d'echantillonnage
//---------------------------------------------------
// 1- LowPass Filter Gabarit in Real Frequencies (Hz))
//---------------------------------------------------
  f0=90; // Low Cut Off Frequency f0 (Hz)
  f1=110; // Hig Cut Off Frequency f1 (Hz)
  G0_db=20*log10(0.9);  // mininum Gain for f<=f0, decibels
  G1_db=20*log10(0.01); // maximum Gain for f>=f1, decibels
//-----------------------------------------------------
// 2- filter model
//        "butt"  for butterworth
//        "cheb1" for chebychef  type 1
//        "cheb2" for chebychef  type 2
//        "ellip" for elliptic
//        "bess" for bessel  (typically choose f1 >> f0)
//------------------------------------------------------------------------
  modele_flt="ellip"; // "butt","cheb1","cheb2","ellip" 
//-----------------------------------------------------
// 3-CHOOSE FREQUENCY RESPONSE DRAWING DOMAIN
//------------------------------------------------------
  f0_aff=0; // min frequency for drawing
  f1_aff=min([10*f1,0.49*fs]); // max frequency for drawing
  nb_points_aff=1000; // number of drawing points
//------------------------------------------------------------------------
// MAIN PROGRAM, DON'T CHANGE ANYTHING UNDER THIS LINE
//------------------------------------------------------------------------
//-------------------------------------------------------
// 4- GABARIT IN W PLANE ( PSEUDO-FREQUENCIES rad), DON'T CHANGE
//-------------------------------------------------------
  v0=tan(%pi*f0/fs);// pseudo-pulsation v0 corresponding to f0
  v1=tan(%pi*f1/fs);// pseudo-pulsation  v1 corresponding to f1
  v0_aff=tan(%pi*f0_aff/fs);// pseudo-pulsation v0_aff corresponding to f0_aff
  v1_aff=tan(%pi*f1_aff/fs);// pseudo-pulsation v1_aff corresponding to f1_aff
//-------------------------------------------------------
// 3- IDEAL CASCADE FILTER COMPUTATION
// F(w) =K . F_of_w(1).F_of_w(2)... => allways cascade decomposition
// F_of_w is a list() of order 0,1,2 cels in w
//-------------------------------------------------------
   if (params.switch_structure=="paralell") then
    params.switch_structure="cascade-to-paralell";
   end
// 3.1-use of function low_pass_en_p, as for a continuous filter
  [K,F_of_w] = low_pass_en_p(modele_flt,v0,v1,G0_db,G1_db);
// 3.2-distribute gain K beetwen cascade cels
  F_of_w=distribute_gain(K,F_of_w);
//3.3 Also compute filter as 2 paralell allpass filters
// F(w)=[sigma1.S1(w) +sigma2.S2(w)]/2
  [S1_of_w,S2_of_w,sigma1,sigma2]=allpass_low_pass_en_p(modele_flt,v0,v1,G0_db,G1_db);
  S1_of_w(1)=sigma1/2*S1_of_w(1);
  S2_of_w(1)=sigma2/2*S2_of_w(1);

//-------------------------------------------------------
// 4- COMPUTE corresponding CELS IN z and z^-1
//-------------------------------------------------------
  F_of_z=hornerij(F_of_w,w_of_z,"hd");// F(z) is a list
  F_of_z_1=hornerij(F_of_w,w_of_z_1,"ld");// F(z^-1) is a list
  S1_of_z=hornerij(S1_of_w,w_of_z,"hd");// S1(z) is a list
  S1_of_z_1=hornerij(S1_of_w,w_of_z_1,"ld");// S1(z^-1) is a list
  S2_of_z=hornerij(S2_of_w,w_of_z,"hd");// S2(z) is a list
  S2_of_z_1=hornerij(S2_of_w,w_of_z_1,"ld");// S2(z^-1) is a list

//----------------------------------------------------------
// 6-COMPUTE CORRESPONDING QUANTIFIED FILTER,
// QUANTIFICATION,SCALING AND NOISE ANALYSIS
// output is a scilab structure containing all relevant information
//----------------------------------------------------------
  output_F=compute_c_filter(F_of_w,params);
  params.name_filter="S1z";
  params.switch_structure="cascade"; // compute S1 as cascade cels
  output_S1=compute_c_filter(S1_of_w,params);
  params.name_filter="S2z";
  params.switch_structure="cascade"; // compute S2 as cascade cels
  output_S2=compute_c_filter(S2_of_w,params);
//----------------------
// 7-C CODE GENERATION AND DISPLAY RESULTS
//----------------------
  liste_outputs=list();
  liste_outputs(1)=output_F;
  liste_outputs(2)=output_S1;
  liste_outputs(3)=output_S2;
  code_to_write=[];

  for i=1:length(liste_outputs),
    output_i=liste_outputs(i);
    params_i=output_i.params;
    disp("-----caracteristics of filter :"+params_i.name_filter+"---");
    if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
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

  // output levels due to input( see function functions_gene_code.sce->compute_c_filter)
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
      disp(" 3.1 max modulus        of useful output signal ="+string(max_s));
      disp(" 3.2 max eff. value     of useful output signal ="+string(max_val_eff_s));
      disp(" 3.3 standard-deviation of useful output signal  ="+string(ecart_type_s));
    end
    disp(" 4-  output noise (norme "+string(params_i.i_norm_analysis)+")="+string(output_i.output_noise));
    disp(" 5-  operator ="+params_i.switch_operateur);
  end //for i=1:length(liste_outputs),
  if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
    file_name=liste_outputs(1).params.file_name;
    write_list_to_file(code_to_write.all_code,file_name+".c");
    write_list_to_file(code_to_write.int_code.all_code,file_name+"_int.c");
    write_list_to_file(code_to_write.float_code.all_code,file_name+"_float.c");
  end
//-----------------------------------------------------------
// 8-TRACE DES RESPONSES FREQUENTIELLES
//-----------------------------------------------------------
  v0_aff=max(v0_aff,1e-10);
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
      xset("window",io);clf(io,"reset");
      subplot(2,1,1);
      xtitle("ideal and quantified responses of filter :"+params_i.name_filter);
      plot2d(f_aff*fs,20*log10(md_F));
      rep_DF=rep_F-[rep_F_ideal,rep_F_ideal];
      md_DF=abs(rep_DF);
      i=find(md_DF<=1e-9*mx_F);
      md_DF(i)=1e-9*mx_F*ones(md_DF(i));
      subplot(2,1,2);
      plot2d(f_aff*fs,20*log10(md_DF));
      xtitle("difference between ideal and quantified "+string(params_i.NB_BITS)+" bits responses","frequency Hz","gain dB");
    end
  end
//----------------------------------------------------------------
// AFFICHAGE DES STRUCTURES
// UNCOMMENT TO DISPLAY THE FIELDS
//---------------------------------------------------------------  
// output_i         // display output structure
// output_i.params // display parameters of code generation
