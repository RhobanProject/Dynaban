MY_TRUE=%t; // merci scilab, compatibilite arriere de isfield...
global pcaxe_glob;
pcaxe_glob.name="pca global variables";
function init_pcaxe_glob(params)
    global pcaxe_glob;
    pcaxe_glob.NAME_INPUT_LOGIC="ent";
    pcaxe_glob.NAME_OUTPUT_LOGIC="sor";
    pcaxe_glob.CLOCK_NAME="clk_50MHz";
    pcaxe_glob.nb_process=0;
    pcaxe_glob.name_process="z_";
    pcaxe_glob.l_process=list();
    pcaxe_glob.name="pca global variables";
    pcaxe_glob.name_tmp="tmp_";
    pcaxe_glob.nb_tmp=0;
    pcaxe_glob.l_tmp=list();
    pcaxe_glob.NB=params.NB_BITS;
    pcaxe_glob.dbg=%f;
endfunction
function [s,name_out]=cod_pcaxe_resize(name_in,NB_BITS,resize_if_unknown)
    [lhs,rhs]=argn(0);
    if (rhs<3) then
        resize_if_unknown=%t;
    end
    v_in=get_last_pcaxe_var_named(name_in,%f);
    if (max(size(v_in))~=0) then
        // found v_in
        if (v_in.nb_bits==NB_BITS) then
            s="-- do not resize( "+name_in+" , "+string(NB_BITS)+" );";
            name_out=name_in;
            return
        end
        var_out=get_new_pcaxe_var(NB_BITS);
        name_out= var_out.name;
        s= name_out+"<= resize( "+name_in+" , "+string(NB_BITS)+" );";
        return
    end
    //not found v_in
    if (resize_if_unknown==%t) then
        var_out=get_new_pcaxe_var(NB_BITS);
        name_out= var_out.name;
        s= name_out+"<= resize( "+name_in+" , "+string(NB_BITS)+" );";
    else
        s="-- do not resize( "+name_in+" to "+string(NB_BITS)+", because it is not a signal";
        name_out=name_in;
        return
    end
endfunction
function output=compute_pcaxe_filter(F_w,params)
    init_pcaxe_glob(params);
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
            disp("WARNING in function functions_gene_pcaxe->compute_pcaxe_filter");
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
function l=get_pcaxe_standard_def(nb_cels,Tech_s)
    s_nbcels=string(round(nb_cels));
    l=list();i=0;
    i=i+1;l(i)="NOMBRE DE BLOCS :"+s_nbcels;
    i=i+1;l(i)="NOMBRE DE VRAIS BLOCS :"++s_nbcels;
    i=i+1;l(i)="VERSION PCAXE10";
    i=i+1;l(i)="Periode Ech(ms)"+string(Tech_s*1e3);
    i=i+1;l(i)="Periode Rafraichissement Ecran (s) 1.01000000000000E+002";
    i=i+1;l(i)="Duree Execution(s) 1.00000000000000E+003";
    i=i+1;l(i)="Type de Carte5";
    i=i+1;l(i)="NbSortie_Card19";
    i=i+1;l(i)="NbCODEUR_Card3";
    i=i+1;l(i)="TypeModeCodeur_Card[1]1";
    i=i+1;l(i)="TypeModeCodeur_Card[2]1";
    i=i+1;l(i)="TypeModeCodeur_Card[3]1";
    i=i+1;l(i)="NbCAN_Card16";
    i=i+1;l(i)="TypeModeCAN_Card[1]1";
    i=i+1;l(i)="TypeModeCAN_Card[2]1";
    i=i+1;l(i)="TypeModeCAN_Card[3]1";
    i=i+1;l(i)="TypeModeCAN_Card[4]1";
    i=i+1;l(i)="TypeModeCAN_Card[5]1";
    i=i+1;l(i)="TypeModeCAN_Card[6]1";
    i=i+1;l(i)="TypeModeCAN_Card[7]1";
    i=i+1;l(i)="TypeModeCAN_Card[8]1";
    i=i+1;l(i)="TypeModeCAN_Card[9]1";
    i=i+1;l(i)="TypeModeCAN_Card[10]1";
    i=i+1;l(i)="TypeModeCAN_Card[11]1";
    i=i+1;l(i)="TypeModeCAN_Card[12]1";
    i=i+1;l(i)="TypeModeCAN_Card[13]1";
    i=i+1;l(i)="TypeModeCAN_Card[14]1";
    i=i+1;l(i)="TypeModeCAN_Card[15]1";
    i=i+1;l(i)="TypeModeCAN_Card[16]1";
    i=i+1;l(i)="NbEntree_Card4";
    i=i+1;l(i)="NbCNA_Card4";
    i=i+1;l(i)="TypeModeCNA_Card[1]1";
    i=i+1;l(i)="TypeModeCNA_Card[2]1";
    i=i+1;l(i)="TypeModeCNA_Card[3]1";
    i=i+1;l(i)="TypeModeCNA_Card[4]1";
    i=i+1;l(i)="Nombre de Courbes:0";
    i=i+1;l(i)="TEch min(ms) 1.00000000000000E-002";
    i=i+1;l(i)="TEch Max(ms) 1.00000000000000E+008";
    i=i+1;l(i)="Longueur des tableaux de donnees100000";
    l_define=l;
endfunction
function l_code=get_pcaxe_one_cel_code(F_wi,num_cel,num_cel_input,num_cel_output,num_cel_suiv)
  l_code=list();i=0;
  num_F_wi=numer(F_wi);
  deg_num=degree(num_F_wi);
  s_deg_num=string(round(deg_num));
  den_F_wi=denom(F_wi);
  deg_den=degree(den_F_wi);
  s_deg_den=string(round(deg_den));
  s_num_cel=string(round(num_cel));
  s_num_cel_input=string(round(num_cel_input));
  s_num_cel_output=string(round(num_cel_output));
  s_num_cel_suiv=string(round(num_cel_suiv));
  s_num_cel_prec=string(round(num_cel-1));
i=i+1;l_code(i)="FORME NUMERO : "+s_num_cel;;
i=i+1;l_code(i)="->PREC: "+s_num_cel_prec;
i=i+1;l_code(i)="->SUIV: "+s_num_cel_suiv;
i=i+1;l_code(i)="->CHILDS: 0";
i=i+1;l_code(i)="->Parent: 0";
i=i+1;l_code(i)="->Moi: "+s_num_cel;
i=i+1;l_code(i)="->Msg: cel"+s_num_cel;
i=i+1;l_code(i)="->Left16: 11143";
i=i+1;l_code(i)="->Right16: 12453";
i=i+1;l_code(i)="->Top16: 10981";
i=i+1;l_code(i)="->Bottom16: 12548";
i=i+1;l_code(i)="->Selected: True";
i=i+1;l_code(i)="->TypeForme: 1|";
i=i+1;l_code(i)="->ColorBrush: 192|192|192|0|";
i=i+1;l_code(i)="->StyleBrush: 0|0|0|0|";
i=i+1;l_code(i)="->ColorBord: 0|0|0|0|";
i=i+1;l_code(i)="->StyleBord: 0|0|0|0|";
i=i+1;l_code(i)="->ModeBord: 4|0|0|0|";
i=i+1;l_code(i)="->WidthBord: 1|0|0|0|";
i=i+1;l_code(i)="->NbInputs: 1";
i=i+1;l_code(i)="->NbOutputs: 1";
i=i+1;l_code(i)="->NumDansBuff: 1";
i=i+1;l_code(i)="->Num_IN_OUT : 0";
i=i+1;l_code(i)="->NumBranche: 0";
i=i+1;l_code(i)="->Orientation: 0";
i=i+1;l_code(i)="->Entree numero 1->AddBloc: "+s_num_cel_prec;
i=i+1;l_code(i)="->Entree numero 1->NumOutput: 1";
i=i+1;l_code(i)=" SOUS-BLOC NUMERO :1";
i=i+1;l_code(i)="-> NOM :cel"+s_num_cel;
i=i+1;l_code(i)="-> TYPE:FILTRE";
i=i+1;l_code(i)="-> NIVEAU EXEC:INDETERMINE";
i=i+1;l_code(i)="-> MODIF PARAM:NON MODIFIABLE";
i=i+1;l_code(i)="-> NUM EXEC :150";
i=i+1;l_code(i)="-> PREC :"+s_num_cel_prec;
i=i+1;l_code(i)="-> SUIV :"+s_num_cel_suiv;
i=i+1;l_code(i)=" PARAMS.Code16446";
i=i+1;l_code(i)=" PARAMS.NbEntrees1";
i=i+1;l_code(i)=" PARAMS.NbSorties1";
i=i+1;l_code(i)=" PARAMS.MsgFILTRE";
i=i+1;l_code(i)="Param.Entree[1] :"+s_num_cel_input;
i=i+1;l_code(i)="->Flt.N0Decim1";
i=i+1;l_code(i)="->Flt.NbDecim1";
i=i+1;l_code(i)="->Flt.Val Initiale Entree : 0.00000000000000E+000";
i=i+1;l_code(i)="->Flt.Val Initiale Sortie : 0.00000000000000E+000";
i=i+1;l_code(i)="->Flt.TypeSaisie:Coeffs en W";
i=i+1;l_code(i)="->Flt.Nb"+s_deg_num;
i=i+1;l_code(i)=" ->Flt.Na"+s_deg_den;
for ic=0:deg_num,
  ci=coeff(num_F_wi,ic); 
  s_ci=string(ci);
  s_ind_i=string(ic);
  i=i+1;l_code(i)="->Flt.B["+s_ind_i+"] : "+s_ci;
end
for ic=0:deg_den,
  ci=coeff(den_F_wi,ic); 
  s_ci=string(ci);
  s_ind_i=string(ic);
  i=i+1;l_code(i)="->Flt.A["+s_ind_i+"] : "+s_ci;
end

endfunction
function new_code=append_filter_to_pcaxe(old_code,output)
    format(20);//use 20 decimals numbers for writing old_code
    new_code=old_code;
    F_w=output.F_w_casc_ideal;
    if (length(output.F_w_casc_ideal)<=0) then
        return;
    end
    Tech_s=1e-3;
    nb_cels=length(F_w);
    l_define=get_pcaxe_standard_def(nb_cels,Tech_s)
    l_code=list();  
    for i=1:nb_cels,
        F_wi=F_w(i);
        num_cel=i;
        num_cel_input=i-1;
        if( i<nb_cels) then 
           num_cel_output=i+1;
           num_cel_suiv=i+1;
        else
           num_cel_output=0;
           num_cel_suiv=0;
        end 
        [l_one_cel]=get_pcaxe_one_cel_code(F_wi,num_cel,num_cel_input,num_cel_output,num_cel_suiv);
        l_code=lstcat(l_code,l_one_cel);       
    end
    all_code=new_code.all_code;
    all_code=lstcat(all_code,l_define);
    all_code=lstcat(all_code,l_code);
    new_code.all_code=all_code;
endfunction
