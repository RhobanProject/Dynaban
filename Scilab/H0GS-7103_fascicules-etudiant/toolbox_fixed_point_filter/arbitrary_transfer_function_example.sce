// this scilab program generate c code of an arbitrary transfer function
// read remarks to adapt it to your own problem
   clear
   lines(0);
   rep=get_absolute_file_path("arbitrary_transfer_function_example.sce");
   chdir(rep);
//-------------------------------------------
// integration of my specific functions
//------------------------------------------------
   exec("functions.sce");
   exec("functions_scaling.sce");
   exec("functions_statespace.sce");
   exec("functions_allpass.sce");
   exec("functions_direct_forms.sce");
   exec("functions_gene_code.sce");
   exec("functions_gene_vhdl.sce");
   exec("functions_gene_pcaxe.sce");
   
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
// FILTER DEFINITION ( MODIFY AT YOUR CONVENIENCE)
//-------------------------------------------------------------
//-------------------------------------------------
// Sampling Frequency and period
//-------------------------------------------------
  fs=20000; // frequence d'echantillonnage
  ts=1/fs; // periode d'echantillonnage
//-----------------------------------------------------
// 3-CHOOSE FREQUENCY RESPONSE DRAWING DOMAIN
//------------------------------------------------------
  f0_aff=0; // min frequency for drawing
  f1_aff=0.49*fs; // max frequency for drawing
  nb_points_aff=5000; // number of drawing points
//-------------------------------------------------------
// 4- DEFINE TRANSFER FUNCTION OF THE FILTER IN W (BILNEAR TRANSFORM )PLANE
// AS A CASCADE LIST F_of_w OF TRANSFER FUNCTIONS OF ORDER <=2
// YOU CAN ALSO USE PARALELL LIST  F_of_w
// IN THIS CASE DON'T FORGET TO MODIFY params.switch_structure ACCORDINGLY
//-------------------------------------------------------
  p = %s;
  F_of_p = (p + 2)/(p + 3);
  // Euler le drame mais facile à comprendre: p_of_z_1 = (1 - z_1) / ts;
  //Tustin :
  p_of_z_1 = (2/ts)*(1 - z_1) / (1 + z_1);
  F_of_z_1 = horner(F_of_p, p_of_z_1);
  F_of_w=list();
  F_of_w(1)=horner(F_of_z_1, z_1_of_w);

//  F_of_w(3)=1/(1+2*0.1*w/0.03+(w/0.03)^2); // third cel
//  F_of_w(4)=1/(1+2*0.01*w/0.03+(w/0.1)^2); // fourth cel

// And so on ... , the only constraints are
// 1- each cel must be stable(  denominator roots have Real part < 0 )
// 2- the order of each cel must be <= 2
// You can also define a list F(z), or F(z_1) in the same way
// And convert it as a list F(w) with the function hornerij :
//   F_of_w=hornerij(F_of_z,z_of_w,"hd"); // "hd" means higher denom coeff normalization
//   F_of_w=hornerij(F_of_z_1,z_1_of_w,"hd");
   
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
//           => max noise on vhdl_output
//     2    for l2 norm ( sqrt of ( sum of square values of impulse response)
//           => standard deviation of noise on vhdl_output,
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
// the quantization, scaling and analysis are performed for any form
// THE C CODE GENERATION ONLY WORKS FOR DF2 AND STATE-SPACE FORMS
//-------------------------------------------------------
   params.switch_form="state-space";// "df1","df1t","df2","df2t","state-space"
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
// see usage after, when defining F_of_w   params.switch_structure="paralell";//"cascade","paralell","cascade-to-paralell"
//---------------------------------------------------------------------------
// CHOICE OF OPERATOR
// params.switch_operateur defines the used operator to code filter
// the main work of the author is to realize the filter
// with an non classic operator, adpated to the dynamics of each cel
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
   params.switch_operateur="z_1"; // "z_1" ou "x"
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
   params.file_name="arbitrary"; // will generate toto.c,toto_int.c,toto_float.c
//---------------------------------------------------------------------------------
// NAME OF FUNCTIONS IN C FILES
// params.name_filter defines the postfix in C files, corresponding to the filter
// for example if params.name_filter="Fz";
// All functions specific to the filter will end with the character string _Fz
//--------------------------------------------------------------------------------
   params.name_filter="arbitrary"; // specifc functions for this filter will end with _Fz
//--------------------------------------------------------------
// ROUNDING, TRUNCATE OR FIX
// params.switch_round sets the way results are truncated in the C code
//   params.switch_round="floor"; truncate to inf integer
//   params.switch_round="round"; truncate to nearest integer
//  params.switch_round="fix";truncate to integer nearest 0
//  params.switch_round=round only at key points"; round results only at important points
//--------------------------------------------------------------
   params.switch_round="floor"; // "floor","round", "fix","round only at key points"
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


   params.switch_structure="cascade-to-paralell";//"cascade","paralell","cascade-to-paralell"

//------------------------------------------------------------------------
// MAIN PROGRAM, DON'T CHANGE ANYTHING UNDER THIS LINE
//------------------------------------------------------------------------
//-------------------------------------------------------
// 4- GABARIT IN W PLANE ( PSEUDO-FREQUENCIES rad), DON'T CHANGE
//-------------------------------------------------------
  v0_aff=tan(%pi*f0_aff/fs);// pseudo-pulsation v0_aff corresponding to f0_aff
  v1_aff=tan(%pi*f1_aff/fs);// pseudo-pulsation v1_aff corresponding to f1_aff
//-------------------------------------------------------
// 4- COMPUTE corresponding CELS IN z and z^-1
//-------------------------------------------------------
  F_of_z=hornerij(F_of_w,w_of_z,"hd");// F(z) is a list
  F_of_z_1=hornerij(F_of_w,w_of_z_1,"ld");// F(z^-1) is a list
//------------------------------------
// compute filter and generate code
//------------------------------------
  exec("compute_filter.sce");
