MY_TRUE=%t; // merci scilab, compatibilite arriere de isfield...
global vhdl_glob;
vhdl_glob.name="vhdl global variables";
function init_vhdl_glob(params)
  global vhdl_glob;
  vhdl_glob.NAME_INPUT_LOGIC="ent";
  vhdl_glob.NAME_OUTPUT_LOGIC="sor";
  vhdl_glob.CLOCK_NAME="clk_50MHz";
  vhdl_glob.nb_process=0;
  vhdl_glob.name_process="z_";
  vhdl_glob.l_process=list();
  vhdl_glob.name="vhdl global variables";
  vhdl_glob.name_tmp="tmp_";
  vhdl_glob.nb_tmp=0;
  vhdl_glob.l_tmp=list();
  vhdl_glob.NB=params.NB_BITS;
  vhdl_glob.dbg=%f;
endfunction
function [s,name_out]=cod_vhdl_resize(name_in,NB_BITS,resize_if_unknown)
  [lhs,rhs]=argn(0);
  if (rhs<3) then
    resize_if_unknown=%t;
  end
  v_in=get_last_vhdl_var_named(name_in,%f);
  if (max(size(v_in))~=0) then
  // found v_in
    if (v_in.nb_bits==NB_BITS) then
      s="-- do not resize( "+name_in+" , "+string(NB_BITS)+" );";
      name_out=name_in;
      return
    end
    var_out=get_new_vhdl_var(NB_BITS);
    name_out= var_out.name;
    s= name_out+"<= resize( "+name_in+" , "+string(NB_BITS)+" );";
    return
  end
  //not found v_in
  if (resize_if_unknown==%t) then
    var_out=get_new_vhdl_var(NB_BITS);
    name_out= var_out.name;
    s= name_out+"<= resize( "+name_in+" , "+string(NB_BITS)+" );";
  else
      s="-- do not resize( "+name_in+" to "+string(NB_BITS)+", because it is not a signal";
      name_out=name_in;
      return
  end
endfunction
function output=compute_vhdl_filter(F_w,params)
  init_vhdl_glob(params);
// first convert F_w to list if necessary
  if (typeof(F_w)~="list") then
    tmp=list();
    tmp(1)=F_w;
    F_w=tmp;
  end

//--------------------------------------------------
// then verify if F_w is in the w plane, and convert it if necessary
//--------------------------------------------------
  vn=my_varn(F_w); // the name of var in polynomial
  w=poly(0,"w");
  if (vn=="z") then
    z_de_w=(1+w)/(1-w);
    F_w=hornerij(F_w,z_de_w,"hd") ;
  end
  if (vn=="z_1") then
    z_1_de_w=(1-w)/(1+w);
    F_w=hornerij(F_w,z_1_de_w,"hd") ;
  end
//--------------------------------------------------
// now set defaults parameters if necessary
//--------------------------------------------------
   [lhs,rhs]=argn(0);
   if (rhs<2) then
   // create default structure
     params=struct("file_name","toto");
   end
// get default value of fields if not given by unexperimented user
   if isfield(params,"file_name")~=MY_TRUE then
     params.file_name="toto"; // ne perdons pas les bonnes habitudes...
   end
   if isfield(params,"name_filter")~=MY_TRUE then
     params.name_filter="Fz";
   end
   if isfield(params,"switch_structure")~=MY_TRUE then
     params.switch_structure="cascade-to-paralell";//"cascade","paralell","cascade-to-paralell"
   end
   if isfield(params,"switch_operateur")~=MY_TRUE then
     params.switch_operateur="z_1"; // "x" ou "z_1"
   end
   if params.switch_operateur=="z" then
     params.switch_operateur="z_1"; 
   end
   if params.switch_operateur=="x" then
     if isfield(params,"switch_vx_ideal")~=MY_TRUE then
       params.switch_vx_ideal=%f;// works only for x operator
     end
   end 
   if isfield(params,"switch_round")~=MY_TRUE then
     params.switch_round="floor"; // "floor","round", "fix","round only at key points"
   end
   if isfield(params,"switch_saturate")~=MY_TRUE then
     params.switch_saturate="no saturate"; // "saturate","no saturate"
   end
   if isfield(params,"over_scale")~=MY_TRUE then
   // you can overscale input by this factor comparing to analysis
   // <=> first lbd=first lbd . overscale
   //     last  lbd=last lbd/over_scale
   // take care, you can generate overflow if youy use it!...
     params.over_scale=1;
   end
   if isfield(params,"i_norm_scaling")~=MY_TRUE then
     params.i_norm_scaling=%inf; // 1, 2 or %inf
   end
   if isfield(params,"i_norm_analysis")~=MY_TRUE then
     params.i_norm_analysis=2;// 1, 2 or %inf
   end
   if isfield(params,"NBECHS_NORM")~=MY_TRUE then
   // Nb sample for norm 1,norm 2 and norm inf computation
     params.NBECHS_NORM=compute_NBECH_Fw(F_w);
     MAX_NBECHS_NORM=1000000;
     if (params.NBECHS_NORM>MAX_NBECHS_NORM) then
        disp("WARNING in function functions_gene_vhdl->compute_vhdl_filter");
        disp("  theoretical NBECH for norm computation is "+string(params.NBECHS_NORM));
        disp("  automatically limited to "+string(MAX_NBECHS_NORM));
        params.NBECHS_NORM=MAX_NBECHS_NORM;
     end
   end
   NBECHS_NORM=params.NBECHS_NORM;
   if isfield(params,"NB_BITS")~=MY_TRUE then
     params.NB_BITS=16;
   end
   if isfield(params,"verbose")~=MY_TRUE then
     params.verbose=%t; // %t for verbose or %f for silent computation
   end
   if isfield(params,"switch_quantifie")~=MY_TRUE then
     params.switch_quantifie=%t;
   end
   if isfield(params,"switch_form")~=MY_TRUE then
     params.switch_form="df2";// "df1","df1t","df2","df2t","state-space"
   end
   if params.switch_form=="state-space" then

     if isfield(params,"switch_ss")~=MY_TRUE then
       params.switch_ss="hwang";//"hwang", 'normal' type of state-space representation used
     end
   end
   if isfield(params,"type_allpass")~=MY_TRUE then
     params.type_allpass='M'; // 'J','M' or 'Q' , but unused for instance
   end
   if isfield(params,"switch_sort")~=MY_TRUE then
     params.switch_sort=[]; //[],"well damped first","bad damped first"
   end
   if isfield(params,"switch_use_power_of_2")~=MY_TRUE then
     params.switch_use_power_of_2=%t; // use scaling in integer power of 2
   end

   w=poly(0,'w');
   x=poly(0,"x");
   x_1=poly(0,"x_1");
   x_de_x_1=1/x_1;
   moins_w=-w;
   z=poly(0,'z');
   w_de_z=(z-1)/(z+1);
   z_de_w=(1+w)/(1-w);
   i_inf=0;infos_=list();
     i_inf=i_inf+1;infos_(i_inf)=("-----analysis of filter :"+params.name_filter+"-------------");
   if (params.switch_form=="state-space")&(params.switch_operateur=="x")&(params.switch_ss~="hwang") then
     disp(" WARNING");
     disp("  state-space forms of type:"+params.switch_form+" can only be used with z_1 operator");
     disp("  automatically changing params.switch_operateur to z_1");
     params.switch_operateur="z_1";
   end
   i_inf=i_inf+1;infos_(i_inf)=("op="+params.switch_operateur+",form :"+params.switch_form+" programmed as "+params.switch_structure);
   i_inf=i_inf+1;infos_(i_inf)=("scaling norm="+string(params.i_norm_scaling)+",analysis norm="+string(params.i_norm_analysis));
// creation de output_, de type structure contenant le champ infos
  output_=struct("infos",infos_);
// creation des autres champs de sortie
  output_.F_w=F_w;
  output_.F_z=hornerij(output_.F_w,w_de_z,"hd");
  if (params.switch_structure=="cascade") then
    output_.F_z_casc_ideal=output_.F_z;
  elseif (params.switch_structure=="cascade-to-paralell") then
    output_.F_z_casc_ideal=output_.F_z;
    output_.F_w_casc_ideal=F_w;
    [K_inf,output_.F_z]=my__parfrac(output_.F_z);
    l=list();
    l(1)=real(K_inf);
    output_.F_z=lstcat(l,output_.F_z);
    output_.F_w=hornerij(output_.F_z,z_de_w,"hd");
    osm=simp_mode();
    simp_mode(%f);
    for i=1:length(output_.F_w),
      output_.F_w(i)=real(numer(output_.F_w(i)))/real(denom(output_.F_w(i)));
      output_.F_z(i)=real(numer(output_.F_z(i)))/real(denom(output_.F_z(i)));
    end 
    simp_mode(osm);
  elseif (params.switch_structure=="paralell") then
    output_.F_z=hornerij(F_w,w_de_z,"hd");
    output_.F_w=hornerij(output_.F_z,z_de_w,"hd");
  else
    error("bad params.switch_structure:"+params.switch_structure);
  end
  if (params.switch_sort~=[]) then
    [output_.F_w,output_.infos_roots]=sort_filter(output_.F_w,params.switch_sort);
  end
  output_.params=params;
  lambda_glob=1; // scaling factor
//---------------------------------------------
// compute direct form transferts
//---------------------------------------------
  NFES_z=list();
  DFES_z=list();
  if (params.switch_operateur=="z_1") then
    b0x_de_z=1;
    a0x_de_z=0;
 // Fq(z)=(b0Fqz+b1Fqz.z)/(a0Fqz+a1Fqz.z)=(z-1)/(z-(1-2-Lop))
    b1Fqz=0;b0Fqz=0;
    a1Fqz=0;a0Fqz=1;
    x_de_w=(1-w)/(1+w);
    w_de_x=horner11_inv(x_de_w,"x");
  end
  F_x=list();
  F_xq=list();
  v_x=list();
  F_z_qtf=list();
  cel_qtf=list(); // structures defining quantified cels
  for i_f=1:length(output_.F_w),
  // ieme cel = structure with name cel(indice of cel)
     cel_i=struct("name","cel("+string(i_f)+")");
     Fwi=output_.F_w(i_f);
     Nwi=numer(Fwi);
     Dwi=denom(Fwi);
     pw=roots(Dwi);
     b0w=coeff(Nwi,0);
     b1w=coeff(Nwi,1);
     b2w=coeff(Nwi,2);
     a0w=coeff(Dwi,0);
     a1w=coeff(Dwi,1);
     a2w=coeff(Dwi,2);
  // compute operator x if necessary 
     vx_i=1;
     if params.switch_operateur=="x" then
        vn=abs(pw(1));
        vx_i=compute_vx(vn,params.switch_vx_ideal);
        if (vx_i<=1) then
        // low frequency gain normalised to 1
          x_de_w=(1-w)/(1+w/vx_i);
        else
        // high frequency gain normalised to -1
          x_de_w=(1-w)/(vx_i+w);
        end
        w_de_x=horner11_inv(x_de_w,"x");
        X=x;
        w_de_X=w_de_x;
        X_de_z=hornerij(x_de_w,w_de_z);
     // X(z)=b0Fxz/(z+a0Fxz)
        d1_X=coeff(denom(X_de_z),1);
        X_de_z=(numer(X_de_z)/d1_X)/(denom(X_de_z)/d1_X);
        b0x_de_z=coeff(numer(X_de_z),0);
        a0x_de_z=coeff(denom(X_de_z),0);
     // Fq(z)=(b0Fqz+b1Fqz.z)/(a0Fqz+a1Fqz.z)=(z-1)/(z+a0x_de_z)
        b1Fqz=1;b0Fqz=sign(a0x_de_z);
        a1Fqz=1;a0Fqz=a0x_de_z;
     //   b1Fqz=0;b0Fqz=0;a1Fqz=0;a0Fqz=1;
     end // if params.switch_operateur=="x"
   // compute transfer function in X, works in x and in z_1
     [b0X,b1X,b2X,a0X,a1X,a2X]=clc_Fx_de_Fw(b0w,b1w,b2w,a0w,a1w,a2w..
       ,b0x_de_z,a0x_de_z);
     b0X=b0X/a0X;
     b1X=b1X/a0X;
     b2X=b2X/a0X;
     a1X=a1X/a0X;
     a2X=a2X/a0X;
     a0X=1;
     osm=simp_mode();
     simp_mode(%f);
     F_x(i_f)=(b0X+b1X*x+b2X*x^2)/(1+a1X*x+a2X*x^2);
     Nxi=numer(F_x(i_f));
     Dxi=denom(F_x(i_f));
     simp_mode(osm);
   // now compute filter implementation in x
     if (params.switch_form=="state-space") then
     // state-space form
       Fxi=hornerij(Fwi,w_de_x,"ld");
       Fx_1i=hornerij(Fxi,x_de_x_1,"hd"); 
       Nx_1i=numer(Fx_1i);
       Dx_1i=denom(Fx_1i);
       degre_i=degree(Dx_1i);
       if (degre_i>0) then
         sys_abcdi=syslin(1,Nx_1i,Dx_1i);
         sys_abcdi=tf2ss(sys_abcdi);
         if params.switch_ss=="hwang" then
           sys_ssi=hwang_optimal_ss(sys_abcdi,a0x_de_z);
         elseif params.switch_ss=='normal' then
           sys_ssi=normal_optimal_ss(sys_abcdi);
         else
           error("sys_ss="+params.switch_ss+" not implemented");
         end
         cel_i=get_scaled_ss(sys_ssi,params.NB_BITS);
         if (params.switch_quantifie==%t) then
           sys_ssi=cel_i.sys_ss_q;
         end
         cel_i.a0x_de_z=a0x_de_z;
         cel_i.sys_ssx_1=sys_ssi;
         [NFES_zi,DFES_zi,NFES_wi,DFES_wi,NFES_z_1i,DFES_z_1i]=clc_ss(lambda_glob,..
             sys_ssi.A,sys_ssi.B,sys_ssi.C,sys_ssi.D,cel_i.a0x_de_z);
        else
       // degree=0 => no states, just a pure gain, program it as you want
         cel_i=get_scaled_direct_form(b0X,"df2",params.NB_BITS);
         cel_i.b0x_de_z=1;// useful for code generation
         cel_i.a0x_de_z=0;
         if (params.switch_quantifie==%t) then
           b0X=coeff(numer(cel_i.Fx_q),0);
         end
         [NFES_zi,DFES_zi,NFES_wi,DFES_wi,NFES_z_1i,DFES_z_1i]=clc_direct_form("df2",lambda_glob,..
           b0X,0,0,0,0,..
           0,0,1,0,..
           cel_i.b0x_de_z,cel_i.a0x_de_z);
         NFES_z(i_f)=NFES_zi;
         DFES_z(i_f)=DFES_zi;
       end // end of degree 0
     // end of state-space forms
     else
     // df1,df1t,df2,df2t forms
       osm=simp_mode();
       simp_mode(%f);
       F_x(i_f)=(b0X+b1X*x+b2X*x^2)/(1+a1X*x+a2X*x^2);
       F_xi=(b0X+b1X*x+b2X*x^2)/(1+a1X*x+a2X*x^2);
       cel_i=get_scaled_direct_form(F_xi,params.switch_form,params.NB_BITS);
       ci=cel_i;
       ci.b0x_de_z=b0x_de_z;// useful for code generation
       ci.a0x_de_z=a0x_de_z;
       cel_i=ci;
       if (params.switch_quantifie==%t) then
         F_xq(i_f)=cel_i.Fx_q;
       else
         F_xq(i_f)=F_x(i_f);
       end
       b0X=coeff(numer(F_xq(i_f)),0);
       b1X=coeff(numer(F_xq(i_f)),1);
       b2X=coeff(numer(F_xq(i_f)),2);
       a0X=coeff(denom(F_xq(i_f)),0);
       a1X=coeff(denom(F_xq(i_f)),1);
       a2X=coeff(denom(F_xq(i_f)),2);
       v_x(i_f)=vx_i;
       simp_mode(osm);
       [NFES_zi,DFES_zi,NFES_wi,DFES_wi,NFES_z_1i,DFES_z_1i]=clc_direct_form(params.switch_form,lambda_glob,..
         b0X,b1X,b2X,a1X,a2X,..
         b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
         b0x_de_z,a0x_de_z);
     end
     NFES_z(i_f)=NFES_zi;
     DFES_z(i_f)=DFES_zi;
     osm=simp_mode();
     simp_mode(%f);
     cel_i.NFES_z=NFES_zi;
     cel_i.DFES_z=DFES_zi;
     cel_i.F_z_qtf=NFES_zi(1)(1)/DFES_zi(1)(1);
     F_z_qtf(i_f)=NFES_zi(1)(1)/DFES_zi(1)(1);
     simp_mode(osm);
     cel_qtf(i_f)=cel_i;
  end
  output_.F_z_qtf=F_z_qtf;
  if (length(cel_qtf)==1) then
  // scilab, or unfixed, bug !...
  //  if cel_qtf has only one element
  //  then scilab is unable to display output
  // so in this case add another element to cel_qtf
  // i've not found another way to solve the problem
    cel_qtf(length(cel_qtf)+1)=[];
  end
  output_.cel_qtf=cel_qtf;
  output_.NB_CELS=length(output_.F_w);
//-----------------------------------------------------------
// analyse des caracteristiques
//-----------------------------------------------------------

  params=output_.params;
  params.is_paralell=strindex(params.switch_structure,"paralell")>0==%t;
  if (params.is_paralell) then
    type_Fq="paralell";
  else
    type_Fq="cascade";
  end
  output_.type_of_F_z_qtf=type_Fq;
  norme_F_1=norme_Fz(F_z_qtf,type_Fq,1,NBECHS_NORM);
  norme_F_2=norme_Fz(F_z_qtf,type_Fq,2,NBECHS_NORM);
  norme_F_Hinf=norme_Fz(F_z_qtf,type_Fq,%inf,NBECHS_NORM);
  max_e=2^(params.NB_BITS-1);
  max_val_eff_e=max_e; // suppose egal au maximum de l'entree dans le pire des cas
  ecart_type_e=(2*max_e)*sqrt(1/12); // ecart-type de e, si bruit blanc
  output_levels.max_module_s=norme_F_1*max_e;
  output_levels.max_val_eff_s=norme_F_Hinf*max_val_eff_e;
  output_levels.ecart_type_s=norme_F_2*ecart_type_e;
  output_.output_levels=output_levels;
  output_.norme1_Fz_qtf=norme_F_1;
  output_.norme2_Fz_qtf=norme_F_2;
  output_.normeHinf_Fz_qtf=norme_F_Hinf;
  output_.params=params;
  if (params.is_paralell==%f) then
    [output_.lambda,output_.max_x_e,output_.norm_sb]=scale_cels(NFES_z,DFES_z,params.NBECHS_NORM,params.i_norm_scaling,params.i_norm_analysis,params.switch_use_power_of_2);
  else
  // special treatment for paralell forms
    lN=list();lD=list();
    output_.lambda=list();
    output_.max_x_e=list();
    output_.norm_sb=[];
    for i_f=1:output_.NB_CELS,
      cel_i=output_.cel_qtf(i_f);
      lN(1)=cel_i.NFES_z;
      lD(1)=cel_i.DFES_z;
      [li,mxei,nsbi]=scale_cels(lN,lD,params.NBECHS_NORM,params.i_norm_scaling,params.i_norm_analysis,params.switch_use_power_of_2);
      output_.lambda(i_f)=li;
      output_.max_x_e(i_f)=mxei;
      output_.norm_sb=[output_.norm_sb;nsbi];
    end
  end
  if (params.i_norm_analysis)~=1 then
    output_.output_noise=norm(output_.norm_sb,2)
  else
    output_.output_noise=norm(output_.norm_sb,1)
  end
  output=output_;
endfunction
function l=get_vhdl_standard_define(NB_BITS,name_struct)
    l=list();i=0;
    i=i+1;l(i)="----------------------------------------------------------------------------------";
    i=i+1;l(i)="-- Company: Universite Bordeaux 1 departement EEA";
    i=i+1;l(i)="-- Engineer: Autogenerated code ";
    i=i+1;l(i)="--";
    i=i+1;l(i)="-- Create Date:    ";
    i=i+1;l(i)="-- Design Name:";
    i=i+1;l(i)="-- Module Name:    "+name_struct+" - Behavioral";
    i=i+1;l(i)="-- Project Name:";
    i=i+1;l(i)="-- Target Devices:";
    i=i+1;l(i)="-- Tool versions:";
    i=i+1;l(i)="-- Description:";
    i=i+1;l(i)="----------------------------------------------------------------------------------";
    i=i+1;l(i)="library IEEE;";
    i=i+1;l(i)="use IEEE.STD_LOGIC_1164.ALL;";
    i=i+1;l(i)="use IEEE.numeric_std.ALL;-- use signed numbers for numerical computations";

    i=i+1;l(i)="entity "+name_struct+" is";
    i=i+1;l(i)="Port ( "+vhdl_glob.NAME_INPUT_LOGIC+"       : in   STD_LOGIC_VECTOR ("+string(NB_BITS-1)+" downto 0);	--N="+string(NB_BITS)+" bits";
    i=i+1;l(i)="       "+vhdl_glob.NAME_OUTPUT_LOGIC+"       : out  STD_LOGIC_VECTOR ("+string(NB_BITS-1)+" downto 0);	--N="+string(NB_BITS)+" bits";
    i=i+1;l(i)="       clk_50MHz : in std_logic ;";
    i=i+1;l(i)="       f_ech     : in std_logic);";
    i=i+1;l(i)="end "+name_struct+";";
    l_define=l;
endfunction
function new_code=append_filter_to_vhdl(old_code,output)
  format(20);//use 20 decimals numbers for writing old_code
  new_code=old_code;
  if (length(output.cel_qtf)<=0) then
    return;
  end
  cel_qtf=list();k=0;
  l=length(output.cel_qtf);
  for i=1:l,
    ci=output.cel_qtf(i);
    ok=typeof(ci)~="constant";
    if (ok) then
      k=k+1;cel_qtf(k)=ci;
    end
  end
  if isfield(old_code,"int_code")~=MY_TRUE then
    name=list();
    int_code.name=name;
    int_code.specif=list();
    float_code.name=name;
    float_code.specif=list();
    int_code.ALL_NB_BITS=[];
  else
   int_code=old_code.int_code;
   float_code=old_code.float_code;
  end
  params=output.params;
  n= params.NB_BITS;
  i=find(int_code.ALL_NB_BITS==n);
  if (i==[]) then
    int_code.ALL_NB_BITS=[int_code.ALL_NB_BITS;n];
  end
  ic=length(int_code.name);ic=ic+1;
  int_code.name(ic)="integer "+string(n)+"/"+string(2*n)+" bits code  of filter "+params.name_filter;
// overscale is dangerous, just used for testing purpose
  lambda_overscale=output.lambda;
  l=length(lambda_overscale);
  if (params.is_paralell==%f) then
  // cascade cels
    lambda_overscale(1)=lambda_overscale(1)*params.over_scale;
    lambda_overscale(l)=lambda_overscale(l)/params.over_scale;
    [l_ini_coeffs,l_one_step,l_define]=get_casc_vhdl_code(lambda_overscale,cel_qtf,params.name_filter,params.switch_round,params.switch_saturate);
  else
  // paralell cels
    for i=1:l,
      cel_qtf(i).NB_BITS=params.NB_BITS;
      lambda_overscale(i)(1)=lambda_overscale(i)(1)*params.over_scale;
      lambda_overscale(i)(2)=lambda_overscale(i)(2)/params.over_scale;
    end
  //  cel_qtf(i).NB_BITS= params.NB_BITS;
    [l_ini_coeffs,l_one_step,l_define]=get_parl_vhdl_filter(lambda_overscale,cel_qtf,params.name_filter,params.switch_round,params.switch_saturate);
    
  end
  int_code.specif(ic)=lstcat(l_ini_coeffs,l_one_step);
  l=genere_declar_vhdl();
  l_define=lstcat(l_define,l);
  int_code.l_define=l_define;
// generate global integer code
  int_code.all_code=list();
  for i=1:length(int_code.specif),
    int_code.all_code=lstcat(int_code.all_code,int_code.specif(i));
  end
// floating point ideal old_code
  float_code.name(ic)="double precision code of filter "+params.name_filter;
  is_paralell=output.params.is_paralell;
  [l_specif,l_define]=get_ideal_c_code(output.F_z,params.name_filter,is_paralell);
  if isfield(float_code,"common_code")~=MY_TRUE then
    float_code.l_define=l_define;
  end
  float_code.specif(ic)=l_specif;
// generate global floating point code
  float_code.all_code=list();
  for i=1:length(float_code.specif),
    float_code.all_code=lstcat(float_code.all_code,float_code.specif(i));
  end
  all_code=lstcat(int_code.l_define,float_code.l_define);
  all_code=lstcat(all_code,int_code.all_code);
  all_code=lstcat(all_code,float_code.all_code);
  new_code.all_code=all_code;
  int_code.all_code=lstcat(int_code.l_define,int_code.all_code);
  ic=length(int_code.all_code);
  ic=ic+1;int_code.all_code(ic)="end Behavioral;";
  new_code.int_code=int_code;
  float_code.all_code=lstcat(float_code.l_define,float_code.all_code);
  new_code.float_code=float_code;
endfunction
function s=get_vhdl_string_00(nb)
 s="";
 for i=1:nb,
   s=s+"0";
 end
 s=s+"'"";
 s="'""+s;

endfunction
function l=get_vhdl_declar_vars(lv)
  tab_nb=[];
  tab_NB_vi=[];
  tab_name_vi=[];
  l=list();il=0;
  for i=1:length(lv),
    vi=lv(i);
    i=find(vi.nb_bits==tab_nb);
    tab_name_vi=[tab_name_vi;vi.name];
    tab_NB_vi=[tab_NB_vi;vi.nb_bits];
    if max(size(i))==0 then
      tab_nb=[tab_nb,vi.nb_bits];
    end
  end
  tab_nb=gsort(tab_nb,"g","i");
  for i=1:length(tab_nb),
    nb_i=tab_nb(i);
    j=find(tab_NB_vi==nb_i);
    names_vars=tab_name_vi(j);
    iv=1;
    nb_var=max(size(names_vars));
    for k=1:nb_var,
      if iv==1 then
        s=" signal "+names_vars(k);
      else
        s=s+", "+names_vars(k);
      end
      if ((iv== 10) | (k==nb_var)) then
         s=s+" : signed ("+string(nb_i-1)+" downto 0) := " +get_vhdl_string_00(nb_i) + ";-- signaux intermediaires sur "+string(nb_i)+" bits,  niveau 0"; 
         iv=0;
         il=il+1;l(il)=s;
      end
      iv=iv+1;
    end
  //  s=s+" : signed ("+string(nb_i-1)+" downto 0) := " +get_vhdl_string_00(nb_i) + ";-- signaux intermediaires sur "+string(nb_i)+" bits,  niveau 0";
   end
  
endfunction
function l=genere_declar_vhdl()
  l=list();il=0;
  il=il+1;l(il)="architecture Behavioral of RII_exemple is"
  l_vars=get_vhdl_declar_vars(vhdl_glob.l_tmp);
//   signal ent_s, sor_s : signed(7 downto 0);-- echantillons d'entree et de sortie en nombres signes sur N bits
//   -- l'initialisation des signaux ci-dessous e 0 n'est utile qu'en simulation
//   signal e0, ed0, som10, som0, sd0 : signed (15 downto 0) := "0000000000000000" ;-- signaux intermediaires sur 2N bits,  niveau 0
//   signal e1, ed1, som21, som1, sd1, s1 : signed (15 downto 0):= "0000000000000000" ;--  signaux intermediaires sur 2N bits,  niveau 0
//   signal e2, ed2, som32, som2, sd2, s2 : signed (15 downto 0):= "0000000000000000" ;-- signaux intermediaires sur 2N bits,  niveau 0
  l=lstcat(l,l_vars);il=length(l);
  s="begin";
  il=il+1;l(il)=s;
endfunction
function nx=get_nb_states(cel)
  nx=cel.degre;
endfunction 
function nc=get_nb_coeffs(cel)
  if (cel.forme=="df1") then
    nc=(cel.degre+1)+(cel.degre);
    return
  end
  if (cel.forme=="df1t") then
    nc=(cel.degre+1)+(cel.degre);
    return
  end
  if (cel.forme=="df2") then
    nc=(cel.degre+1)+(cel.degre);
    return
  end
  if (cel.forme=="df2t") then
    nc=(cel.degre+1)+(cel.degre);
    return
  end
  if (cel.forme=="ss") then
    nc=(cel.degre^2)+2*(cel.degre)+1;
    return
  end
  error("not yet implemented for cel of type :"+cel.forme);
endfunction
function [l_out,s_struct,p_name_struct]=vhdl_append_declar_to_l(l)
  s_NB_BITS=string(NB_BITS);
  s_2NB_BITS=string(2*NB_BITS);
  s_name_struct="--unused s_"+s_NB_BITS+"bits_"+"filter_"+name_struct;
  p_name_struct="-- unused p_"+s_NB_BITS+"bits_"+"filter_"+name_struct;
  i=length(l);
  s_struct="-- unused p_"+name_struct;
  l_out=l;
endfunction
function [l_ini,l_cod,l_define]=get_parl_vhdl_filter(lbds,cels,name_struct,switch_round,switch_saturate)
  [lhs,rhs]=argn(0);
  if (rhs<4) then
    switch_round="floor";
  end
  if (rhs<5) then
    switch_saturate="no saturate";
  end
  if switch_round=="round only at key points" then
    switch_round_std="floor";
    switch_round_key="round";
  else 
    switch_round_std=switch_round;
    switch_round_key=switch_round;
  end
  if (length(cels)>0) then
    NB_BITS=cels(1).NB_BITS;
    name_tmp_2N="tmp_"+string(2*NB_BITS);
  end

  s_int16="int_"+string(NB_BITS)+"_"+name_struct;
  s_int32="int_"+string(2*NB_BITS)+"_"+name_struct;
  en_32="en_"+string(2*NB_BITS);
  sn_32="sn_"+string(2*NB_BITS);
  en_16="en_"+string(NB_BITS);
  x1="x1_"+string(NB_BITS);
  x2="x2_"+string(NB_BITS);
  vn="vn_"+string(NB_BITS);
  lbd_in=1;
  l_ini=list();
  nb_states=0;
  nb_coeffs=0;
  max_deg=0;
// pass 1 get individual codes and output scalings 
  l_cod_i=list();
  lbd_out_i=[];
  need_acc_x=%f;
  en_16=get_new_vhdl_var(vhdl_glob.NB);
  l_debut_cod=list();i_cod=0;
  i_cod=i_cod+1;l_debut_cod(i_cod)="---------------------------------------------------------------------------------------------------------------";
  i_cod=i_cod+1;l_debut_cod(i_cod)="-- begin of filter : convert "+string(NB_BITS)+" bits logic input :"+vhdl_glob.NAME_INPUT_LOGIC+ ", to signed equivalent :"+en_16.name;
  i_cod=i_cod+1;l_debut_cod(i_cod)="---------------------------------------------------------------------------------------------------------------------";
  i_cod=i_cod+1;l_debut_cod(i_cod)=en_16.name+" <= signed("+vhdl_glob.NAME_INPUT_LOGIC+");";
  [s,en_16]=cod_vhdl_resize(en_16.name,2*vhdl_glob.NB);
  en_16= get_last_vhdl_var_named(en_16);
   i_cod=i_cod+1;l_debut_cod(i_cod)=s;
  l_cod=list();i_cod=0;
  l_var_out=list();
  for i=1:length(cels),
    celi=cels(i);
    celi.switch_round=switch_round;
    celi.switch_saturate=switch_saturate;
    max_deg=max([max_deg,celi.degre]);
    nb_states=nb_states+get_nb_states(celi);
    nb_coeffs=nb_coeffs+get_nb_coeffs(celi);
    lbd_in=lbds(i)(1);
    l_cod=list();
    i_cod=length(l_cod);
    i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------";
    i_cod=i_cod+1;l_cod(i_cod)="-- code of cel "+string(i);
    i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------";
    gain_is_0=(celi.degre==0);
    if gain_is_0 then
      gain_is_0=abs(celi.Bi_int)*2^(-celi.LB) <=1/2^(NB_BITS-1);
    end
    if gain_is_0 then
    //  [lbd_out,l_initi,l_codi]=get_vhdl_cel_code(lbd_in,celi,name_struct,i,en_16.name);
      l_var_out(i)=get_last_vhdl_output_var();
      lbd_out_i=[lbd_out_i;-%inf];
      l_codi=list("--  no generated code because cel "+string(i)+" has zero gain");
      l_cod=lstcat(l_cod,l_codi);
      l_cod_i(i)=l_cod;
    else
      [lbd_out,l_initi,l_codi]=get_vhdl_cel_code(lbd_in,celi,name_struct,i,en_16.name);
      l_var_out(i)=get_last_vhdl_output_var();
      lbd_out_i=[lbd_out_i;lbd_out*lbds(i)(2)];
      l_cod=lstcat(l_cod,l_codi);
      l_cod_i(i)=l_cod;
      i_ini=length(l_ini);
    //  i_ini=i_ini+1;l_ini(i_ini)="-- init of cel "+string(i)+" ";
      l_ini=lstcat(l_ini,l_initi);
    end
    if (celi.forme=="ss")&(cels(i).degre>0) then
      need_acc_x=%t;
    end
  end
// get global output scaling
  l_out_glob=max(lbd_out_i);
  l_out_glob=max([l_out_glob]);
  lbd_out_i=lbd_out_i/l_out_glob;
// pass 2 : scale output of each cel
  l_cod=list();
  output_is_init=%f;
  for i=1:length(cels),
    l_codi=l_cod_i(i);
    lbd_out=lbd_out_i(i);
    if (lbd_out~=-%inf) then
      name_out_i=l_var_out(i).name;
      [li,scaled_i]=cod_vhdl_shift_rnd(name_out_i,round(log2(lbd_out)),2*NB_BITS,switch_round_std);
      li(1)=li(1)+" -- scale output of cel "+string(i)+"";
      l_codi=lstcat(l_codi,li);i_codi=length(l_codi);
      if (output_is_init==%f) then
	name_out_glob=scaled_i;
	output_is_init=%t
	s="-- local output :"+name_out_glob+" of cel "+string(i)+" will be accumulated";
	i_codi=i_codi+1;l_codi(i_codi)=s;
      else
	s="-- accumulation of output: "+scaled_i+" of cel "+string(i)+" with local output: "+name_out_glob;
	i_codi=i_codi+1;l_codi(i_codi)=s;
	[lad,name_out_glob]=cod_vhdl_addition(name_out_glob,scaled_i,2*NB_BITS);
	l_codi=lstcat(l_codi,lad);i_codi=length(l_codi);
      end

    else
      i_codi=length(l_codi);
      i_codi=i_codi+1;l_codi(i_codi)="-- no accumulation because cel "+string(i)+" has zero gain ";
    end
    l_cod_i(i)=l_codi;
    l_cod=lstcat(l_cod,l_cod_i(i));
  end
// pass 3 : scale global output
  i_cod=length(l_cod);
  s="----------------------------------------------------------";
  i_cod=i_cod+1;l_cod(i_cod)=s;
  s="-- end of filter, scale global output : "+name_out_glob;
  i_cod=i_cod+1;l_cod(i_cod)=s;
  s="----------------------------------------------------------";
  i_cod=i_cod+1;l_cod(i_cod)=s;
  [li,sn_32]=cod_vhdl_shift_rnd(name_out_glob,round(log2(l_out_glob)),2*NB_BITS,switch_round_key);
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  li=cod_vhdl_satur(sn_32,sn_32,NB_BITS,switch_saturate);
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  // transmission of gloabal output
  i_cod=length(l_cod);
  last_output=sn_32;
  global_output=get_new_vhdl_var(NB_BITS,"output_"+string(NB_BITS));
  set_last_vhdl_var_fd_val("is_output",%t);
  lcv=cod_vhdl_convert(global_output.name,last_output,NB_BITS);
  l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
  i_cod=i_cod+1;l_cod(i_cod)=vhdl_glob.NAME_OUTPUT_LOGIC+" <= std_logic_vector("+global_output.name+");";

  if (lhs==3) then
    l=get_vhdl_standard_define(NB_BITS,name_struct);
    i=length(l);
    l_define=l;
  end
// entete of l_ini
  s_NB_BITS=string(NB_BITS);
  l=list();
  [l,s_struct,p_name_struct]=vhdl_append_declar_to_l(l);
  i=length(l);
  l_ini=lstcat(l);
  l_ini=ident_list(l_ini,"  ");
// entete of l_cod
  l_cod=lstcat(l_debut_cod,l_cod);
  l_cod=ident_list(l_cod,"  ");
  l_test=get_vhdl_test_code();
  l_cod=lstcat(l_cod,l_test);
  l_cod=ident_list(l_cod,"  ");

endfunction
function [l,n_out]=cod_vhdl_satur(out,in,NB_BITS,switch_saturate)
  [lhs,rhs]=argn(0);
  l=list();il=0;
  if (switch_saturate~="saturate") then
     if (out==in) then
     // nothing to do 
       return;
     end
     il=il+1;l(il)=cod_vhdl_affect(out,in,NB_BITS);
     return  
  end
  if (switch_saturate=="saturate") then
    max_int=2^(NB_BITS-1)-1;max_int=string(max_int);
    min_int=-2^(NB_BITS-1);min_int=string(min_int);
  end
  if (out==in) then
    NB_BITS=-1;
  end
  il=il+1;l(il)="-- "+out+" <- "+in+" saturated between["+max_int+","+min_int+"] ";
  il=il+1;l(il)="if ("+in+">"+max_int+") {";
     il=il+1;l(il)="  "+cod_vhdl_affect(out,max_int,-1);
  il=il+1;l(il)="} else if ("+in+"<"+min_int+") {";
     il=il+1;l(il)="  "+cod_vhdl_affect(out,min_int,-1);
  il=il+1;l(il)="}";
  if (out~=in) then
  // no saturation, result in strupid code : out=out; if name input = name output
    il=il+1;l(il)="else {";
    il=il+1;l(il)="  "+cod_vhdl_affect(out,in,NB_BITS);
    il=il+1;l(il)="}";
  end 
endfunction
function ld=get_vhdl_test_code()
    ld=list();id=0;
endfunction
function [l_ini,l_cod,l_define]=get_casc_vhdl_code(lbds,cels,name_struct,switch_round,switch_saturate)
  [lhs,rhs]=argn(0);
  if (rhs<4) then
    switch_round="floor";
  end
  if (rhs<5) then
    switch_saturate="no saturate";
  end
  if switch_round=="round only at key points" then
    switch_round_std="floor";
    switch_round_key="round";
  else 
    switch_round_std=switch_round;
    switch_round_key=switch_round;
  end
  if (length(cels)>0) then
    NB_BITS=cels(1).NB_BITS;
    name_tmp_2N="tmp_"+string(2*NB_BITS);
  end
  s_NB_BITS=string(NB_BITS);
  lbd_in=1;
  l_cod=list();i_cod=0;
  l_ini=list();
  nb_states=0;
  nb_coeffs=0;
  max_deg=0;
  need_acc_x=%f;
  
  en=get_new_vhdl_var(vhdl_glob.NB);
  
  i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------------------------------------------------------------------------";
  i_cod=i_cod+1;l_cod(i_cod)="-- begin of filter : convert "+string(NB_BITS)+" bits logic input :"+vhdl_glob.NAME_INPUT_LOGIC+ ", to signed equivalent :"+en.name;
  i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------------------------------------------------------------------------------";
  i_cod=i_cod+1;l_cod(i_cod)=en.name+" <= signed("+vhdl_glob.NAME_INPUT_LOGIC+");";
  [s,en_name]=cod_vhdl_resize(en.name,2*vhdl_glob.NB);
  en= get_last_vhdl_var_named(en_name);
  set_last_vhdl_var_fd_val("is_output",%t);
  i_cod=i_cod+1;l_cod(i_cod)=s;
  for i=1:length(cels),
    celi=cels(i);

    if (celi.forme=="ss")&(cels(i).degre>0) then
      need_acc_x=%t;
    end
    celi.switch_round=switch_round;
    celi.switch_saturate=switch_saturate;
    max_deg=max([max_deg,celi.degre]);
    nb_states=nb_states+get_nb_states(celi);
    nb_coeffs=nb_coeffs+get_nb_coeffs(celi);

    lbd_in=lbd_in*lbds(i);
    i_cod=length(l_cod);
    i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------";
    i_cod=i_cod+1;l_cod(i_cod)="-- code of cel "+string(i);
    i_cod=i_cod+1;l_cod(i_cod)="---------------------------------------------";
    [lbd_out,l_initi,l_codi]=get_vhdl_cel_code(lbd_in,celi,name_struct,i);

    l_cod=lstcat(l_cod,l_codi);
    i_ini=length(l_ini);
  //  i_ini=i_ini+1;l_ini(i_ini)="-- init of cel "+string(i)+" ";
    l_ini=lstcat(l_ini,l_initi);
    lbd_in=lbd_out;
  end
  i=length(cels)+1;
  lbd_in=lbd_in*lbds(i);
  s_int16="int_"+string(NB_BITS);
  s_int32="int_"+string(2*NB_BITS);

  if (lhs==3) then
    l=get_vhdl_standard_define(NB_BITS,name_struct);
    i=length(l);
    l_define=l;
  end
  i_cod=length(l_cod);
  i_cod=i_cod+1;l_cod(i_cod)="--------------------------------------";
  i_cod=i_cod+1;l_cod(i_cod)="-- end of filter : scale global output";
  i_cod=i_cod+1;l_cod(i_cod)="--------------------------------------";
  last_output=get_last_vhdl_output_var();
  [li,en]=cod_vhdl_shift_rnd(last_output.name,round(log2(lbd_in)),2*NB_BITS,switch_round_key);
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  li=cod_vhdl_satur(en,en,NB_BITS,switch_saturate);
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  global_output=get_new_vhdl_var(NB_BITS,"output_"+string(NB_BITS));
  set_last_vhdl_var_fd_val("is_output",%t);
  lcv=cod_vhdl_convert(global_output.name,en,NB_BITS);
  l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
  i_cod=i_cod+1;l_cod(i_cod)=vhdl_glob.NAME_OUTPUT_LOGIC+" <= std_logic_vector("+global_output.name+");";
// entete of l_ini
  //l_ini=ident_list(l_ini,"  ");
  l=list();i=0;
  //i=i+1;l(i)="const "+s_int16+" coeffs_"+s_NB_BITS+"bits_"+name_struct+"["+string(nb_coeffs)+"]={";
  l=lstcat(l,l_ini);
  [l,s_struct,p_name_struct]=vhdl_append_declar_to_l(l);
  l_ini=l;
  l_ini=ident_list(l_ini,"  ");
// entete of l_cod
  l_cod=ident_list(l_cod,"  ");
  l_test=get_vhdl_test_code();
  l_cod=lstcat(l_cod,l_test);
  l_cod=ident_list(l_cod,"  ");

endfunction
function [lbd_out,l_init,l_cod]=get_vhdl_cel_code(lbd_in,cel,name_struct,num_cel,name_input)
  [lhs,rhs]=argn(0);
  if (rhs<4) then
     num_cel=0; // unknown number of cel 
  end
  
  if (cel.forme=="df2") then
    if (rhs>=5) then
       [lbd_out,l_init,l_cod]=get_vhdl_df2_code(lbd_in,cel,name_struct,num_cel,name_input)
    else
       [lbd_out,l_init,l_cod]=get_vhdl_df2_code(lbd_in,cel,name_struct,num_cel)
    end   
    return
  elseif (cel.forme=="ss") then
    [lbd_out,l_init,l_cod]=get_vhdl_ss_code(lbd_in,cel,name_struct,num_cel)
    return
  end
  error("not yet implemented for "+cel.forme);
endfunction
function [l,name_out]=cod_vhdl_shift_rnd(nv,val_d,NB_BITS,switch_round)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  l=list();i=0;
  if vhdl_glob.dbg==%t then
    pause
  end
  if (val_d>=0)|(switch_round=="floor") then
    [s,nam_out]=cod_vhdl_decal(nv,val_d,NB_BITS)
    i=i+1;l(i)=s;
    if (lhs>=2) then
      name_out=nam_out;
    end
    return
  end
  if (switch_round=="round") then
    [s,tmp]=cod_vhdl_decal(nv,val_d+1,NB_BITS);
    i=i+1;l(i)=s;
    [lad,tmp]=cod_vhdl_add_with_const(tmp,get_vhdl_signed_coeff(1,NB_BITS));
    l=lstcat(l,lad);i=length(l);
    [s,nam_out]=cod_vhdl_decal(tmp,-1,NB_BITS)
    i=i+1;l(i)=s;
    if (lhs>=2) then
      name_out=nam_out;
    end
    return
  end
//   if (switch_round=="fix") then
//     i=i+1;l(i)="if ("+nv+">=0) {";
//       [s,n_out]=cod_vhdl_decal(nv,val_d,NB_BITS)
//       i=i+1;l(i)="  "+s;
//     i=i+1;l(i)="} else {";
//       [s,n_out]=cod_vhdl_decal("(-"+nv+")",val_d,NB_BITS)
//       i=i+1;l(i)="  "+s;
//       i=i+1;l(i)="  "+n_out+"=-"+n_out+";";
//     i=i+1;l(i)="}";
//     return
//   end
  error("switch_round="+switch_round+" not yet implemented");
endfunction
function [s,name_out]=cod_vhdl_decal(nv,val_d,NB_BITS_MAX_RESULT)
  [lhs,rhs]=argn(0);
  s=[];
  s_type=[];
  NB_BITS_RESULT=NB_BITS_MAX_RESULT;
  var_in=get_last_vhdl_var_named(nv,%f);
  if max(size(var_in))>0 then
    NB_BITS_RESULT=min(var_in.nb_bits+val_d,NB_BITS_RESULT);
    NB_BITS_RESULT=NB_BITS_MAX_RESULT;
    if (NB_BITS_RESULT<=0) then
    // fix the output to 0 on 1 bits
      n_out=get_new_vhdl_var(NB_BITS_RESULT);
      s=n_out.name+" <= "+get_vhdl_signed_coeff(0,NB_BITS_RESULT)+" ; -- output of shift by "+string(val_d)+"is always 0";
      if (lhs>=2) then
        name_out=n_out.name;
      end
      return 
    end
  end
  if (rhs>3) then
    if (NB_BITS_RESULT>0) then
      s_type="(int_"+string(NB_BITS_RESULT)+")";
    end
  end
  s_val_d=string(abs(val_d));
  if (val_d==0) then
    s_rhs=[];
  elseif val_d>0 then
    s_rhs="shift_left("+nv+","+s_val_d+")";
  else
    s_rhs="shift_right("+nv+","+s_val_d+")";
  end
  
  if (s_type==[]) then
    if (s_rhs==[]) then
      if (lhs>=2) then
        name_out=nv;
      end
      return;
    else
      n_out=get_new_vhdl_var(NB_BITS_RESULT);
      s=n_out.name+" <= "+s_rhs+" ;";
      if (lhs>=2) then
        name_out=n_out.name;
      end
    end
    
    return;
  end
  if s_rhs==[] then
    s_rhs=nv;
  end
  s_rhs="("+s_rhs+")";
  n_out=get_new_vhdl_var(NB_BITS_RESULT);
  s=n_out.name +" <= "+s_type+s_rhs+";";
  if (lhs>=2) then
    name_out=n_out.name;
  end
endfunction

function [l,name_out]=cod_vhdl_add_with_const(nv1,ncst,NB_BITS,ns)
   [lhs,rhs]=argn(0);
   l=list();
   [s_resiz_v1,name_resiz_v1]=cod_vhdl_resize(nv1,NB_BITS);
   if (name_resiz_v1~=nv1) then
     il=length(l);l(il+1)=s_resiz_v1;
     nv1=name_resiz_v1;
   end
   nv2=ncst; // no resize for constant
   if (rhs>=4) then
     n_out=get_new_vhdl_var(NB_BITS,ns);
   else
     n_out=get_new_vhdl_var(NB_BITS);
   end
   il=length(l);l(il+1)=n_out.name+ " <= "+nv1+" + "+nv2 + " ;";
   if (lhs>=2) then
     name_out=n_out.name;
   end
endfunction
function [l,name_out]=cod_vhdl_addition(nv1,nv2,NB_BITS,ns)
   [lhs,rhs]=argn(0);
   l=list();
   [s_resiz_v1,name_resiz_v1]=cod_vhdl_resize(nv1,NB_BITS);
   if (name_resiz_v1~=nv1) then
     il=length(l);l(il+1)=s_resiz_v1;
     nv1=name_resiz_v1;
   end
   [s_resiz_v2,name_resiz_v2]=cod_vhdl_resize(nv2);
   if (name_resiz_v2~=nv2) then
     il=length(l);l(il+1)=s_resiz_v2;
     nv2=name_resiz_v2;
   end
   if (rhs>=4) then
     n_out=get_new_vhdl_var(NB_BITS,ns);
   else
     n_out=get_new_vhdl_var(NB_BITS);
   end
   il=length(l);l(il+1)=n_out.name+ " <= "+nv1+" + "+nv2 + " ;";
   if (lhs>=2) then
     name_out=n_out.name;
   end
endfunction
function [l,name_out]=cod_vhdl_substraction(nv1,nv2,NB_BITS,ns)
   [lhs,rhs]=argn(0);
   l=list();
   [s_resiz_v1,name_resiz_v1]=cod_vhdl_resize(nv1,NB_BITS);
   if (name_resiz_v1~=nv1) then
     il=length(l);l(il+1)=s_resiz_v1;
     nv1=name_resiz_v1;
   end
   [s_resiz_v2,name_resiz_v2]=cod_vhdl_resize(nv2);
   if (name_resiz_v2~=nv2) then
     il=length(l);l(il+1)=s_resiz_v2;
     nv2=name_resiz_v2;
   end
   if (rhs>=4) then
     n_out=get_new_vhdl_var(NB_BITS,ns);
   else
     n_out=get_new_vhdl_var(NB_BITS);
   end
   il=length(l);l(il+1)=n_out.name+ " <= "+nv1+" - "+nv2 + " ;";
   if (lhs>=2) then
     name_out=n_out.name;
   end
endfunction


function s=cod_vhdl_affect(n_out,value,NB_BITS)
  [lhs,rhs]=argn(0);
  if (rhs<3) then
     NB_BITS=-1;
  end
  if (NB_BITS>0) then
    s_type="int_"+string(NB_BITS);
    s=n_out+"= ("+s_type+")"+string(value)+";"
  else
    s=n_out+"= "+string(value)+";"
  end
endfunction
function [l,name_out]=cod_delay(ne,nb_delay,NB_BITS,ns)
  [lhs,rhs]=argn(0);
  if (rhs<2) then
    nb_delay=1;
  end
  if (nb_delay<1) then
    nb_delay=1;
  end
  nei=ne;
    j=0;l=list();
  for i=1:nb_delay,
    nsi=ne+"_delayed_"+string(i);
    if (rhs==4) then
      if (i==nb_delay) then
        nsi=ns;
      end
    end
    tmp=get_new_vhdl_var(NB_BITS,nsi);
    process=get_new_vhdl_process();
    j=j+1;l(j)=process.name+": process("+vhdl_glob.CLOCK_NAME+", f_ech)"
    j=j+1;l(j)="begin"
    j=j+1;l(j)="  if rising_edge("+vhdl_glob.CLOCK_NAME+") then if f_ech="'1"' then "+nsi+" <= "+nei+" ;"
    j=j+1;l(j)="				   end if;"
    j=j+1;l(j)="  end if;"
    j=j+1;l(j)="end process;"
    nei=nsi;
  end
  if (lhs>=2) then
    name_out=nsi;
  end
endfunction

function [l,name_out]=cod_vhdl_multiply_acc(name_acc_in,name_coeff,name_var_in)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  [lmul,tmp]=cod_vhdl_multiply(name_var_in,name_coeff,vhdl_glob.NB);
  [lad,nout]=cod_vhdl_addition(tmp,name_acc_in,2*vhdl_glob.NB);
  l=lstcat(lmul,lad);
  if (lhs>=2) then
    name_out=nout;
  end
endfunction
function [l,name_out]=cod_vhdl_multiply(name_var_in,name_coeff,NB_BITS)
  [lhs,rhs]=argn(0);
  l=list();
  v_in=get_last_vhdl_var_named(name_var_in,%f);
  if (max(size(v_in))>0) then
    if (v_in.nb_bits~=NB_BITS) then
      [s,name_var_in]=cod_vhdl_resize(name_var_in,NB_BITS);
      il=length(l);l(il+1)=s;
    end
  end
  nout=get_new_vhdl_var(2*NB_BITS);
  s=nout.name+" <= "+name_var_in+" * "+name_coeff+" ;"
  il=length(l);l(il+1)=s;
  if (lhs>=2) then
    name_out=nout.name
  end
endfunction
function set_last_vhdl_var_fd_val(name_field,value)
  global vhdl_glob;
  if vhdl_glob.nb_tmp==0 then
    return;
  end
  s=vhdl_glob.l_tmp(vhdl_glob.nb_tmp);
  s(name_field)=value;
  vhdl_glob.l_tmp(vhdl_glob.nb_tmp)=s;
endfunction
function s=get_new_vhdl_var(NB_BITS,name)
  global vhdl_glob;
  if NB_BITS<0 then
    whereami()
    pause
  end
  [lhs,rhs]=argn(0);
  vhdl_glob.nb_tmp=vhdl_glob.nb_tmp+1;
  if (rhs<2) then
    s.name=vhdl_glob.name_tmp+string(vhdl_glob.nb_tmp);
  else
    s.name=name;  
  end
  s.nb_bits=NB_BITS;
  s.is_output=%f;
  vhdl_glob.l_tmp(vhdl_glob.nb_tmp)=s;
  
endfunction
function s=get_new_vhdl_process(name)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  vhdl_glob.nb_process=vhdl_glob.nb_process+1;
  if (rhs<1) then
    s.name=vhdl_glob.name_process+string(vhdl_glob.nb_process);
  else
    s.name=name;
  end
  vhdl_glob.l_process(vhdl_glob.nb_process)=s;

endfunction
function s=get_last_vhdl_process()
  global vhdl_glob;
  s=vhdl_glob.l_process(vhdl_glob.nb_process);
endfunction
function s=get_last_vhdl_var()
  global vhdl_glob;
  s=vhdl_glob.l_tmp(vhdl_glob.nb_tmp);
endfunction
function res=get_last_vhdl_output_var()
  global vhdl_glob;
  for il=length(vhdl_glob.l_tmp):-1:1 ,
    s=vhdl_glob.l_tmp(il);
    if s.is_output==%t then
       res=s;
       return
    end
  end
  
  res=[];
endfunction
function res=get_last_vhdl_var_named(name_var,must_exist)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  for il=length(vhdl_glob.l_tmp):-1:1 ,
    s=vhdl_glob.l_tmp(il);
    if s.name==name_var then
       res=s;
       return
    end
  end
  if (rhs<2) then
    must_exist=%t;
  end
  if (must_exist==%t) then
    whereami();
    disp("unknown var: " , name_var);
    pause;
  end
  res=[];
endfunction
function [lbd_out,l_ini,l_cod]=get_vhdl_df0_code(lbd_in,cel,name_struct,num_cel,name_input)
  [lhs,rhs]=argn(0);
  switch_round=cel.switch_round;
  if switch_round=="round only at key points" then
    switch_round_std="floor";
    switch_round_key="round";
  else 
    switch_round_std=switch_round;
    switch_round_key=switch_round;
  end
  s_num_cel=string(num_cel);
  if (rhs<5) then
    en=get_last_vhdl_output_var();
    if (max(size(en))==0) then
       en=get_new_vhdl_var(cel.NB_BITS,"en_"+string(NB_BITS));
    end
    en=en.name;
  else
    en=name_input;
  end
  l_cod=list();i_cod=0;
  l_ini=list();i_ini=0; 
  b0=cel.Bi_int(1);
  if (b0==0) then
    // very special case of gain equal to 0
    sn=get_new_vhdl_var(1);
    sn=sn.name;
    i_cod=i_cod+1;l_cod(i_cod)=sn+"<="+get_vhdl_signed_coeff(b0,1)+"; -- gain b0 =0 ";
    lbd_out=-%inf;
    set_last_vhdl_var_fd_val("is_output",%t);
    return
  end
  str_coeffs="coeffs";
  LB=cel.LB;
  lbd_out=2^(-LB);
  log2_in=round(log2(lbd_in));
  [li,en]=cod_vhdl_shift_rnd(en,round(log2(lbd_in)),2*NB_BITS,switch_round_key);
  li(1)=li(1)+" -- en<-en .2^"+string(log2_in)+ " ";
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  //i_ini=i_ini+1;l_ini(i_ini)=string(b0)+" -- cel +"+string(num_cel)+":  b0.2^"+string(LB)+" ";
  [l_mult,en]=cod_vhdl_multiply(en,get_vhdl_signed_coeff(b0,NB_BITS),NB_BITS);
  l_mult(1)=l_mult(1)+" -- en<-b0 . en ";
  l_cod=lstcat(l_cod,l_mult);i_cod=length(l_cod);
  set_last_vhdl_var_fd_val("is_output",%t);
endfunction
function sy=get_vhdl_auto_inc_code(s)
 sy="( *("+s+"++) )";
endfunction
function s=get_vhdl_signed_coeff(a,NB_BITS)
  s="to_signed("+string(a)+","+string(NB_BITS)+")"
endfunction
function l=cod_vhdl_convert(name_out,name_in,NB_BITS)
  s=name_out+" <= "+name_in+"("+string(NB_BITS-1)+" downto 0);"
  l=list(s);
endfunction

function [lbd_out,l_ini,l_cod]=get_vhdl_df2_code(lbd_in,cel,name_struct,num_cel,name_input)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  dg=cel.degre
  if dg==0 then
    if (rhs==5) then
      [lbd_out,l_ini,l_cod]=get_vhdl_df0_code(lbd_in,cel,name_struct,num_cel,name_input);
    else
      [lbd_out,l_ini,l_cod]=get_vhdl_df0_code(lbd_in,cel,name_struct,num_cel);
    end  
    return
  end
  Lin=round(log2(lbd_in));
  b0=cel.Bi_int(1);
  LA=cel.LA;
  LB=cel.LB;
  Lin_prog=Lin+LA;
  lbd_out=2^(-LB);
  switch_round=cel.switch_round;
  if switch_round=="round only at key points" then
    switch_round_std="floor";
    switch_round_key="round";
  else 
    switch_round_std=switch_round;
    switch_round_key=switch_round;
  end
  Lx=round(log2(1-abs(cel.a0x_de_z)));
  sign_a0=sign(cel.a0x_de_z);
  s_deg=string(cel.degre);
  l_cod=list();i_cod=length(l_cod);
  l_ini=list();i_ini=length(l_ini);
  if (rhs<5) then
    en=get_last_vhdl_output_var();
    if (max(size(en))==0) then
       en=get_new_vhdl_var(2*cel.NB_BITS,"en_"+string(2*NB_BITS));
    end
    en=en.name;
  else
    en=name_input;
  end
  if (dg>0) then
    b1=cel.Bi_int(2);
    a1=cel.moins_Ai_int(1);
  end
  if (dg >1) then
    b2=cel.Bi_int(3);
    a2=cel.moins_Ai_int(2);
  end
  NB_BITS=cel.NB_BITS;
  str_coeffs="coeffs";
  states="states"
  vn="vn_"+string(NB_BITS);
  if (Lin_prog~=0) then
    [li,en]=cod_vhdl_shift_rnd(en,Lin_prog,2*NB_BITS,switch_round_std);
    li(1)=li(1)+" -- en<<L+LA ,L="+string(Lin)+",LA="+string(LA)+"";
    l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  end
  name_x1="x1_"+string(num_cel);
  if (dg>1) then
    name_op_x1="x2_"+string(num_cel);
    name_x2=name_op_x1;
    name_op_x2="op"+name_x2;
    tmp_x2=name_op_x2;
  else  
    name_op_x1="op"+name_x1;
  end
  tmp_x1=name_op_x1;
// AR part, denominator A
  i_cod=i_cod+1;l_cod(i_cod)="  -- AR part of cel "+string(num_cel);
  [lcd,en]=cod_vhdl_multiply_acc(en,get_vhdl_signed_coeff(a1,NB_BITS),tmp_x1);
  lcd(1)=lcd(1)+" -- - a1 . x1 ";
  l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
  if (dg>1) then
    //i_ini=i_ini+1;l_ini(i_ini)=string(a2)+" --  cel +"+string(num_cel)+":  -a2.2^"+string(LA)+" ";
    [lcd,en]=cod_vhdl_multiply_acc(en,get_vhdl_signed_coeff(a2,NB_BITS),tmp_x2);
    lcd(1)=lcd(1)++" -- - a2 . x2 ";
    l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
  end
  vhdl_glob.dbg=%f;
  if (switch_saturate~="saturate") then
    [li,vn]=cod_vhdl_shift_rnd(en,-cel.LA,2*NB_BITS,switch_round_key);
    li(1)=li(1)+" -- vn<-en >> LA ";
  else
    [li,en]=cod_vhdl_shift_rnd(en,-cel.LA,2*NB_BITS,switch_round_key);
    li(1)=li(1)+" -- vn<-en >> LA ";
    l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
    [li,vn]=cod_vhdl_satur(en,NB_BITS,switch_saturate);
  end
  l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  // update states
  lcv=cod_vhdl_convert(name_x1,vn,NB_BITS);
  lcv(1)=lcv(1)+" -- x1=vn  ";
  l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
// MA part, numerator B
  i_cod=i_cod+1;l_cod(i_cod)="  -- MA part of cel "+string(num_cel);
  if (b0~=0) then
    //i_ini=i_ini+1;l_ini(i_ini)=string(b0)+" --  cel +"+string(num_cel)+":  b0.2^"+string(LB)+" ";
    [l_mult,en]=cod_vhdl_multiply(name_x1,get_vhdl_signed_coeff(b0,NB_BITS),NB_BITS);
    l_mult(1)=l_mult(1)+" -- b0 . x1";
    l_cod=lstcat(l_cod,l_mult);i_cod=length(l_cod);
    //i_ini=i_ini+1;l_ini(i_ini)=string(b1)+" --  cel +"+string(num_cel)+":  b1.2^"+string(LB)+" ";
    [lcd,en]=cod_vhdl_multiply_acc(en,get_vhdl_signed_coeff(b1,NB_BITS),tmp_x1);
    lcd(1)=lcd(1)+" -- b1 . x1  ";
    l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
  else 
    //i_ini=i_ini+1;l_ini(i_ini)=string(b1)+" --  cel +"+string(num_cel)+":  b1.2^"+string(LB)+", note that b0=0 ";
    [l_mult,en]=cod_vhdl_multiply(tmp_x1,get_vhdl_signed_coeff(b1,NB_BITS),NB_BITS);
    l_mult(1)=l_mult(1)+" -- en<-b1 . x2 ,because b0=0";
    l_cod=lstcat(l_cod,l_mult);i_cod=length(l_cod);
  end
  if (dg>1) then
    //i_ini=i_ini+1;l_ini(i_ini)=string(b2)+" --  cel +"+string(num_cel)+":  b2.2^"+string(LB)+" ";
    [lcd,en]=cod_vhdl_multiply_acc(en,get_vhdl_signed_coeff(b2,NB_BITS),tmp_x2);
    lcd(1)=lcd(1)+" -- b2 .op x2";
    l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
  end
  l_cod(i_cod)=l_cod(i_cod)+" -- output of cel "+string(num_cel);
  set_last_vhdl_var_fd_val("is_output",%t);
  if (Lx==0) then
    nb_delay=1;
    var_x1=get_new_vhdl_var(NB_BITS,name_x1);
    i_cod=length(l_cod);l_cod(i_cod+1)="-- "+tmp_x1+" <- delay operator ("+name_x1+")";
    i_cod=i_cod+1;l_cod(i_cod)="-- "+tmp_x1+" <- q("+name_x1+"), avec q=1/z";
    [lcd,name_op_x1]=cod_delay(name_x1,nb_delay,NB_BITS,name_op_x1);
    l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    if (dg>1) then
      i_cod=length(l_cod);l_cod(i_cod+1)="-- "+tmp_x2+" <- delay operator ("+name_x2+")";
      [lcd,name_op_x2]=cod_delay(name_x2,nb_delay,NB_BITS,name_op_x2);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    end
  end
  if (Lx~=0) then
    name_q="(2^-"+string(abs(Lx))+")";
    if (sign_a0<0) then
      name_q=name_q+"/(z-[ 1 - "+name_q+" ] )";
    else  
      name_q=name_q+"/(z+[1-"+name_q+"])";
    end
    nb_delay=1;
    name_gx1="i1_"+string(num_cel);
    name_op_gx1="opi1_"+string(num_cel);
    tmp_x1=get_new_vhdl_var(NB_BITS,name_op_x1);
    tmp_x1=tmp_x1.name;
    var_x1=get_new_vhdl_var(NB_BITS,name_x1);
    i_cod=i_cod+1;l_cod(i_cod)="-- "+tmp_x1+" <- q("+name_x1+"), avec q="+name_q;
    [lcd,name_op_gx1]=cod_delay(name_gx1,nb_delay,NB_BITS+abs(Lx)+1,name_op_gx1);
    l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    [lcd,tmp]=cod_vhdl_shift_rnd(name_op_gx1,-abs(Lx),NB_BITS+abs(Lx)+1,switch_round_key);
    lcv=cod_vhdl_convert(name_op_x1,tmp,NB_BITS);
    l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
    if (sign_a0<0) then
      [lsz,tmp]=cod_vhdl_substraction(name_x1,tmp_x1,NB_BITS+abs(Lx)+1);
      l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
      [lad,name_gx1]=cod_vhdl_addition(tmp,name_op_gx1,NB_BITS+abs(Lx)+1,name_gx1);
      l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    else
    // xn=-x(n-1)+en+2_L.xn_1
    // 2^-L/(1+(1-2-L).q)
      [lad,tmp]=cod_vhdl_addition(name_x1,tmp_x1,NB_BITS+abs(Lx)+1);
      l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
      [lsz,name_gx1]=cod_vhdl_substraction(tmp,name_op_gx1,NB_BITS+abs(Lx)+1,name_gx1);
      l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    end
    if (dg>1) then
      name_gx2="i2_"+string(num_cel);
      name_op_gx2="opi2_"+string(num_cel);
      tmp_x2=name_op_x2;
      tmp_x2=get_new_vhdl_var(NB_BITS,name_op_x2);
      tmp_x2=tmp_x2.name;
      i_cod=i_cod+1;l_cod(i_cod)="-- "+tmp_x2+" <- q("+name_x2+"), avec q="+name_q;
      [lcd,name_op_gx2]=cod_delay(name_gx2,nb_delay,NB_BITS+abs(Lx)+1,name_op_gx2);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      [lcd,tmp]=cod_vhdl_shift_rnd(name_op_gx2,-abs(Lx),NB_BITS+abs(Lx)+1,switch_round_key);
      lcv=cod_vhdl_convert(name_op_x2,tmp,NB_BITS);
      l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
      if (sign_a0<0) then
	[lsz,tmp]=cod_vhdl_substraction(name_x2,tmp_x2,NB_BITS+abs(Lx)+1);
	l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
	[lad,name_gx2]=cod_vhdl_addition(tmp,name_op_gx2,NB_BITS+abs(Lx)+1,name_gx2);
	l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
	l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      else
      // xn=-x(n-1)+en+2_L.xn_1
      // 2^-L/(1+(1-2-L).q)
	[lad,tmp]=cod_vhdl_addition(name_x2,tmp_x2,NB_BITS+1);
	l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
	[lsz,name_gx2]=cod_vhdl_substraction(tmp,name_op_gx2,NB_BITS+abs(Lx)+1,name_gx2);
	l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
	l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      end
    end
  end


endfunction
function [lbd_out,l_ini,l_cod]=get_vhdl_ss_code(lbd_in,cel,name_struct,num_cel,name_input)
  global vhdl_glob;
  [lhs,rhs]=argn(0);
  dg=cel.degre
  if dg==0 then
    if (rhs==5) then
      [lbd_out,l_ini,l_cod]=get_vhdl_df0_code(lbd_in,cel,name_struct,num_cel,name_input);
    else
      [lbd_out,l_ini,l_cod]=get_vhdl_df0_code(lbd_in,cel,name_struct,num_cel);
    end
    return
  end
  if (isfield(cel,"a0x_de_z")==MY_TRUE) then
    sign_a0=sign(cel.a0x_de_z);
    Lx=round(log2(1-abs(cel.a0x_de_z)));
  else
    Lx=0;
  end
  lbd_out=2^(-cel.L_s);
  NB_BITS=cel.NB_BITS;
  if (rhs<5) then
    en=get_last_vhdl_output_var();
    if (max(size(en))==0) then
       en=get_new_vhdl_var(2*cel.NB_BITS,"en_"+string(2*NB_BITS));
    end
    en=en.name;
  else
    en=name_input;
  end
  accx="accx_"+string(2*NB_BITS);
  vn="vn_"+string(NB_BITS);
  Lin=round(log2(lbd_in));
  switch_round=cel.switch_round;
  if switch_round=="round only at key points" then
    switch_round_std="floor";
    switch_round_key="round";
  else 
    switch_round_std=switch_round;
    switch_round_key=switch_round;
  end
  s_deg=string(cel.degre);
  l_cod=list();i_cod=length(l_cod);
  l_ini=list();i_ini=length(l_ini);
  vn="vn_"+string(cel.NB_BITS);
  str_coeffs="coeffs";
  states="states"
  if (Lin~=0) then
    [li,vn]=cod_vhdl_shift_rnd(en,Lin,2*NB_BITS,switch_round_std);
    li(1)=li(1)+" -- vn<-en<<L ,L="+string(Lin)+"";
    l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  else
    vn=en;
  end
  new_vn=get_new_vhdl_var(NB_BITS,"e_"+string(num_cel));
  [lcv]=cod_vhdl_convert(new_vn.name,vn,NB_BITS);
  l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
  vn=new_vn.name;

  name_x  =["x1_"+string(num_cel);
            "x2_"+string(num_cel)];
  name_opx=["op_x1_"+string(num_cel);
            "op_x2_"+string(num_cel)];
  A=cel.Aint;
  B=cel.Bint;
  C=cel.Cint;
  D=cel.Dint;

  if (D~=0) then
      //  i_ini=i_ini+1;l_ini(i_ini)=string(D)+" --  cel +"+string(num_cel)+":  D.2^"+string(cel.L_s)+" ";
    [l_mult,en]=cod_vhdl_multiply(vn,get_vhdl_signed_coeff(D,NB_BITS),NB_BITS);
    l_mult(1)=l_mult(1)+" -- sn<-D.vn ";
    l_cod=lstcat(l_cod,l_mult);i_cod=length(l_cod);
  else
    i_cod=i_cod+1;l_cod(i_cod)=cod_vhdl_affect(en,0,2*NB_BITS)+" -- sn<-0,because D=0 ";
  end
  for i_x=1:cel.degre,
    i=i_x;
    Lxi=cel.L_x(i);
    ni=string(i);
    nxi=name_x(i_x);
    nopxi=name_opx(i_x);
    if cel.degre>1 then
      j=1+cel.degre-i_x;
      nj=string(j);
      nxj=name_x(j);
      nopxj=name_opx(j);
      
    end
    s="-- update state "+nxi +" of cel "+string(num_cel);
    i_cod=i_cod+1;l_cod(i_cod)=s;
    
    if (B(i)~=0) then
    // Xn+1=B.U
    //i_ini=i_ini+1;l_ini(i_ini)=string(B(i))+" --  cel +"+string(num_cel)+":  B"+ni+".2^"+string(Lxi)+" ";
      [l_mult,accx]=cod_vhdl_multiply(vn,get_vhdl_signed_coeff(B(i),NB_BITS),NB_BITS);
      l_mult(1)=l_mult(1)+" -- accx<-b"+ni+".vn ";
      l_cod=lstcat(l_cod,l_mult);i_cod=length(l_cod);
    end // if (Bi<>0 )
  // Xn+1=A.X
    if (A(i,i)~=0) then
    //      i_ini=i_ini+1;l_ini(i_ini)=string(A(i,i))+" --  cel +"+string(num_cel)+":  A"+ni+ni+".2^"+string(Lxi)+" ";
      [lcd,accx]=cod_vhdl_multiply_acc(accx,get_vhdl_signed_coeff(A(i,i),NB_BITS),nopxi);
      lcd(1)=lcd(1)+" -- accx<-accx-a"+ni+ni+" . "+nopxi+" ";
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    else
    //      i_ini=i_ini+1;l_ini(i_ini)=" --  cel +"+string(num_cel)+":  A"+ni+ni+"is zero, not coded in coeffs ";
    end
    if (dg>1) then
      if (A(i,j)~=0 ) then
          //  i_ini=i_ini+1;l_ini(i_ini)=string(A(i,j))+" --  cel +"+string(num_cel)+":  A"+ni+nj+".2^"+string(Lxi)+" ";
        [lcd,accx]=cod_vhdl_multiply_acc(accx,get_vhdl_signed_coeff(A(i,j),NB_BITS),nopxj);
        lcd(1)=lcd(1)+" -- accx<-accx-a"+ni+nj+" . "+nopxj+" ";
        l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      else
          //  i_ini=i_ini+1;l_ini(i_ini)=" --  cel +"+string(num_cel)+":  A"+ni+nj+"is zero, not coded in coeffs ";
      end
    end
    if (switch_saturate~="saturate") then
      [li,accx]=cod_vhdl_shift_rnd(accx,-Lxi,2*NB_BITS,switch_round_key);
      li(1)=li(1)+" -- accx<-accx >> Lx"+string(i)+" ";
    else
      [li,accx]=cod_vhdl_shift_rnd(accx,-Lxi,2*NB_BITS,switch_round_key);
      li(1)=li(1)+" -- accx<-accx >> Lx"+string(i)+" ";
      l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
      li=cod_vhdl_satur(accx,accx,NB_BITS,switch_saturate);
    end
    l_cod=lstcat(l_cod,li);i_cod=length(l_cod);
  // update state
    lcv=cod_vhdl_convert(nxi,accx,NB_BITS);
    l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
    if (C(i)~=0) then
    // Y=C.X use previously computed state
        //  i_ini=i_ini+1;l_ini(i_ini)=string(C(i))+" --  cel +"+string(num_cel)+":  C"+ni+".2^"+string(cel.L_s)+" ";
      [lcd,en]=cod_vhdl_multiply_acc(en,get_vhdl_signed_coeff(C(i),NB_BITS),nopxi);
      lcd(1)=lcd(1)+" -- sn<-sn+C"+ni+" . "+nxi+" ";
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    end
  end // for i=1:degre
  set_last_vhdl_var_fd_val("is_output",%t);
//-----------------------------------
// compute delay or operator
//-----------------------------------
  for i_x=1:cel.degre,
    nxi=name_x(i_x);
    nopxi=name_opx(i_x);
    if (Lx==0) then
      var_xi=get_new_vhdl_var(NB_BITS,nxi);
      nb_delay=1;
      i_cod=length(l_cod);l_cod(i_cod+1)="-- "+nopxi+" <- delay operator ("+nxi+")";
      i_cod=i_cod+1;l_cod(i_cod)="-- "+nopxi+" <- q("+nxi+"), avec q=1/z";
      [lcd,nopxi]=cod_delay(nxi,nb_delay,NB_BITS,nopxi);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
    end
    if (Lx~=0) then
      name_q="(2^-"+string(abs(Lx))+")";
      if (sign_a0<0) then
	name_q=name_q+"/(z-[ 1 - "+name_q+" ] )";
      else
	name_q=name_q+"/(z+[1-"+name_q+"])";
      end
      nb_delay=1;
      name_gxi="i1_"+string(num_cel);
      name_op_gxi="opi1_"+string(num_cel);
      tmp_xi=get_new_vhdl_var(NB_BITS,nopxi);
      tmp_xi=tmp_xi.name;
      var_xi=get_new_vhdl_var(NB_BITS,nxi);
      i_cod=i_cod+1;l_cod(i_cod)="-- "+tmp_xi+" <- q("+nxi+"), avec q="+name_q;
      [lcd,name_op_gxi]=cod_delay(name_gxi,nb_delay,NB_BITS+abs(Lx)+1,name_op_gxi);
      l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      [lcd,tmp]=cod_vhdl_shift_rnd(name_op_gxi,-abs(Lx),NB_BITS+abs(Lx)+1,switch_round_key);
      lcv=cod_vhdl_convert(nopxi,tmp,NB_BITS);
      l_cod=lstcat(l_cod,lcv);i_cod=length(l_cod);
      if (sign_a0<0) then
	[lsz,tmp]=cod_vhdl_substraction(nxi,tmp_xi,NB_BITS+abs(Lx)+1);
	l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
	[lad,name_gxi]=cod_vhdl_addition(tmp,name_op_gxi,NB_BITS+abs(Lx)+1,name_gxi);
	l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
	l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      else
      // xn=-x(n-1)+en+2_L.xn_1
      // 2^-L/(1+(1-2-L).q)
	[lad,tmp]=cod_vhdl_addition(nxi,tmp_xi,NB_BITS+abs(Lx)+1);
	l_cod=lstcat(l_cod,lad);i_cod=length(l_cod);
	[lsz,name_gxi]=cod_vhdl_substraction(tmp,name_op_gxi,NB_BITS+abs(Lx)+1,name_gxi);
	l_cod=lstcat(l_cod,lsz);i_cod=length(l_cod);
	l_cod=lstcat(l_cod,lcd);i_cod=length(l_cod);
      end
    end
  end // for i_x=1:cel.degre
endfunction //get_vhdl_ss_code

function ld=get_vhdl_real_test_code()
   ld=list();id=0;
endfunction
  function new_l=suppress_vhdl_remarques(l)
    if SUPPRESS_REMARQUES==%f then
      new_l=l;
      return
    end
    k=0;new_l=list();
    for i=1:length(l),
      s=l(i);
      s=stripblanks(s,%t);
      index=strindex(s,'--');
      do_not_suppress= min(index)~= 1 ;
      if do_not_suppress==%t then
        k=k+1;new_l(k)=l(i);
      end
    end // for =1:length(l),
  endfunction
  function l=vhdl_get_list_coeffs(type_var,name_var,coeffs)
    nb_coeffs=max(size(coeffs));
    l=list();
//     for i=1:nb_coeffs,
//       l(i+1)=string(coeffs(i));
//       if (i<nb_coeffs) then
//        l(i+1)=l(i+1)+",";
//       else
//        l(i+1)=l(i+1)+"};"
//       end
//     end
//     l=ident_list(l,"    ");
    //l(1)="const "+type_var+" "+name_var+"["+string(nb_coeffs)+"]={";
  endfunction