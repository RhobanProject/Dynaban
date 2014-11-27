//----------------------------------------------------------
// 0-COMPUTE PCAXE UNQUANTIFIED FILTER,
// PCAXE CODE GENERATION
// pcaxe_output is a scilab structure containing all relevant information
//----------------------------------------------------------
pcaxe_output=compute_pcaxe_filter(F_of_w,params);
if (typeof(pcaxe_output)~="list" ) then
    liste_pcaxe_outputs=list();
    liste_pcaxe_outputs(1)=pcaxe_output;
else
    liste_pcaxe_outputs=pcaxe_output;
end
code_pcaxe.name="code";
code_pcaxe.all_code=list();
for i=1:length(liste_pcaxe_outputs),
    output_i=liste_pcaxe_outputs(i);
    params_i=output_i.params;
    //     disp("-----caracteristics of filter :"+params_i.name_filter+"---");
        code_pcaxe=append_filter_to_pcaxe(code_pcaxe,output_i);
end //for i=1:length(liste_pcaxe_outputs),
    file_name=liste_pcaxe_outputs(1).params.file_name;
    write_list_to_file(code_pcaxe.all_code,file_name+".Sc1");
    disp(" pcaxe generated file is :"+file_name+".Sc1");

//----------------------------------------------------------
// 1-COMPUTE C LANGUAGE QUANTIFIED FILTER,
// C CODE GENERATION
// QUANTIFICATION,SCALING AND NOISE ANALYSIS
// c_output is a scilab structure containing all relevant information
//----------------------------------------------------------
c_output=compute_c_filter(F_of_w,params);
if (typeof(c_output)~="list" ) then
    liste_c_outputs=list();
    liste_c_outputs(1)=c_output;
else
    liste_c_outputs=c_output;
end
code_to_write=[];

for i=1:length(liste_c_outputs),
    c_output_i=liste_c_outputs(i);
    params_i=c_output_i.params;
    disp("-----caracteristics of filter :"+params_i.name_filter+"---");
    if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
        code_to_write=append_filter_to_c_code(code_to_write,c_output_i);
    else
        disp(" NO CODE GENERATED, CODE GENERATION ONLY FOR switch_form=df2 or state");
    end
    nb_cels=length(c_output_i.F_z);
    s=string(nb_cels)+" "+params_i.switch_structure;
    s=s+"  cels of type : "+params_i.switch_form;
    if params_i.switch_form=="state-space" then
        s =s+"("+params_i.switch_ss+")";
    end
    [degree_n,degree_d]=order_filter(c_output_i.F_z);
    disp("  degree numer="+string(degree_n)+",degree denom="+string(degree_d));

    // c_output levels due to input( see function functions_gene_code.sce->compute_c_filter)
    F_z_qtf=c_output_i.F_z_qtf;
    NBECHS_NORM=params_i.NBECHS_NORM;
    [N_z_qtf,D_z_qtf]=make_as_ND(F_z_qtf);
    max_s=c_output_i.output_levels.max_module_s;
    max_val_eff_s=c_output_i.output_levels.max_val_eff_s;
    ecart_type_s=c_output_i.output_levels.ecart_type_s;

    // affichage des resultats
    disp(" 1-  "+s);
    disp(" 2-  scaling norm= "+string(params_i.i_norm_scaling));
    if (params_i.is_paralell==%f) then
        // bug, cette info n'est valable que pour des structures cascade
        disp(" 3.1 max modulus        of useful c_output signal ="+string(max_s));
        disp(" 3.2 max eff. value     of useful c_output signal ="+string(max_val_eff_s));
        disp(" 3.3 standard-deviation of useful c_output signal  ="+string(ecart_type_s));
    end
    disp(" 4-  output noise (norme "+string(params_i.i_norm_analysis)+")="+string(c_output_i.output_noise)+" / " + string(2^(params_i.NB_BITS-1)-1));
    disp(" 5-  operator ="+params_i.switch_operateur);
end //for i=1:length(liste_c_outputs),
if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
    file_name=liste_c_outputs(1).params.file_name;
    name_filter=liste_c_outputs(1).params.name_filter;
    NB_BITS=liste_c_outputs(1).params.NB_BITS;
    code_to_write.header_list=get_header_c_code(name_filter,NB_BITS);
    write_list_to_file(code_to_write.header_list,file_name+".h");
    write_list_to_file(code_to_write.all_code,file_name+".c");
    write_list_to_file(code_to_write.int_code.all_code,file_name+"_int.c");
    write_list_to_file(code_to_write.float_code.all_code,file_name+"_float.c");
    disp(" C generated files are :"+file_name+".h, "+file_name+".c, "+file_name+"_int.c, "+file_name+"_float.c");
end
//-----------------------------------------------------------
// 2-TRACE DES RESPONSES FREQUENTIELLES
//-----------------------------------------------------------
v0_aff=max(v0_aff,1e-10);
v_aff=logspace(log10(v0_aff),log10(v1_aff),nb_points_aff);
f_aff=atan(v_aff)/%pi;
z_aff=exp(%i*2*%pi*f_aff);
for io=1:length(liste_c_outputs),
    output_i=liste_c_outputs(io);
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
        xset("window",io);clf(io);
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
//----------------------------------------------------------
// 3-COMPUTE VHDL QUANTIFIED FILTER,
// VHDL CODE GENERATION
// QUANTIFICATION,SCALING AND NOISE ANALYSIS
// vhdl_output is a scilab structure containing all relevant information
//----------------------------------------------------------
vhdl_output=compute_vhdl_filter(F_of_w,params);
if (typeof(vhdl_output)~="list" ) then
    liste_vhdl_outputs=list();
    liste_vhdl_outputs(1)=vhdl_output;
else
    liste_vhdl_outputs=vhdl_output;
end
code_vhdl.name="code";

for i=1:length(liste_vhdl_outputs),
    output_i=liste_vhdl_outputs(i);
    params_i=output_i.params;
    //     disp("-----caracteristics of filter :"+params_i.name_filter+"---");
    if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
        code_vhdl=append_filter_to_vhdl(code_vhdl,output_i);
    else
        //       disp(" NO CODE GENERATED, CODE GENERATION ONLY FOR switch_form=df2 ");
    end
    nb_cels=length(output_i.F_z);
    s=string(nb_cels)+" "+params_i.switch_structure;
    s=s+"  cels of type : "+params_i.switch_form;
    if params_i.switch_form=="state-space" then
        s =s+"("+params_i.switch_ss+")";
    end
    [degree_n,degree_d]=order_filter(output_i.F_z);
    //     disp("  degree numer="+string(degree_n)+",degree denom="+string(degree_d));

    // vhdl_output levels due to input( see function functions_gene_code.sce->compute_c_filter)
    F_z_qtf=output_i.F_z_qtf;
    NBECHS_NORM=params_i.NBECHS_NORM;
    [N_z_qtf,D_z_qtf]=make_as_ND(F_z_qtf);
    max_s=output_i.output_levels.max_module_s;
    max_val_eff_s=output_i.output_levels.max_val_eff_s;
    ecart_type_s=output_i.output_levels.ecart_type_s;

    // affichage des resultats
    //     disp(" 1-  "+s);
    //     disp(" 2-  scaling norm= "+string(params_i.i_norm_scaling));
    if (params_i.is_paralell==%f) then
        // bug, cette info n'est valable que pour des structures cascade
        //       disp(" 3.1 max modulus        of useful vhdl_output signal ="+string(max_s));
        //       disp(" 3.2 max eff. value     of useful vhdl_output signal ="+string(max_val_eff_s));
        //       disp(" 3.3 standard-deviation of useful vhdl_output signal  ="+string(ecart_type_s));
    end
    //     disp(" 4-  output noise (norme "+string(params_i.i_norm_analysis)+")="+string(output_i.output_noise));
    //     disp(" 5-  operator ="+params_i.switch_operateur);
end //for i=1:length(liste_vhdl_outputs),
if (params_i.switch_form=="df2")|(params_i.switch_form=="state-space") then
    file_name=liste_vhdl_outputs(1).params.file_name;
    write_list_to_file(code_vhdl.int_code.all_code,file_name+".vhd");
    disp(" vhdl generated file is :"+file_name+".vhd");
end

//----------------------------------------------------------------
// AFFICHAGE DES STRUCTURES
// UNCOMMENT TO DISPLAY THE FIELDS
//---------------------------------------------------------------
// output_i         // display vhdl_output structure
// output_i.params // display parameters of code generation