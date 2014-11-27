  function [lambda,max_x_e,norm_sb]=scale_cels(Nz,Dz,NBECH_NORM,i_norm_scaling,i_norm_analysis,use_power_of_2)
    [lhs,rhs]=argn(0);
    if rhs<6 then
      use_power_of_2=%t;
    end

    if rhs<5 then
      i_norm_analysis=1;
    end
    if rhs<4 then
      i_norm_scaling=1;
    end
    if rhs<3 then
      NBECH_NORM=200000;
    end
    [norm_sx,max_x_e]=clc_norm_sx(Nz,Dz,NBECH_NORM,i_norm_scaling);
    lambda=clc_lambda(max_x_e);
    if (use_power_of_2) then
      lambda=get_as_power_of_2(lambda);
    end
    [norm_seb,total_norm_sb]=clc_norm_s_eb(Nz,Dz,NBECH_NORM,i_norm_analysis);
    norm_sb=clc_norm_sb(norm_seb,lambda);
  endfunction
  function y=impulse_Fz(Fz,NBECH,type_of_list)
    [lhs,rhs]=argn(0);
   [Nz,Dz]=make_as_ND(Fz);
    if (rhs<2) then
      y=impulse_NzDz(Nz,Dz);
      return
    end
    if (rhs<3) then
      y=impulse_NzDz(Nz,Dz,NBECH);
      return
    end
    y=impulse_NzDz(Nz,Dz,NBECH,type_of_list);
  endfunction
  function y=impulse_NzDz(Nz,Dz,NBECH,type_of_list)
    [lhs,rhs]=argn(0);
    if (rhs<4) then
      type_of_list="matrix";
    end
    if (rhs<3) then
      y=filter_ND(Nz,Dz); // impulse by default
      return
    end
    pause
    fn=zeros(1,NBECH);fn(1)=1;
    y=filter_ND(Nz,Dz,fn,type_of_list); // impulse by default
  endfunction
  function y=filter_Fz(Fz,fn,type_of_list)
    [lhs,rhs]=argn(0);
    [Nz,Dz]=make_as_ND(Fz);
    if (rhs<2) then
      y=filter_ND(Nz,Dz);
      return
    end
    if (rhs<3) then
      y=filter_ND(Nz,Dz,fn);
      return
    end
    y=filter_ND(Nz,Dz,fn,type_of_list);
  endfunction

  function y=filter_ND(Nz,Dz,fn,type_of_list)
    [lhs,rhs]=argn(0);
    if (rhs<4) then
      type_of_list="matrix";
    end
    if (rhs<3) then
      fn=zeros(1,200000);fn(0)=1;
    end
    if (rhs<2) then
      error("too few parameters,rhs="+string(rhs));
    end
    if (typeof(Nz) == 'polynomial')|(typeof(Dz) == 'polynomial') then
      [m,n]=size(Nz);
      if (max([m,n])>1) then
        y=list();
        for i=1:m,
          y(i)=list();
          for j=1:n,
            y(i)(j)=filter_ND(Nz(i,j),Dz(i,j),fn);
          end
        end
        return
      end
      if (degree(Nz)>degree(Dz)) then
        error("non causal transfer function");
      end
      if (degree(Nz)==0)&(degree(Dz)==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=fn*(coeff(Nz,0)/coeff(Dz,0)); // delta_n=sequence impulsion
        return
      end
      rD=roots(Dz);
      if (rD~=[]) then
        if (max(abs(rD))>=1) then
          pause
          error("unstable function");
        end
      end
      Te=1;sys_Fz=syslin(Te,Nz,Dz);// conversion en fct de transfert discrete de periode Te=1
      y=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
      return
    end //    if typeof(Fz_1) == 'rational' then
    if (typeof(Dz) == 'constant') then
      y=fn*(coeff(Nz,0)/coeff(Dz,0));
      return
    end//    if typeof(Dz) == 'constant' then
    if typeof(Dz) == 'list' then
      fields=definedfields(Dz);
      is_cascade_list=(type_of_list=="cascade");
      is_paralell_list=(type_of_list=="paralell");
      if (is_cascade_list) then
        y=fn; // delta_n=sequence impulsion unite;
        fields=fields($:-1:1);
        i=find(fields>0);
        fields=fields(i);
        for i_f=fields,
          Nzi=Nz(i_f);Dzi=Dz(i_f);
          if ((degree(Nzi) ==0)&(degree(Dzi) ==0)) then
            y=y*(coeff(Nzi,0)/coeff(Dzi,0));
          else
              Te=1;sys_Fz=syslin(Te,Nzi,Dzi);// conversion en fct de transfert discrete de periode Te=1
              y=flts(y,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end //    if typeof(Fz_1i) == 'rational' then
        end //for i_f=length(Fz_1):-1:1,
        return
      end // if (is_cascade_list) then
      if (is_paralell_list) then
        fields=fields($:-1:1);
        i=find(fields>0);
        fields=fields(i);
        for i_f=fields,
          Nzi=Nz(i_f);Dzi=Dz(i_f);
          if ((degree(Nzi) ==0)&(degree(Dzi) ==0)) then
            y=y+(coeff(Nzi,0)/coeff(Dzi,0))*fn;
          else
            Te=1;sys_Fz=syslin(Te,Nzi,Dzi);// conversion en fct de transfert discrete de periode Te=1
            y=y+flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end //    if typeof(Fz_1i) == 'rational' then
        end //for i_f=length(Fz_1):-1:1,
        return
      end // if (is_paralell_list) then
   // case where list is not an ending cascade or paralell list
      y=list();
      for i=1:length(fields),
        ifd=fields(i);
        if (ifd>0) then
          y(ifd)=filter_ND(Nz(ifd),Dz(ifd),NBECH);
        end
      end
      return
    end //    if typeof(Fz_1) == 'list' then
    error('type d entree non gere');
  endfunction
  function norm_sb=clc_norm_sb(norm_s_eb,lambda)
  // norm_sb(i)=norm of output noise ( at the output of lambda[N+1)),
  // due to internal noises in cel(i)
  // whith scaling factors
    NB_F=length(norm_s_eb);
    lambda_glob=lambda(NB_F+1);// = 1 for normalized version
    norms_sb=zeros(NB_F,1);
    for i_f=NB_F:-1:1,
      nseb=norm_s_eb(i_f);
      i_b=definedfields(nseb);
      i_b=i_b(find(i_b>1)); // suppress effect of input(1) in noise analysis
      nsb=0;
      for ib=i_b,
        nsb=nsb+nseb(ib);
      end
      nsb=nsb*lambda_glob;
      norm_sb(i_f)=nsb;
      lambda_glob=lambda_glob*lambda(i_f);
    end
  endfunction

  function [norm_s_eb,total_norm_sb]=clc_norm_s_eb(Nz,Dz,NBECH_NORME,i_norm)
  // return a list whose first indice is the cell indice
  // l(i)(1  )=norm(output of cel i)
  // l(i)(j>1)=norm( of jeme internal var of cel i)
    [lhs,rhs]=argn(0);

    if (rhs<4) then
      i_norm=1;
    end
    if (rhs<3) then
      NBECH_NORME=200000;
    end

    NB_FES=length(Nz);
    if (i_norm==%inf) then
      xn=linspace(-%pi,%pi,NBECH_NORME);
      xn=exp(%i*xn);
      en=ones(xn); 
    else
      en=zeros(1,NBECH_NORME);en(1)=1; // en impulse response of Gafter =G(i+1).Gn
    end
    norm_s_eb=list();
    total=0;
    i_out=1;
    for i_f=NB_FES:-1:1,
      Nzi=Nz(i_f)(i_out); // only first output is considered
      Dzi=Dz(i_f)(i_out);
      i_b=definedfields(Nzi);
      i=find(i_b>=1); 
      i_b=i_b(i);
      norm_s=list();
      for ib=i_b,
        if( i_norm==%inf ) then
          s_de_bi=abs(horner(Nzi(ib),xn));
          s_de_bi=s_de_bi./abs(horner(Dzi(ib),xn));
          s_de_bi=s_de_bi.*en;
        else
          s_de_bi=filter_ND(Nzi(ib),Dzi(ib),en);
        end
        norm_s(ib)=norm(s_de_bi,i_norm);
        if (ib==1) then
           new_en=s_de_bi; //<=> Gafter=Gi . Gafter
        else
          total=total+norm_s(ib)^(i_norm);
        end
      end // for ib=i_b
      norm_s_eb(i_f)=norm_s;
      en=new_en; 
    end // for i_f=NB_F to 1
    total=total^(1/i_norm);
    if (lhs>=2) then
      total_norm_sb=total;
    end 
  endfunction
  function lambda=clc_lambda(max_x)
    lambda_glob=1;
    NB_F=length(max_x);
    lambda=zeros(NB_F+1,1);
    for i=1:NB_F,
      max_xi=max_x(i)*lambda_glob;
      lambda(i)=1/max_xi;
      lambda_glob=lambda_glob*lambda(i);
    end
    lambda(NB_F+1)=1/lambda_glob;
  endfunction
  function lambda_2=get_as_power_of_2(lambda)
    lambda_2=[];
    over_scale=1;
    l_glob=1;
    l2_glob=1;

    for i_l=1:(length(lambda)-1),
      li=lambda(i_l)
      l_glob=l_glob*li;
      l2=log2(l_glob/l2_glob);
      l2=floor(l2 +log2(2.0001/2));
      l2=2^l2;
      lambda_2=[lambda_2;l2];
      l2_glob=l2_glob*l2;
    end
    lambda_2=[lambda_2;1/l2_glob];
  endfunction
  function [norm_sx_e,max_x_e]=clc_norm_sx(Nz,Dz,NBECH_NORME,i_norm,switch_noise)
  // return a list whose first indice is the cell indice
  // l(i)(1  )=norm(output of cel i)
  // l(i)(j>1)=norm( of jeme internal var of cel i)

    [lhs,rhs]=argn(0);
    if (rhs<5) then
      switch_noise=%f;
    end
    if (switch_noise==%t) then
      error('sorry, not yet implemented');
    end
    if (rhs<4) then
      i_norm=1;
    end
    if (rhs<3) then
      NBECH_NORME=200000;
    end
    NB_FES=length(Nz); 
    norm_FES=list();
   // pass 1 : get norm of xi due to ei 
    NESz=list();
    DESz=list();
    if (i_norm==%inf) then
      xn=linspace(-%pi,%pi,NBECH_NORME);
      xn=exp(%i*xn);
      en=ones(xn);
    else
      en=zeros(1,NBECH_NORME);en(1)=1;
    end 
    norm_sx_e=list();
    max_x=list();
    for i_f=1:NB_FES,
      Nzi=Nz(i_f);
      Dzi=Dz(i_f);
      i_x=definedfields(Nzi);
      i=find(i_x>0);
      i_x=i_x(i);
      norm_x=list();
      max_xi=0;
      for ix=i_x,
        if (i_norm==%inf) then
          s_de_e=abs(horner(Nzi(ix)(1),xn));
          s_de_e=s_de_e./abs(horner(Dzi(ix)(1),xn));
          s_de_e=s_de_e.*en;
        else 
          s_de_e=filter_ND(Nzi(ix)(1),Dzi(ix)(1),en);
        end
        norm_x(ix)=norm(s_de_e,i_norm);
        if (ix==1) then
          new_en=s_de_e;
        else
          max_xi=max([max_xi,norm_x(ix)]);
        end
      end
      norm_sx_e(i_f)=norm_x;
      max_x(i_f)=max_xi;
      en=new_en;
    end
    if (lhs>=2) then
      max_x_e=max_x;
    end
    if switch_noise==%f then
      return
    end
  endfunction
  function [y,nbech_norm]=norme_ND(Nz,Dz,NBECH_NORM,i_norm,type_of_list)
    [lhs,rhs]=argn(0);
    if rhs<5 then
      type_of_list="matrix"; 
    end
    if (rhs<4) then
      i_norm=1;
    end
    if (rhs<3) then
      NBECH_NORM=compute_NBECH_NzDz(Nz,Dz);
    end
    if (rhs<2) then
      error("too few parameters,rhs="+string(rhs));
    end

    if (typeof(Nz) == 'polynomial')|(typeof(Dz) == 'polynomial') then
      [m,n]=size(Nz);
      if (max([m,n])>1) then
        y=zeros(m,n);
        for i=1:m,
          for j=1:n,
            y(i,j)=norme_ND(Nz(i,j),Dz(i,j),NBECH_NORM,i_norm);
          end
        end
        if (lhs>1) then
           nbech_norm=NBECH_NORM;
        end
        return
      end
      if (degree(Nz)>degree(Dz)) then
        error("non causal transfer function");
      end
      if (degree(Nz)==0)&(degree(Dz)==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=abs(coeff(Nz))/abs(coeff(Dz));
        if (lhs>1) then
           nbech_norm=NBECH_NORM;
        end
        return 
      end
      rD=roots(Dz);
      if (rD~=[]) then
        if (max(abs(rD))>=1) then
          error("unstable function");
        end
      end
      if (i_norm==%inf) then
      // compute max frequency response
        fn=linspace(0,%pi,NBECH_NORM);
        fn=exp(%i*fn);
        fn=horner(Nz,fn)./horner(Dz,fn);
        fn=abs(fn);
        y=norm(fn,i_norm);
      else
        fn=zeros(1,NBECH_NORM);fn(1)=1; // delta_n=sequence impulsion unite;
        Te=1;sys_Fz=syslin(Te,Nz,Dz);// conversion en fct de transfert discrete de periode Te=1
        fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
        y=norm(fn,i_norm); // norme1 de F(z) = somme (module(f(n))
      end
      return
    end //    if typeof(Fz_1) == 'rational' then
    if (typeof(Dz) == 'constant') then
      y=abs(coeff(Nz))./abs(coeff(Dz));
      if (lhs>1) then
         nbech_norm=NBECH_NORM;
      end
      return
    end//    if typeof(Dz) == 'constant' then
    if typeof(Dz) == 'list' then
      fields=definedfields(Dz);
      is_cascade_list=type_of_list=="cascade";
      is_paralell_list=type_of_list=="paralell";
      if (is_cascade_list) then
        if (i_norm==%inf) then
          xn=linspace(0,%pi,NBECH_NORM);
          xn=exp(%i*xn);
          fn=ones(xn);
        else
          fn=zeros(1,NBECH_NORM);fn(1)=1; // delta_n=sequence impulsion unite;
        end 
        fields=fields($:-1:1);
        i=find(fields>0);
        fields=fields(i);
        for i_f=fields,
          Nzi=Nz(i_f);Dzi=Dz(i_f);
          if ((degree(Nzi) ==0)&(degree(Dzi) ==0)) then
            fn=fn*coeff(Nzi,0)/coeff(Dzi,0);
          else
            if (i_norm==%inf) then
              yn=horner(Nzi,xn)./horner(Dzi,xn);
              fn=fn.*abs(yn);
            else
              Te=1;sys_Fz=syslin(Te,Nzi,Dzi);// conversion en fct de transfert discrete de periode Te=1
              fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
            end
          end //    if typeof(Fz_1i) == 'rational' then
        end //for i_f=length(Fz_1):-1:1,
        if (i_norm==2) then
          y=norm(fn,i_norm); // norme2 de F(z) = norme(fn,2)
        elseif(i_norm==1) then
          y=norm(fn,i_norm); // norme1 de F(z) = norme(fn,1)
        elseif(i_norm==%inf) then
          y=norm(fn,i_norm); // norme2 de F(z) = norme(F(exp(j.theta),%inf)
        else
          error("unknown norm");
        end  
        if (lhs>1) then
           nbech_norm=NBECH_NORM;
        end
        return
      end // if (is_cascade_list) then
      if (is_paralell_list) then
        if (i_norm==%inf) then
          xn=linspace(-%pi,%pi,NBECH_NORM);
          xn=exp(%i*xn);
          fn=ones(xn);
        else
          fn=zeros(1,NBECH_NORM);fn(1)=1; // delta_n=sequence impulsion unite;
        end 
        fields=fields($:-1:1);
        i=find(fields>0);
        fields=fields(i);
        for i_f=fields,
          Nzi=Nz(i_f);Dzi=Dz(i_f);
          if ((degree(Nzi) ==0)&(degree(Dzi) ==0)) then
            fn=fn+coeff(Nzi,0)/coeff(Dzi,0);
          else
            if (i_norm==%inf) then
              yn=horner(Nzi,xn)./horner(Dzi,xn);
              fn=fn+yn;
            else
              Te=1;sys_Fz=syslin(Te,Nzi,Dzi);// conversion en fct de transfert discrete de periode Te=1
              en=zeros(fn);en(1)=1;
              fn=fn+flts(en,sys_Fz);// fn=fn+=reponse impulsionnelle de F(z)
            end
          end //    if typeof(Fz_1i) == 'rational' then
        end //for i_f=length(Fz_1):-1:1,
        if (i_norm==2) then
          y=norm(fn,i_norm); // norme2 de F(z) = norme(fn,2)
        elseif(i_norm==1) then
          y=norm(fn,i_norm); // norme1 de F(z) = norme(fn,1)
        elseif(i_norm==%inf) then
          y=norm(fn,i_norm); // norme2 de F(z) = norme(F(exp(j.theta),%inf)
        else
          error("unknown norm");
        end  
        if (lhs>1) then
           nbech_norm=NBECH_NORM;
        end
        return
      end // if (is_cascade_list) then
   // case where list is a matrix
      y=list();
      for i=1:length(fields),
        ifd=fields(i);
        if (ifd>0) then
          y(ifd)=norme_ND(Nz(ifd),Dz(ifd),NBECH_NORM,i_norm);
        end
      end
      if (lhs>1) then
         nbech_norm=NBECH_NORM;
      end
      return
    end //    if typeof(Fz_1) == 'list' then
    error('type d entree non gere');
  endfunction
  function [y,nbech_norm]=norme_Fz(Fz,type_of_list,i_norm,NBECH_NORM)
    [lhs,rhs]=argn(0);
    if (rhs<4) then
      NBECH_NORM=compute_NBECH_Fz(F_z);
    end
    if (rhs<3) then
      i_norm=1;
    end 
    if (rhs<2) then
      type_of_list="matrix";
    end 
    [Nz,Dz]=make_as_ND(Fz);
    y=norme_ND(Nz,Dz,NBECH_NORM,i_norm,type_of_list);
    if (lhs>1) then
       nbech_norm=NBECH_NORM;
    end
  endfunction

  function integer_coeffs=get_integer_coeffs(coeffs,L)
    integer_coeffs=round(2^L * coeffs);
  endfunction
  function [L,integer_coeffs,quantified_coeffs]=get_scaled_coeffs(coeffs,NB_BITS,L_MAX)
    [lhs,rhs]=argn(0);
    if (rhs<3) then
      L_MAX=2^(NB_BITS);
    end
    max_abs_coeff_pos=2^(NB_BITS-1)-1;
    max_abs_coeff_neg=2^(NB_BITS-1);
    c_pos=max(coeffs);
    c_pos=max([0,c_pos]);
    c_neg=min(coeffs);
    c_neg=min([0,c_neg]);
    c_neg=abs(c_neg);
    if (max([c_neg,c_pos]))<=2^(1-2*NB_BITS) then
      L=0;integer_coeffs=zeros(coeffs);
      quantified_coeffs=zeros(coeffs);
      return;
    end
    if (c_pos>0) then
      L_c_pos=floor(log2(max_abs_coeff_pos/c_pos));
    else
     L_c_pos=%inf;
    end
    if (c_neg>0) then
      L_c_neg=floor(log2(max_abs_coeff_neg/c_neg));
    else
     L_c_neg=%inf;
    end
    L=min([L_c_pos,L_c_neg]);
    if (L>L_MAX) then
    // too little coeff, consider it is equal to zero
      L=0;integer_coeffs=zeros(coeffs);
      quantified_coeffs=zeros(coeffs);
    else
      integer_coeffs=round(2^L * coeffs) ;
      quantified_coeffs=2^(-L) * round( integer_coeffs);
    end
  endfunction
  function [cel_dir_form]=get_scaled_direct_form(F_x,switch_form,NB_BITS)
    F_x=normalize(F_x,"ld");
    nx=my_varn(F_x);
    if (nx==[]) then
      nx="x";
    end
    x=poly(0,nx);
    Bx=numer(F_x);
    Ax=denom(F_x);
    dg=max([degree(Bx),degree(Ax)]);
    cel_df=struct("NB_BITS",NB_BITS);
    cel_df.degre=dg;
    cel_df.forme=switch_form;
    cel_df.Fx=F_x;
    c_Bx=coeff(Bx);
    c_Ax=coeff(-Ax);
  //  icilesgars c_Ax=c_Ax(2:$); dangerous for programmation if coeffs near 0
    if (switch_form=="df2")|(switch_form=="df1") then
      [LBx,Bx_int,Bx_q]=get_scaled_coeffs(c_Bx,NB_BITS);
      [LAx,Ax_int,Ax_q]=get_scaled_coeffs(c_Ax,NB_BITS);
      cel_df.LB=LBx;
      cel_df.LA=LAx;
      cel_df.Bi_int=Bx_int;
      cel_df.moins_Ai_int=Ax_int(2:$);
      Bx_q=poly(Bx_q,nx,'coeff');
      cA=[1,-Ax_q(2:$)];
      Ax_q=poly(cA,nx,'coeff');
      osm=simp_mode();
      simp_mode(%f);
      Fx_q=Bx_q/Ax_q ;
      cel_df.Fx_q=Fx_q;
      simp_mode(osm);
      cel_dir_form=cel_df;
      return;
    end// df2 or df1 internal scaling
    if (switch_form=="df1t")|(switch_form=="df2t") then
      C_bq=[];
      for i=1:max(size((c_Bx))),
        [LBxi,Bx_inti,Bx_qi]=get_scaled_coeffs(c_Bx(i),NB_BITS);
        if (i==1) then
          cel_df.Lb0=LBxi;
          cel_df.b0_int=Bx_inti;
        elseif (i==2) then
          cel_df.Lb1=LBxi;
          cel_df.b1_int=Bx_inti;
        elseif (i==3) then
          cel_df.Lb2=LBxi;
          cel_df.b2_int=Bx_inti;
        else
          error("get_scaled_direct_form works only for second order sections");
        end
        C_bq=[C_bq,Bx_qi];
      end
      C_aq=[]; 
      for i=2:max(size((c_Ax))),
        [LAxi,Ax_inti,Ax_qi]=get_scaled_coeffs(c_Ax(i),NB_BITS);
        if (i==2) then
          cel_df.La1=LAxi;
          cel_df.moins_a1_int=Ax_inti;
        elseif (i==3) then
          cel_df.La2=LAxi;
          cel_df.moins_a2_int=Ax_inti;
        else
          error("get_scaled_direct_form works only for second order sections");
        end
        C_aq=[C_aq,-Ax_qi];
      end
      Bx_q=poly(C_bq,nx,'coeff');
      C_aq=[1,C_aq];
      Ax_q=poly(C_aq,nx,'coeff');
      osm=simp_mode();
      simp_mode(%f);
      Fx_q=Bx_q/Ax_q ;
      cel_df.Fx_q=Fx_q;
      simp_mode(osm);
      cel_dir_form=cel_df;
      return;
    end// df1t or df2t term to term internal scaling
    error("not yet implemented for "+ switch_form);
  endfunction
  function [cel_sst]=get_scaled_ss(sys_ss,NB_BITS)
    cel_ss=struct("forme","ss");
    cel_ss.sys_ss=sys_ss;
    cel_ss.NB_BITS=NB_BITS;  
    A=sys_ss.A;
    cel_ss.degre=max(size(A));
    B=sys_ss.B;
    C=sys_ss.C;
    D=sys_ss.D;
    [nx,tmp]=size(A);
    L_x=[];
    Aq=[];Bq=[];
    Aint=[];Bint=[];
    for i=1:nx,
      AB_i=[A(i,:),B(i,:)];
      [Lxi,ABint_i,ABq_i]=get_scaled_coeffs(AB_i,NB_BITS);
      L_x=[L_x;Lxi];
      Aqi=ABq_i(1,1:nx);
      Bqi=ABq_i(1,(nx+1):$);
      Aq=[Aq;Aqi];
      Bq=[Bq;Bqi];
      Ainti=ABint_i(1,1:nx);
      Binti=ABint_i(1,(nx+1):$);
      Aint=[Aint;Ainti];
      Bint=[Bint;Binti];
    end
    [L_s,CDint,CDq]=get_scaled_coeffs([C,D],NB_BITS);
    Cq=CDq(1:nx);
    Dq=CDq((nx+1):$);
    Cint=CDint(1:nx);
    Dint=CDint((nx+1):$);
    cel_ss.L_x=L_x;
    cel_ss.L_s=L_s;
    sys_q=sys_ss;
    sys_q.A=Aq;
    sys_q.B=Bq;
    sys_q.C=Cq;
    sys_q.D=Dq;
    cel_ss.sys_ss_q=sys_q;
    cel_ss.Aint=Aint;
    cel_ss.Bint=Bint;
    cel_ss.Cint=Cint;
    cel_ss.Dint=Dint;
    cel_sst=cel_ss;
  endfunction
  function NBECH=compute_NBECH_from_mag(mag_p)
      i=find(mag_poles_z>=1);
      if (i~=[]) then
        NBECH=%inf;
        return
      end
      i=find((mag_p>1e-9)&(mag_p<1));
      mag_p=mag_p(i);
      if (mag_p==[]) then
        NBECH=10;
        return
      else
        rho_p=max(mag_p);
        rho_p=max([rho_p,0.1]); // for too little time_constant
        time_constant=-1/log(rho_p);
        NBECH=max([10*time_constant,10]);
        NBECH=ceil(NBECH);
      end
  endfunction
  function NBECH=compute_NBECH_zp_in_z(poles_z,zeros_z)

      mag_poles_z=abs(poles_z);
      NBECH_poles=compute_NBECH_from_mag(mag_poles_z);
      mag_zeros_z=abs(zeros_z);
      i=find(mag_zeros_z>=1);
      if (i~=[]) then
      // spectral factorization of unstable zeros
        mag_zeros_z(i)=ones(mag_zeros_z(i))./mag_zeros_z(i);
      end
      NBECH_zeros=compute_NBECH_from_mag(mag_zeros_z);
      NBECH_zeros=min(NBECH_zeros,10*NBECH_poles);
      NBECH=max([NBECH_zeros,NBECH_poles]);
  endfunction
  function [z,p]=get_zeros_poles(F)
    z=[];p=[];
    if (typeof(F)~="list") then
    // rational, polynomial or constant 
      [m,n]=size(F);
      for i=1:m,
        for j=1:n,
          Fij=F(i,j);
          z=[z;roots(numer(Fij))];
          p=[p;roots(denom(Fij))];
        end
      end
      return
    end
    // list
    ifd=definedfields(F);
    for i=ifd,
      [zi,pi]=get_zeros_poles(F(i));
      z=[z;zi];
      p=[p;pi];
    end
  endfunction 
  function NBECH=compute_NBECH_NzDz(Nz,Dz)
    [zeros_z,tmp]=get_zeros_poles(Nz);
    [tmp,poles_z]=get_zeros_poles(Dz);
    NBECH=compute_NBECH_zp_in_z(poles_z,zeros_z);
  endfunction
  function NBECH=compute_NBECH_Fz(F_z)
    [zeros_z,poles_z]=get_zeros_poles(F_z);
    NBECH=compute_NBECH_zp_in_z(poles_z,zeros_z);
  endfunction
  function NBECH=compute_NBECH_Fw(F_w)
      [zeros_w,poles_w]=get_zeros_poles(F_w);
      
      w=poly(0,"w");
      z_de_w=(1+w)/(1-w);
      poles_z=hornerij(z_de_w,poles_w);
      zeros_z=hornerij(z_de_w,zeros_w);
      NBECH=compute_NBECH_zp_in_z(poles_z,zeros_z);
  endfunction
