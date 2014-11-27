function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_direct_form(switch_form,lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
  if (b2x~=0)|(a2x~=0) then
     order=2;
  elseif (b1x~=0)|(a1x~=0)
    order=1;
  else
    order=0;
  end
  if (order==0) then
  // all implementations are the same for a pure gain 
  // s=1/lambda.[lambda.b0x.e1+e2]
  // x=lambda.e1

    [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df_0(lambda,b0x);
    return
  end
  if (switch_form=="df1") then
    if (order==1) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
       return
    end
    if (order==2) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
      return;
    end
    error("bad order for df1");
  end
 if (switch_form=="df1t") then
    if (order==1) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1t_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
       return
    end
    if (order==2) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1t_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
      return;
    end
    error("bad order for df1t");
  end
  if (switch_form=="df2") then
    if (order==1) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
       return
    end
    if (order==2) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
      return;
    end
    error("bad order for df2");
  end
 if (switch_form=="df2t") then
    if (order==1) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2t_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
       return
    end
    if (order==2) then
       [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2t_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
      return;
    end
    error("bad order for df2t");
  end
  error("switch_form must be in :df1,df1t,df2 or df2t");


endfunction

function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=4;n=5;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = -b0x
      t2 = -b1x*b0x_de_z-b0x*a0x_de_z+t1
      t3 = -b1x
      t4 = -b1x*a0x_de_z
      t5 = t4+t3
      t6 = a1x*a0x_de_z
      t7 = t6+a1x
      t8 = -a0x_de_z
      t9 = t8-1
      t10 = -b0x_de_z
      t11 = b0x*a0x_de_z
      t12 = b0x_de_z^2
      t13 = b1x*t12
      t14 = t13+(t11+b0x)*b0x_de_z
      t15 = -b1x*b0Fqz*b0x_de_z
      t16 = b1x*b0x_de_z+t11+t1
      t17 = a0x_de_z-1
      t18 = -2*b1x*t12-2*b0x*a0x_de_z*b0x_de_z
      t19 = t6-a1x
      t20 = t13+(t11+t1)*b0x_de_z
      t21 = -a1x*b0x_de_z+t8-1
      t22 = t21*lambda
      t23 = -a0Fqz
      t24 = -a0Fqz*a0x_de_z
      t25 = -a1x*a0Fqz
      t26 = (t25-a1x*a1Fqz)*b0x_de_z+t9*a1Fqz+t24+t23
      t27 = t26*lambda
      t28 = a0x_de_z^2
      t29 = t7*b0x_de_z+t28+2*a0x_de_z+1
      t30 = a1x*b0x_de_z+a0x_de_z-1
      t31 = t30*lambda
      t32 = 2*a1x*a0Fqz*b0x_de_z-2*a1Fqz+2*a0Fqz*a0x_de_z
      t33 = t32*lambda
      t34 = -2*a1x*a0x_de_z*b0x_de_z-2*t28+2
      t35 = (a1x*a1Fqz+t25)*b0x_de_z+t17*a1Fqz+t24+a0Fqz
      t36 = t35*lambda
      t37 = t19*b0x_de_z+t28-2*a0x_de_z+1
      N0w(1,1) = t2
      N0w(1,2) = t2
      N0w(1,3) = t5*b1Fqz+t5*b0Fqz
      N0w(1,4) = t7*b1Fqz+t7*b0Fqz
      N0w(1,5) = t9
      N0w(2,1) = lambda
      N0w(2,2) = 1
      N0w(3,1) = -b0x_de_z*lambda
      N0w(3,2) = t10
      N0w(3,3) = b1Fqz+b0Fqz
      N0w(4,1) = t14*lambda
      N0w(4,2) = t14
      N0w(4,3) = t15-b1x*b0x_de_z*b1Fqz
      N0w(4,4) = t9*b1Fqz+t9*b0Fqz
      N0w(4,5) = t10
      N1w(1,1) = t16
      N1w(1,2) = t16
      N1w(1,3) = 2*b1x*a0x_de_z*b0Fqz-2*b1x*b1Fqz
      N1w(1,4) = 2*a1x*b1Fqz-2*a1x*a0x_de_z*b0Fqz
      N1w(1,5) = t17
      N1w(3,1) = b0x_de_z*lambda
      N1w(3,2) = b0x_de_z
      N1w(3,3) = b1Fqz-b0Fqz
      N1w(4,1) = t18*lambda
      N1w(4,2) = t18
      N1w(4,3) = 2*b1x*b0Fqz*b0x_de_z
      N1w(4,4) = 2*a0x_de_z*b0Fqz-2*b1Fqz
      N1w(4,5) = b0x_de_z
      N2w(1,3) = (b1x*a0x_de_z+t3)*b1Fqz+(t4+b1x)*b0Fqz
      N2w(1,4) = (a1x-a1x*a0x_de_z)*b1Fqz+t19*b0Fqz
      N2w(4,1) = t20*lambda
      N2w(4,2) = t20
      N2w(4,3) = b1x*b0x_de_z*b1Fqz+t15
      N2w(4,4) = t17*b1Fqz+(t8+1)*b0Fqz
      D0w(1,1) = t21
      D0w(1,2) = t22
      D0w(1,3) = t27
      D0w(1,4) = t27
      D0w(1,5) = t22
      D0w(2,1) = 1
      D0w(2,2) = 1
      D0w(2,3) = 1
      D0w(2,4) = 1
      D0w(2,5) = 1
      D0w(3,1) = t9
      D0w(3,2) = t9
      D0w(3,3) = a1Fqz+a0Fqz
      D0w(3,4) = 1
      D0w(3,5) = 1
      D0w(4,1) = t29
      D0w(4,2) = t29
      D0w(4,3) = t26
      D0w(4,4) = t26
      D0w(4,5) = t21
      D1w(1,1) = t30
      D1w(1,2) = t31
      D1w(1,3) = t33
      D1w(1,4) = t33
      D1w(1,5) = t31
      D1w(3,1) = t17
      D1w(3,2) = t17
      D1w(3,3) = a1Fqz+t23
      D1w(4,1) = t34
      D1w(4,2) = t34
      D1w(4,3) = t32
      D1w(4,4) = t32
      D1w(4,5) = t30
      D2w(1,3) = t36
      D2w(1,4) = t36
      D2w(4,1) = t37
      D2w(4,2) = t37
      D2w(4,3) = t35
      D2w(4,4) = t35
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
endfunction
function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=3;n=4;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = -b0x
      t2 = -b1x*b0x_de_z-b0x*a0x_de_z+t1
      t3 = a1x*b0x
      t4 = -b1x
      t5 = (t4+t3)*a0x_de_z
      t6 = t5+t4+t3
      t7 = -a0x_de_z
      t8 = t7-1
      t9 = a1x*a0x_de_z
      t10 = t9+a1x
      t11 = b1x*b0x_de_z+b0x*a0x_de_z+t1
      t12 = a0x_de_z-1
      t13 = -a1x*b0x
      t14 = -a1x*b0x_de_z+t7-1
      t15 = -a0Fqz*a0x_de_z
      t16 = -a1x*a0Fqz
      t17 = (t16-a1x*a1Fqz)*b0x_de_z+t8*a1Fqz+t15-a0Fqz
      t18 = a1x*b0x_de_z+a0x_de_z-1
      t19 = 2*a1x*a0Fqz*b0x_de_z-2*a1Fqz+2*a0Fqz*a0x_de_z
      t20 = (a1x*a1Fqz+t16)*b0x_de_z+t12*a1Fqz+t15+a0Fqz
      N0w(1,1) = t2
      N0w(1,2) = t2
      N0w(1,3) = t6*b1Fqz+t6*b0Fqz
      N0w(1,4) = 1
      N0w(2,1) = t8*lambda
      N0w(2,2) = t8
      N0w(2,3) = t10*b1Fqz+t10*b0Fqz
      N0w(3,1) = -b0x_de_z*lambda
      N0w(3,2) = -b0x_de_z
      N0w(3,3) = t8*b1Fqz+t8*b0Fqz
      N1w(1,1) = t11
      N1w(1,2) = t11
      N1w(1,3) = (2*a1x*b0x-2*b1x)*b1Fqz+(2*b1x-2*a1x*b0x)*a0x_de_z*b0Fqz
      N1w(2,1) = t12*lambda
      N1w(2,2) = t12
      N1w(2,3) = 2*a1x*b1Fqz-2*a1x*a0x_de_z*b0Fqz
      N1w(3,1) = b0x_de_z*lambda
      N1w(3,2) = b0x_de_z
      N1w(3,3) = 2*a0x_de_z*b0Fqz-2*b1Fqz
      N2w(1,3) = ((b1x+t13)*a0x_de_z+t4+t3)*b1Fqz+(t5+b1x+t13)*b0Fqz
      N2w(2,3) = (a1x-a1x*a0x_de_z)*b1Fqz+(t9-a1x)*b0Fqz
      N2w(3,3) = t12*b1Fqz+(t7+1)*b0Fqz
      D0w(1,1) = t14
      D0w(1,2) = t14*lambda
      D0w(1,3) = t17*lambda
      D0w(1,4) = lambda
      D0w(2,1) = t14
      D0w(2,2) = t14
      D0w(2,3) = t17
      D0w(2,4) = 1
      D0w(3,1) = t14
      D0w(3,2) = t14
      D0w(3,3) = t17
      D0w(3,4) = 1
      D1w(1,1) = t18
      D1w(1,2) = t18*lambda
      D1w(1,3) = t19*lambda
      D1w(2,1) = t18
      D1w(2,2) = t18
      D1w(2,3) = t19
      D1w(3,1) = t18
      D1w(3,2) = t18
      D1w(3,3) = t19
      D2w(1,3) = t20*lambda
      D2w(2,3) = t20
      D2w(3,3) = t20
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
endfunction
function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df_0(lambda,b0x)
     m=2;n=2;
     Zr= zeros(m,n);
     N0w= Zr;
     D0w = ones(Zr);
     N0w(1,1)=b0x;     // e1-> s1
     N0w(1,2)=1/lambda;// e2-> s1
     N0w(2,1)=lambda;  // e1-> x
     N0w(2,2)=0;       // e2-> x
     Nw=real(N0w);
     Dw=real(D0w);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Nw(1)(1)=b0x; 
     Dw(1)(1)=1; 
     Nz=Nw;Dz=Dw;
     Nz_1=Nw;Dz_1=Dw;

endfunction

function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1t_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=2;n=7;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = -b0x
      t2 = -b0x*a0x_de_z
      t3 = -b1x*b0x_de_z+t2+t1
      t4 = -b1x*b0Fqz*b0x_de_z
      t5 = b0x*a0x_de_z
      t6 = b0x_de_z^2
      t7 = b1x*t6
      t8 = -b0x_de_z
      t9 = -a0x_de_z
      t10 = t9-1
      t11 = t10*lambda
      t12 = b1x*b0x_de_z+t5+t1
      t13 = a0x_de_z-1
      t14 = t13*lambda
      t15 = -a1x*b0x_de_z+t9-1
      t16 = -a0Fqz
      t17 = -a0Fqz*a0x_de_z
      t18 = -a1x*a0Fqz
      t19 = (t18-a1x*a1Fqz)*b0x_de_z+t10*a1Fqz+t17+t16
      t20 = a0x_de_z^2
      t21 = a1x*a0x_de_z
      t22 = a1x*b0x_de_z+a0x_de_z-1
      t23 = 2*a1x*a0Fqz*b0x_de_z-2*a1Fqz+2*a0Fqz*a0x_de_z
      t24 = (a1x*a1Fqz+t18)*b0x_de_z+t13*a1Fqz+t17+a0Fqz
      N0w(1,1) = t3
      N0w(1,2) = t3
      N0w(1,3) = t3*b1Fqz+t4+(t2+t1)*b0Fqz
      N0w(1,4) = t7+(t5+b0x)*b0x_de_z
      N0w(1,5) = t8
      N0w(1,6) = b1Fqz+b0Fqz
      N0w(1,7) = 1
      N0w(2,1) = t11
      N0w(2,2) = t10
      N0w(2,3) = t10*b1Fqz+t10*b0Fqz
      N0w(2,4) = t8
      N1w(1,1) = t12
      N1w(1,2) = t12
      N1w(1,3) = -2*b0x*b1Fqz+2*b1x*b0Fqz*b0x_de_z+2*b0x*a0x_de_z*b0Fqz
      N1w(1,4) = -2*b1x*t6-2*b0x*a0x_de_z*b0x_de_z
      N1w(1,5) = b0x_de_z
      N1w(1,6) = b1Fqz-b0Fqz
      N1w(2,1) = t14
      N1w(2,2) = t13
      N1w(2,3) = 2*a0x_de_z*b0Fqz-2*b1Fqz
      N1w(2,4) = b0x_de_z
      N2w(1,3) = t12*b1Fqz+t4+(t2+b0x)*b0Fqz
      N2w(1,4) = t7+(t5+t1)*b0x_de_z
      N2w(2,3) = t13*b1Fqz+(t9+1)*b0Fqz
      D0w(1,1) = t15
      D0w(1,2) = t15*lambda
      D0w(1,3) = t19*lambda
      D0w(1,4) = ((t21+a1x)*b0x_de_z+t20+2*a0x_de_z+1)*lambda
      D0w(1,5) = t11
      D0w(1,6) = (a1Fqz+a0Fqz)*lambda
      D0w(1,7) = lambda
      D0w(2,1) = t15
      D0w(2,2) = t15
      D0w(2,3) = t19
      D0w(2,4) = t15
      D0w(2,5) = 1
      D0w(2,6) = 1
      D0w(2,7) = 1
      D1w(1,1) = t22
      D1w(1,2) = t22*lambda
      D1w(1,3) = t23*lambda
      D1w(1,4) = (-2*a1x*a0x_de_z*b0x_de_z-2*t20+2)*lambda
      D1w(1,5) = t14
      D1w(1,6) = (a1Fqz+t16)*lambda
      D1w(2,1) = t22
      D1w(2,2) = t22
      D1w(2,3) = t23
      D1w(2,4) = t22
      D2w(1,3) = t24*lambda
      D2w(1,4) = ((t21-a1x)*b0x_de_z+t20-2*a0x_de_z+1)*lambda
      D2w(2,3) = t24
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
endfunction
function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2t_1(lambda,..
        b0x,b1x,a1x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=3;n=5;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = -b0x
      t2 = -b1x*b0x_de_z-b0x*a0x_de_z+t1
      t3 = -a0x_de_z
      t4 = t3-1
      t5 = -b0x_de_z
      t6 = t4*b1Fqz+t4*b0Fqz
      t7 = b1x*b0x_de_z+b0x*a0x_de_z+t1
      t8 = a0x_de_z-1
      t9 = 2*a0x_de_z*b0Fqz-2*b1Fqz
      t10 = t8*b1Fqz+(t3+1)*b0Fqz
      t11 = -a1x*b0x_de_z+t3-1
      t12 = t11*lambda
      t13 = -a0Fqz*a0x_de_z
      t14 = -a1x*a0Fqz
      t15 = (t14-a1x*a1Fqz)*b0x_de_z+t4*a1Fqz+t13-a0Fqz
      t16 = a1x*b0x_de_z+a0x_de_z-1
      t17 = t16*lambda
      t18 = 2*a1x*a0Fqz*b0x_de_z-2*a1Fqz+2*a0Fqz*a0x_de_z
      t19 = (a1x*a1Fqz+t14)*b0x_de_z+t8*a1Fqz+t13+a0Fqz
      N0w(1,1) = t2
      N0w(1,2) = t2
      N0w(1,3) = t4
      N0w(1,4) = t5
      N0w(1,5) = t6
      N0w(2,1) = lambda
      N0w(2,2) = 1
      N0w(3,1) = t2*lambda
      N0w(3,2) = t2
      N0w(3,3) = t4
      N0w(3,4) = t5
      N0w(3,5) = t6
      N1w(1,1) = t7
      N1w(1,2) = t7
      N1w(1,3) = t8
      N1w(1,4) = b0x_de_z
      N1w(1,5) = t9
      N1w(3,1) = t7*lambda
      N1w(3,2) = t7
      N1w(3,3) = t8
      N1w(3,4) = b0x_de_z
      N1w(3,5) = t9
      N2w(1,5) = t10
      N2w(3,5) = t10
      D0w(1,1) = t11
      D0w(1,2) = t12
      D0w(1,3) = t12
      D0w(1,4) = t12
      D0w(1,5) = t15*lambda
      D0w(2,1) = 1
      D0w(2,2) = 1
      D0w(2,3) = 1
      D0w(2,4) = 1
      D0w(2,5) = 1
      D0w(3,1) = t11
      D0w(3,2) = t11
      D0w(3,3) = t11
      D0w(3,4) = t11
      D0w(3,5) = t15
      D1w(1,1) = t16
      D1w(1,2) = t17
      D1w(1,3) = t17
      D1w(1,4) = t17
      D1w(1,5) = t18*lambda
      D1w(3,1) = t16
      D1w(3,2) = t16
      D1w(3,3) = t16
      D1w(3,4) = t16
      D1w(3,5) = t18
      D2w(1,5) = t19*lambda
      D2w(3,5) = t19
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
endfunction

function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=6;n=7;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = 2*b0x*a0x_de_z
      t2 = a0x_de_z^2
      t3 = b0x*t2
      t4 = b1x*a0x_de_z
      t5 = t4+b1x
      t6 = t5*b0x_de_z
      t7 = b0x_de_z^2
      t8 = b2x*t7
      t9 = t8+t6+t3+t1+b0x
      t10 = 2*b1x*a0x_de_z
      t11 = b1x*t2
      t12 = b2x*a0x_de_z
      t13 = t12+b2x
      t14 = t13*b0Fqz*b0x_de_z
      t15 = 2*b2x*a0x_de_z
      t16 = b2x*t2
      t17 = t16+t15+b2x
      t18 = -a1x
      t19 = -2*a1x*a0x_de_z
      t20 = -a1x*t2
      t21 = t20+t19+t18
      t22 = -a2x
      t23 = -a2x*a0x_de_z
      t24 = t23+t22
      t25 = t24*b0Fqz*b0x_de_z
      t26 = -2*a2x*a0x_de_z
      t27 = -a2x*t2
      t28 = t27+t26+t22
      t29 = 2*a0x_de_z
      t30 = t2+t29+1
      t31 = b1Fqz+b0Fqz
      t32 = t7*lambda
      t33 = -b0Fqz*b0x_de_z
      t34 = -b0x
      t35 = -2*b0x*a0x_de_z
      t36 = -b1x
      t37 = -b1x*a0x_de_z
      t38 = t37+t36
      t39 = t38*t7
      t40 = b0x_de_z^3
      t41 = -b2x*t40
      t42 = t41+t39+(-b0x*t2+t35+t34)*b0x_de_z
      t43 = b2x*b0Fqz*t7
      t44 = t30*b0Fqz
      t45 = a0x_de_z+1
      t46 = b0x_de_z^4
      t47 = b2x*t46
      t48 = t47+t5*t40+(t3+t1+b0x)*t7
      t49 = -b2x*b0Fqz*t40
      t50 = b2x*t7*b1Fqz
      t51 = a1x*a0x_de_z
      t52 = t51+a1x
      t53 = t52*b0x_de_z
      t54 = -2*b2x*t7-2*b1x*a0x_de_z*b0x_de_z-2*b0x*t2+2*b0x
      t55 = -2*b1x*a0x_de_z
      t56 = -b2x
      t57 = (t56-3*b2x*a0x_de_z)*b0Fqz*b0x_de_z
      t58 = 3*b1x
      t59 = -b1x*t2
      t60 = -b2x*a0x_de_z
      t61 = t60+b2x
      t62 = -2*b2x*a0x_de_z
      t63 = 3*b2x
      t64 = -b2x*t2
      t65 = 2*a1x*a0x_de_z
      t66 = 3*a1x*t2
      t67 = t66+t65+t18
      t68 = 3*a2x*a0x_de_z+a2x
      t69 = t68*b0Fqz*b0x_de_z
      t70 = -3*a1x
      t71 = a1x*t2
      t72 = a2x*a0x_de_z
      t73 = t72+t22
      t74 = 2*a2x*a0x_de_z
      t75 = -3*a2x
      t76 = a2x*t2
      t77 = -2*t2
      t78 = t77+2
      t79 = b1Fqz-b0Fqz
      t80 = -2*t7
      t81 = 3*b1x*a0x_de_z
      t82 = 3*b2x*t40+(t81+b1x)*t7+(3*b0x*t2+t1+t34)*b0x_de_z
      t83 = -3*b1x*a0x_de_z
      t84 = -3*b2x*b0Fqz*t7
      t85 = t37+b1x
      t86 = -b2x*t7
      t87 = -2*a0x_de_z
      t88 = -3*t2
      t89 = (t88+t87+1)*b0Fqz
      t90 = -t2
      t91 = t90+t29+3
      t92 = -4*b0x*t2
      t93 = -2*b1x
      t94 = -4*b1x*a0x_de_z
      t95 = -4*b2x*t46
      t96 = t95+(t94+t93)*t40+(t92-4*b0x*a0x_de_z)*t7
      t97 = 2*b1x
      t98 = 4*b1x*a0x_de_z
      t99 = 4*b2x*b0Fqz*t40
      t100 = -b2x*t7*b1Fqz
      t101 = -3*a0x_de_z
      t102 = -a0x_de_z
      t103 = t102+1
      t104 = -a1x*a0x_de_z
      t105 = t104+a1x
      t106 = t4+t36
      t107 = t106*b0x_de_z
      t108 = t8+t107+t3+t35+b0x
      t109 = (3*b2x*a0x_de_z+t56)*b0Fqz*b0x_de_z
      t110 = t60+t56
      t111 = -3*a1x*t2
      t112 = t111+t65+a1x
      t113 = a2x-3*a2x*a0x_de_z
      t114 = t113*b0Fqz*b0x_de_z
      t115 = t72+a2x
      t116 = t2+t87+1
      t117 = -3*b2x*t40+(t83+b1x)*t7+(-3*b0x*t2+t1+b0x)*b0x_de_z
      t118 = 3*b2x*b0Fqz*t7
      t119 = 3*t2
      t120 = (t119+t87-1)*b0Fqz
      t121 = t90+t87+3
      t122 = a0x_de_z-1
      t123 = 6*b2x*t46+6*b1x*a0x_de_z*t40+(6*b0x*t2-2*b0x)*t7
      t124 = 3*a0x_de_z
      t125 = t102-1
      t126 = 3*a1x*a0x_de_z
      t127 = t104+t18
      t128 = t61*b0Fqz*b0x_de_z
      t129 = t12+t56
      t130 = t71+t19+a1x
      t131 = t73*b0Fqz*b0x_de_z
      t132 = t23+a2x
      t133 = t76+t26+a2x
      t134 = t3+t35+b0x
      t135 = t106*t7
      t136 = b2x*t40
      t137 = t136+t135+t134*b0x_de_z
      t138 = -b2x*b0Fqz*t7
      t139 = (t90+t29-1)*b0Fqz
      t140 = t95+(t94+t97)*t40+(t92+4*b0x*a0x_de_z)*t7
      t141 = t51+t18
      t142 = t141*b0x_de_z
      t143 = t47+t106*t40+t134*t7
      t144 = a2x*t7
      t145 = t144+t53+t2+t29+1
      t146 = t145*lambda
      t147 = 2*a0Fqz*a0x_de_z
      t148 = a1x*a0Fqz
      t149 = a2x*a0Fqz
      t150 = a2x*a1Fqz
      t151 = (t150+t149)*t7+(t52*a1Fqz+a1x*a0Fqz*a0x_de_z+t148)*b0x_de_z+t30..
        *a1Fqz+a0Fqz*t2+t147+a0Fqz
      t152 = t151*lambda
      t153 = a1Fqz+a0Fqz
      t154 = -a0Fqz
      t155 = -a0Fqz*a0x_de_z
      t156 = a0x_de_z^3
      t157 = -t156
      t158 = t24*t7+t21*b0x_de_z+t157+t88+t101-1
      t159 = 6*t2
      t160 = a0x_de_z^4
      t161 = a1x*t156
      t162 = (t76+t74+a2x)*t7+(t161+t66+t126+a1x)*b0x_de_z+t160+4*t156+t159..
        +4*a0x_de_z+1
      t163 = -3*a0Fqz*a0x_de_z
      t164 = -3*a0Fqz*t2
      t165 = -a0Fqz*t156
      t166 = -a1x*a0Fqz
      t167 = -a1x*a0Fqz*t2
      t168 = -a2x*a0Fqz
      t169 = -a2x*a0Fqz*a0x_de_z
      t170 = -2*a2x*t7-2*a1x*a0x_de_z*b0x_de_z+t77+2
      t171 = t170*lambda
      t172 = -2*a0Fqz*a0x_de_z
      t173 = -a2x*a1Fqz
      t174 = (t173-3*a2x*a0Fqz)*t7+(t105*a1Fqz-3*a1x*a0Fqz*a0x_de_z+t166)..
        *b0x_de_z+t91*a1Fqz+t164+t172+a0Fqz
      t175 = t174*lambda
      t176 = a1Fqz+t154
      t177 = t68*t7+t67*b0x_de_z+3*t156+t119+t101-3
      t178 = -4*t160
      t179 = 2*a1x
      t180 = -4*a1x*t156
      t181 = -4*a2x*t2
      t182 = (t181-4*a2x*a0x_de_z)*t7+(t180-6*a1x*t2+t179)*b0x_de_z+t178-8*t156..
        +8*a0x_de_z+4
      t183 = 4*a0Fqz*t156
      t184 = 4*a1x*a0Fqz*t2
      t185 = -2*a1x
      t186 = 4*a2x*a0Fqz*a0x_de_z
      t187 = t144+t142+t2+t87+1
      t188 = t187*lambda
      t189 = 3*a0Fqz*t2
      t190 = (t173+3*a2x*a0Fqz)*t7+(t127*a1Fqz+3*a1x*a0Fqz*a0x_de_z+t166)..
        *b0x_de_z+t121*a1Fqz+t189+t172+t154
      t191 = t190*lambda
      t192 = t113*t7+t112*b0x_de_z-3*t156+t119+t124-3
      t193 = (6*a2x*t2-2*a2x)*t7+(6*a1x*t156-6*a1x*a0x_de_z)*b0x_de_z+6*t160..
        -12*t2+6
      t194 = (t150+t168)*t7+(t141*a1Fqz-a1x*a0Fqz*a0x_de_z+t148)*b0x_de_z+t116..
        *a1Fqz-a0Fqz*t2+t147+t154
      t195 = t194*lambda
      t196 = t73*t7+t130*b0x_de_z+t156+t88+t124-1
      t197 = (t181+4*a2x*a0x_de_z)*t7+(t180+6*a1x*t2+t185)*b0x_de_z+t178+8*t156..
        -8*a0x_de_z+4
      t198 = t133*t7+(t161+t111+t126+t18)*b0x_de_z+t160-4*t156+t159-4*a0x_de_z..
        +1
      N0w(1,1) = t9
      N0w(1,2) = t9
      N0w(1,3) = (t13*b0x_de_z+t11+t10+b1x)*b1Fqz+t14+(t11+t10+b1x)*b0Fqz
      N0w(1,4) = t17*b1Fqz+t17*b0Fqz
      N0w(1,5) = (t24*b0x_de_z+t20+t19+t18)*b1Fqz+t25+t21*b0Fqz
      N0w(1,6) = t28*b1Fqz+t28*b0Fqz
      N0w(1,7) = t30
      N0w(2,1) = lambda
      N0w(2,2) = 1
      N0w(3,1) = -b0x_de_z*lambda
      N0w(3,2) = -b0x_de_z
      N0w(3,3) = t31
      N0w(4,1) = t32
      N0w(4,2) = t7
      N0w(4,3) = t33-b0x_de_z*b1Fqz
      N0w(4,4) = t31
      N0w(5,1) = t42*lambda
      N0w(5,2) = t42
      N0w(5,3) = (t8+t6)*b1Fqz+t43+t5*b0Fqz*b0x_de_z
      N0w(5,4) = t13*b0x_de_z*b1Fqz+t14
      N0w(5,5) = t30*b1Fqz+t44
      N0w(5,6) = t24*b0x_de_z*b1Fqz+t25
      N0w(5,7) = t45*b0x_de_z
      N0w(6,1) = t48*lambda
      N0w(6,2) = t48
      N0w(6,3) = (t41+t39)*b1Fqz+t49+t38*b0Fqz*t7
      N0w(6,4) = t50+t43
      N0w(6,5) = t45*b0x_de_z*b1Fqz+t45*b0Fqz*b0x_de_z
      N0w(6,6) = (t53+t2+t29+1)*b1Fqz+t52*b0Fqz*b0x_de_z+t44
      N0w(6,7) = t7
      N1w(1,1) = t54
      N1w(1,2) = t54
      N1w(1,3) = (t61*b0x_de_z+t59+t10+t58)*b1Fqz+t57+(-3*b1x*t2+t55+b1x)..
        *b0Fqz
      N1w(1,4) = (t64+t15+t63)*b1Fqz+(-3*b2x*t2+t62+b2x)*b0Fqz
      N1w(1,5) = (t73*b0x_de_z+t71+t19+t70)*b1Fqz+t69+t67*b0Fqz
      N1w(1,6) = (t76+t26+t75)*b1Fqz+(3*a2x*t2+t74+t22)*b0Fqz
      N1w(1,7) = t78
      N1w(3,1) = b0x_de_z*lambda
      N1w(3,2) = b0x_de_z
      N1w(3,3) = t79
      N1w(4,1) = -2*t7*lambda
      N1w(4,2) = t80
      N1w(4,3) = 2*b0Fqz*b0x_de_z
      N1w(4,4) = t79
      N1w(5,1) = t82*lambda
      N1w(5,2) = t82
      N1w(5,3) = (t86+t85*b0x_de_z)*b1Fqz+t84+(t83+t36)*b0Fqz*b0x_de_z
      N1w(5,4) = t61*b0x_de_z*b1Fqz+t57
      N1w(5,5) = t91*b1Fqz+t89
      N1w(5,6) = t73*b0x_de_z*b1Fqz+t69
      N1w(5,7) = -2*a0x_de_z*b0x_de_z
      N1w(6,1) = t96*lambda
      N1w(6,2) = t96
      N1w(6,3) = (2*b2x*t40+2*b1x*a0x_de_z*t7)*b1Fqz+t99+(t98+t97)*b0Fqz..
        *t7
      N1w(6,4) = t100+t84
      N1w(6,5) = t103*b0x_de_z*b1Fqz+(t101-1)*b0Fqz*b0x_de_z
      N1w(6,6) = (t105*b0x_de_z+t90+t29+3)*b1Fqz+(t18-3*a1x*a0x_de_z)*b0Fqz..
        *b0x_de_z+t89
      N1w(6,7) = t80
      N2w(1,1) = t108
      N2w(1,2) = t108
      N2w(1,3) = (t110*b0x_de_z+t59+t55+t58)*b1Fqz+t109+(3*b1x*t2+t55+t36)..
        *b0Fqz
      N2w(1,4) = (t64+t62+t63)*b1Fqz+(3*b2x*t2+t62+t56)*b0Fqz
      N2w(1,5) = (t115*b0x_de_z+t71+t65+t70)*b1Fqz+t114+t112*b0Fqz
      N2w(1,6) = (t76+t74+t75)*b1Fqz+(-3*a2x*t2+t74+a2x)*b0Fqz
      N2w(1,7) = t116
      N2w(4,1) = t32
      N2w(4,2) = t7
      N2w(4,3) = b0x_de_z*b1Fqz+t33
      N2w(5,1) = t117*lambda
      N2w(5,2) = t117
      N2w(5,3) = (t86+t38*b0x_de_z)*b1Fqz+t118+(t81+t36)*b0Fqz*b0x_de_z
      N2w(5,4) = t110*b0x_de_z*b1Fqz+t109
      N2w(5,5) = t121*b1Fqz+t120
      N2w(5,6) = t115*b0x_de_z*b1Fqz+t114
      N2w(5,7) = t122*b0x_de_z
      N2w(6,1) = t123*lambda
      N2w(6,2) = t123
      N2w(6,3) = 2*b1x*t7*b1Fqz-6*b2x*b0Fqz*t40-6*b1x*a0x_de_z*b0Fqz*t7
      N2w(6,4) = t100+t118
      N2w(6,5) = t125*b0x_de_z*b1Fqz+(t124-1)*b0Fqz*b0x_de_z
      N2w(6,6) = (t127*b0x_de_z+t90+t87+3)*b1Fqz+(t126+t18)*b0Fqz*b0x_de_z..
        +t120
      N2w(6,7) = t7
      N3w(1,3) = (t129*b0x_de_z+t11+t55+b1x)*b1Fqz+t128+(t59+t10+t36)..
        *b0Fqz
      N3w(1,4) = (t16+t62+b2x)*b1Fqz+(t64+t15+t56)*b0Fqz
      N3w(1,5) = (t132*b0x_de_z+t20+t65+t18)*b1Fqz+t131+t130*b0Fqz
      N3w(1,6) = (t27+t74+t22)*b1Fqz+t133*b0Fqz
      N3w(5,1) = t137*lambda
      N3w(5,2) = t137
      N3w(5,3) = (t8+t107)*b1Fqz+t138+t85*b0Fqz*b0x_de_z
      N3w(5,4) = t129*b0x_de_z*b1Fqz+t128
      N3w(5,5) = t116*b1Fqz+t139
      N3w(5,6) = t132*b0x_de_z*b1Fqz+t131
      N3w(6,1) = t140*lambda
      N3w(6,2) = t140
      N3w(6,3) = (-2*b2x*t40-2*b1x*a0x_de_z*t7)*b1Fqz+t99+(t98+t93)*b0Fqz..
        *t7
      N3w(6,4) = t50+t138
      N3w(6,5) = t122*b0x_de_z*b1Fqz+t103*b0Fqz*b0x_de_z
      N3w(6,6) = (t142+t2+t87+1)*b1Fqz+t105*b0Fqz*b0x_de_z+t139
      N4w(6,1) = t143*lambda
      N4w(6,2) = t143
      N4w(6,3) = (t136+t135)*b1Fqz+t49+t85*b0Fqz*t7
      D0w(1,1) = t145
      D0w(1,2) = t146
      D0w(1,3) = t152
      D0w(1,4) = t152
      D0w(1,5) = t152
      D0w(1,6) = t152
      D0w(1,7) = t146
      D0w(2,1) = 1
      D0w(2,2) = 1
      D0w(2,3) = 1
      D0w(2,4) = 1
      D0w(2,5) = 1
      D0w(2,6) = 1
      D0w(2,7) = 1
      D0w(3,1) = t125
      D0w(3,2) = t125
      D0w(3,3) = t153
      D0w(3,4) = 1
      D0w(3,5) = 1
      D0w(3,6) = 1
      D0w(3,7) = 1
      D0w(4,1) = t30
      D0w(4,2) = t30
      D0w(4,3) = t125*a1Fqz+t155+t154
      D0w(4,4) = t153
      D0w(4,5) = 1
      D0w(4,6) = 1
      D0w(4,7) = 1
      D0w(5,1) = t158
      D0w(5,2) = t158
      D0w(5,3) = t151
      D0w(5,4) = t151
      D0w(5,5) = t151
      D0w(5,6) = t151
      D0w(5,7) = t145
      D0w(6,1) = t162
      D0w(6,2) = t162
      D0w(6,3) = (t24*a1Fqz+t169+t168)*t7+(t21*a1Fqz+t167-2*a1x*a0Fqz..
        *a0x_de_z+t166)*b0x_de_z+(t157+t88+t101-1)*a1Fqz+t165+t164+t163+t154
      D0w(6,4) = t151
      D0w(6,5) = t151
      D0w(6,6) = t151
      D0w(6,7) = t145
      D1w(1,1) = t170
      D1w(1,2) = t171
      D1w(1,3) = t175
      D1w(1,4) = t175
      D1w(1,5) = t175
      D1w(1,6) = t175
      D1w(1,7) = t171
      D1w(3,1) = t122
      D1w(3,2) = t122
      D1w(3,3) = t176
      D1w(4,1) = t78
      D1w(4,2) = t78
      D1w(4,3) = t147-2*a1Fqz
      D1w(4,4) = t176
      D1w(5,1) = t177
      D1w(5,2) = t177
      D1w(5,3) = t174
      D1w(5,4) = t174
      D1w(5,5) = t174
      D1w(5,6) = t174
      D1w(5,7) = t170
      D1w(6,1) = t182
      D1w(6,2) = t182
      D1w(6,3) = (2*a2x*a0x_de_z*a1Fqz+t186+2*a2x*a0Fqz)*t7+((2*a1x*t2+t185)..
        *a1Fqz+t184+4*a1x*a0Fqz*a0x_de_z)*b0x_de_z+(2*t156-6*a0x_de_z-4)*a1Fqz..
        +t183+6*a0Fqz*t2-2*a0Fqz
      D1w(6,4) = t174
      D1w(6,5) = t174
      D1w(6,6) = t174
      D1w(6,7) = t170
      D2w(1,1) = t187
      D2w(1,2) = t188
      D2w(1,3) = t191
      D2w(1,4) = t191
      D2w(1,5) = t191
      D2w(1,6) = t191
      D2w(1,7) = t188
      D2w(4,1) = t116
      D2w(4,2) = t116
      D2w(4,3) = t122*a1Fqz+t155+a0Fqz
      D2w(5,1) = t192
      D2w(5,2) = t192
      D2w(5,3) = t190
      D2w(5,4) = t190
      D2w(5,5) = t190
      D2w(5,6) = t190
      D2w(5,7) = t187
      D2w(6,1) = t193
      D2w(6,2) = t193
      D2w(6,3) = (2*a2x*a1Fqz-6*a2x*a0Fqz*a0x_de_z)*t7+(4*a1x*a0x_de_z*a1Fqz..
        -6*a1x*a0Fqz*t2+2*a1x*a0Fqz)*b0x_de_z+(t159-6)*a1Fqz-6*a0Fqz*t156..
        +6*a0Fqz*a0x_de_z
      D2w(6,4) = t190
      D2w(6,5) = t190
      D2w(6,6) = t190
      D2w(6,7) = t187
      D3w(1,3) = t195
      D3w(1,4) = t195
      D3w(1,5) = t195
      D3w(1,6) = t195
      D3w(5,1) = t196
      D3w(5,2) = t196
      D3w(5,3) = t194
      D3w(5,4) = t194
      D3w(5,5) = t194
      D3w(5,6) = t194
      D3w(6,1) = t197
      D3w(6,2) = t197
      D3w(6,3) = (-2*a2x*a0x_de_z*a1Fqz+t186-2*a2x*a0Fqz)*t7+((t179-2*a1x..
        *t2)*a1Fqz+t184-4*a1x*a0Fqz*a0x_de_z)*b0x_de_z+(-2*t156+6*a0x_de_z-4)*a1Fqz..
        +t183-6*a0Fqz*t2+2*a0Fqz
      D3w(6,4) = t194
      D3w(6,5) = t194
      D3w(6,6) = t194
      D4w(6,1) = t198
      D4w(6,2) = t198
      D4w(6,3) = (t73*a1Fqz+t169+t149)*t7+(t130*a1Fqz+t167+2*a1x*a0Fqz..
        *a0x_de_z+t166)*b0x_de_z+(t156+t88+t124-1)*a1Fqz+t165+t189+t163..
        +a0Fqz
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
endfunction
function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=4;n=5;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = a0x_de_z^2
      t2 = b0x*t1
      t3 = b1x*a0x_de_z
      t4 = b0x_de_z^2
      t5 = b2x*t4
      t6 = t5+(t3+b1x)*b0x_de_z+t2+2*b0x*a0x_de_z+b0x
      t7 = -a1x*b0x
      t8 = (2*b1x-2*a1x*b0x)*a0x_de_z
      t9 = (b1x+t7)*t1
      t10 = -a2x*b0x
      t11 = b2x+t10
      t12 = t11*a0x_de_z
      t13 = t12+b2x+t10
      t14 = (2*b2x-2*a2x*b0x)*a0x_de_z
      t15 = t11*t1
      t16 = -a2x*b1x
      t17 = a1x*b2x
      t18 = (t17+t16)*a0x_de_z
      t19 = t18+t17+t16
      t20 = 2*a0x_de_z
      t21 = t1+t20+1
      t22 = -a1x
      t23 = -2*a1x*a0x_de_z
      t24 = -a1x*t1
      t25 = -a2x
      t26 = -a2x*a0x_de_z
      t27 = t26+t25
      t28 = t27*b0Fqz*b0x_de_z
      t29 = -2*a2x*a0x_de_z
      t30 = -a2x*t1
      t31 = t30+t29+t25
      t32 = a0x_de_z+1
      t33 = t21*b0Fqz
      t34 = t4*lambda
      t35 = a1x*a0x_de_z
      t36 = t35+a1x
      t37 = t36*b0x_de_z
      t38 = -2*b2x*t4-2*b1x*a0x_de_z*b0x_de_z-2*b0x*t1+2*b0x
      t39 = (2*a1x*b0x-2*b1x)*a0x_de_z
      t40 = a2x*b0x
      t41 = -b2x
      t42 = 3*a2x*b0x-3*b2x
      t43 = -3*a1x*b0x
      t44 = 3*b1x
      t45 = a1x*b0x
      t46 = -b1x
      t47 = (t46+t45)*t1
      t48 = t41+t40
      t49 = t48*a0x_de_z
      t50 = t49+b2x+t10
      t51 = (2*a2x*b0x-2*b2x)*a0x_de_z
      t52 = a2x*b1x
      t53 = -a1x*b2x
      t54 = -3*a2x*b0x
      t55 = 3*b2x
      t56 = t48*t1
      t57 = (t53+t52)*a0x_de_z
      t58 = t57+t17+t16
      t59 = -2*t1
      t60 = t59+2
      t61 = 2*a1x*a0x_de_z
      t62 = (3*a2x*a0x_de_z+a2x)*b0Fqz*b0x_de_z
      t63 = -3*a1x
      t64 = a1x*t1
      t65 = a2x*a0x_de_z
      t66 = t65+t25
      t67 = 2*a2x*a0x_de_z
      t68 = -3*a2x
      t69 = a2x*t1
      t70 = -2*a0x_de_z
      t71 = (-3*t1+t70+1)*b0Fqz
      t72 = -t1
      t73 = t72+t20+3
      t74 = -a0x_de_z
      t75 = t74+1
      t76 = -a1x*a0x_de_z
      t77 = t76+a1x
      t78 = t5+(t3+t46)*b0x_de_z+t2-2*b0x*a0x_de_z+b0x
      t79 = t55+t54
      t80 = t1+t70+1
      t81 = (a2x-3*a2x*a0x_de_z)*b0Fqz*b0x_de_z
      t82 = t65+a2x
      t83 = a0x_de_z-1
      t84 = (3*t1+t70-1)*b0Fqz
      t85 = t72+t70+3
      t86 = t76+t22
      t87 = t66*b0Fqz*b0x_de_z
      t88 = t26+a2x
      t89 = (t72+t20-1)*b0Fqz
      t90 = t35+t22
      t91 = t90*b0x_de_z
      t92 = a2x*t4
      t93 = t92+t37+t1+t20+1
      t94 = 2*a0Fqz*a0x_de_z
      t95 = a1x*a0Fqz
      t96 = a2x*a1Fqz
      t97 = (t96+a2x*a0Fqz)*t4+(t36*a1Fqz+a1x*a0Fqz*a0x_de_z+t95)*b0x_de_z+t21..
        *a1Fqz+a0Fqz*t1+t94+a0Fqz
      t98 = t97*lambda
      t99 = -2*a2x*t4-2*a1x*a0x_de_z*b0x_de_z+t59+2
      t100 = -2*a0Fqz*a0x_de_z
      t101 = -a1x*a0Fqz
      t102 = -a2x*a1Fqz
      t103 = (t102-3*a2x*a0Fqz)*t4+(t77*a1Fqz-3*a1x*a0Fqz*a0x_de_z+t101)..
        *b0x_de_z+t73*a1Fqz-3*a0Fqz*t1+t100+a0Fqz
      t104 = t103*lambda
      t105 = t92+t91+t1+t70+1
      t106 = -a0Fqz
      t107 = (t102+3*a2x*a0Fqz)*t4+(t86*a1Fqz+3*a1x*a0Fqz*a0x_de_z+t101)..
        *b0x_de_z+t85*a1Fqz+3*a0Fqz*t1+t100+t106
      t108 = t107*lambda
      t109 = (t96-a2x*a0Fqz)*t4+(t90*a1Fqz-a1x*a0Fqz*a0x_de_z+t95)*b0x_de_z..
        +t80*a1Fqz-a0Fqz*t1+t94+t106
      t110 = t109*lambda
      N0w(1,1) = t6
      N0w(1,2) = t6
      N0w(1,3) = (t13*b0x_de_z+t9+t8+b1x+t7)*b1Fqz+t13*b0Fqz*b0x_de_z+(t9+t8..
        +b1x+t7)*b0Fqz
      N0w(1,4) = (t19*b0x_de_z+t15+t14+b2x+t10)*b1Fqz+t19*b0Fqz*b0x_de_z+(t15..
        +t14+b2x+t10)*b0Fqz
      N0w(1,5) = 1
      N0w(2,1) = t21*lambda
      N0w(2,2) = t21
      N0w(2,3) = (t27*b0x_de_z+t24+t23+t22)*b1Fqz+t28+(t24+t23+t22)*b0Fqz
      N0w(2,4) = t31*b1Fqz+t31*b0Fqz
      N0w(3,1) = t32*b0x_de_z*lambda
      N0w(3,2) = t32*b0x_de_z
      N0w(3,3) = t21*b1Fqz+t33
      N0w(3,4) = t27*b0x_de_z*b1Fqz+t28
      N0w(4,1) = t34
      N0w(4,2) = t4
      N0w(4,3) = t32*b0x_de_z*b1Fqz+t32*b0Fqz*b0x_de_z
      N0w(4,4) = (t37+t1+t20+1)*b1Fqz+t36*b0Fqz*b0x_de_z+t33
      N1w(1,1) = t38
      N1w(1,2) = t38
      N1w(1,3) = (t50*b0x_de_z+t47+t8+t44+t43)*b1Fqz+(t42*a0x_de_z+t41+t40)..
        *b0Fqz*b0x_de_z+((3*a1x*b0x-3*b1x)*t1+t39+b1x+t7)*b0Fqz
      N1w(1,4) = (t58*b0x_de_z+t56+t14+t55+t54)*b1Fqz+((3*a2x*b1x-3*a1x*b2x)..
        *a0x_de_z+t53+t52)*b0Fqz*b0x_de_z+(t42*t1+t51+b2x+t10)*b0Fqz
      N1w(2,1) = t60*lambda
      N1w(2,2) = t60
      N1w(2,3) = (t66*b0x_de_z+t64+t23+t63)*b1Fqz+t62+(3*a1x*t1+t61+t22)..
        *b0Fqz
      N1w(2,4) = (t69+t29+t68)*b1Fqz+(3*a2x*t1+t67+t25)*b0Fqz
      N1w(3,1) = -2*a0x_de_z*b0x_de_z*lambda
      N1w(3,2) = -2*a0x_de_z*b0x_de_z
      N1w(3,3) = t73*b1Fqz+t71
      N1w(3,4) = t66*b0x_de_z*b1Fqz+t62
      N1w(4,1) = -2*t4*lambda
      N1w(4,2) = -2*t4
      N1w(4,3) = t75*b0x_de_z*b1Fqz+(-3*a0x_de_z-1)*b0Fqz*b0x_de_z
      N1w(4,4) = (t77*b0x_de_z+t72+t20+3)*b1Fqz+(t22-3*a1x*a0x_de_z)*b0Fqz*b0x_de_z..
        +t71
      N2w(1,1) = t78
      N2w(1,2) = t78
      N2w(1,3) = ((t49+t41+t40)*b0x_de_z+t47+t39+t44+t43)*b1Fqz+(t79*a0x_de_z..
        +t41+t40)*b0Fqz*b0x_de_z+((t44+t43)*t1+t39+t46+t45)*b0Fqz
      N2w(1,4) = ((t57+t53+t52)*b0x_de_z+t56+t51+t55+t54)*b1Fqz+((3*a1x*b2x..
        -3*a2x*b1x)*a0x_de_z+t53+t52)*b0Fqz*b0x_de_z+(t79*t1+t51+t41+t40)..
        *b0Fqz
      N2w(2,1) = t80*lambda
      N2w(2,2) = t80
      N2w(2,3) = (t82*b0x_de_z+t64+t61+t63)*b1Fqz+t81+(-3*a1x*t1+t61+a1x)..
        *b0Fqz
      N2w(2,4) = (t69+t67+t68)*b1Fqz+(-3*a2x*t1+t67+a2x)*b0Fqz
      N2w(3,1) = t83*b0x_de_z*lambda
      N2w(3,2) = t83*b0x_de_z
      N2w(3,3) = t85*b1Fqz+t84
      N2w(3,4) = t82*b0x_de_z*b1Fqz+t81
      N2w(4,1) = t34
      N2w(4,2) = t4
      N2w(4,3) = (t74-1)*b0x_de_z*b1Fqz+(3*a0x_de_z-1)*b0Fqz*b0x_de_z
      N2w(4,4) = (t86*b0x_de_z+t72+t70+3)*b1Fqz+(3*a1x*a0x_de_z+t22)*b0Fqz*b0x_de_z..
        +t84
      N3w(1,3) = ((t12+t41+t40)*b0x_de_z+t9+t39+b1x+t7)*b1Fqz+t50*b0Fqz*b0x_de_z..
        +(t47+t8+t46+t45)*b0Fqz
      N3w(1,4) = ((t18+t53+t52)*b0x_de_z+t15+t51+b2x+t10)*b1Fqz+t58*b0Fqz..
        *b0x_de_z+(t56+t14+t41+t40)*b0Fqz
      N3w(2,3) = (t88*b0x_de_z+t24+t61+t22)*b1Fqz+t87+(t64+t23+a1x)*b0Fqz
      N3w(2,4) = (t30+t67+t25)*b1Fqz+(t69+t29+a2x)*b0Fqz
      N3w(3,3) = t80*b1Fqz+t89
      N3w(3,4) = t88*b0x_de_z*b1Fqz+t87
      N3w(4,3) = t83*b0x_de_z*b1Fqz+t75*b0Fqz*b0x_de_z
      N3w(4,4) = (t91+t1+t70+1)*b1Fqz+t77*b0Fqz*b0x_de_z+t89
      D0w(1,1) = t93
      D0w(1,2) = t93*lambda
      D0w(1,3) = t98
      D0w(1,4) = t98
      D0w(1,5) = lambda
      D0w(2,1) = t93
      D0w(2,2) = t93
      D0w(2,3) = t97
      D0w(2,4) = t97
      D0w(2,5) = 1
      D0w(3,1) = t93
      D0w(3,2) = t93
      D0w(3,3) = t97
      D0w(3,4) = t97
      D0w(3,5) = 1
      D0w(4,1) = t93
      D0w(4,2) = t93
      D0w(4,3) = t97
      D0w(4,4) = t97
      D0w(4,5) = 1
      D1w(1,1) = t99
      D1w(1,2) = t99*lambda
      D1w(1,3) = t104
      D1w(1,4) = t104
      D1w(2,1) = t99
      D1w(2,2) = t99
      D1w(2,3) = t103
      D1w(2,4) = t103
      D1w(3,1) = t99
      D1w(3,2) = t99
      D1w(3,3) = t103
      D1w(3,4) = t103
      D1w(4,1) = t99
      D1w(4,2) = t99
      D1w(4,3) = t103
      D1w(4,4) = t103
      D2w(1,1) = t105
      D2w(1,2) = t105*lambda
      D2w(1,3) = t108
      D2w(1,4) = t108
      D2w(2,1) = t105
      D2w(2,2) = t105
      D2w(2,3) = t107
      D2w(2,4) = t107
      D2w(3,1) = t105
      D2w(3,2) = t105
      D2w(3,3) = t107
      D2w(3,4) = t107
      D2w(4,1) = t105
      D2w(4,2) = t105
      D2w(4,3) = t107
      D2w(4,4) = t107
      D3w(1,3) = t110
      D3w(1,4) = t110
      D3w(2,3) = t109
      D3w(2,4) = t109
      D3w(3,3) = t109
      D3w(3,4) = t109
      D3w(4,3) = t109
      D3w(4,4) = t109
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);

      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);

endfunction
function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df1t_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=2;n=11;
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = 2*b0x*a0x_de_z
      t2 = a0x_de_z^2
      t3 = b0x*t2
      t4 = b1x*a0x_de_z
      t5 = t4+b1x
      t6 = b0x_de_z^2
      t7 = b2x*t6
      t8 = t7+t5*b0x_de_z+t3+t1+b0x
      t9 = t3+t1+b0x
      t10 = b0x_de_z^3
      t11 = b0x_de_z^4
      t12 = b2x*t11
      t13 = -b0x
      t14 = -2*b0x*a0x_de_z
      t15 = -b0x*t2
      t16 = t15+t14+t13
      t17 = -b1x
      t18 = -b1x*a0x_de_z
      t19 = t18+t17
      t20 = -b2x*b0Fqz*t10
      t21 = -b2x*t10+t19*t6+t16*b0x_de_z
      t22 = -b0Fqz*b0x_de_z
      t23 = 2*a0x_de_z
      t24 = t2+t23+1
      t25 = t24*lambda
      t26 = a0x_de_z+1
      t27 = 2*b0x
      t28 = -2*b0x*t2
      t29 = -2*b2x*t6-2*b1x*a0x_de_z*b0x_de_z+t28+t27
      t30 = -4*b0x*a0x_de_z
      t31 = -4*b0x*t2
      t32 = -2*b1x
      t33 = -4*b1x*a0x_de_z
      t34 = -4*b2x*t11
      t35 = 4*b0x*a0x_de_z
      t36 = 4*b0x*t2
      t37 = 2*b1x
      t38 = 4*b1x*a0x_de_z
      t39 = 4*b2x*b0Fqz*t10
      t40 = -2*b0x
      t41 = 3*b0x*t2
      t42 = 3*b1x*a0x_de_z
      t43 = -3*b0x*t2
      t44 = -3*b1x*a0x_de_z
      t45 = 3*b0x
      t46 = t18+b1x
      t47 = -b2x*t6
      t48 = -2*t6
      t49 = -2*t2
      t50 = t49+2
      t51 = t50*lambda
      t52 = -3*a0x_de_z
      t53 = -a0x_de_z
      t54 = t53+1
      t55 = -2*a0x_de_z
      t56 = -3*t2
      t57 = -t2
      t58 = t57+t23+3
      t59 = t4+t17
      t60 = t7+t59*b0x_de_z+t3+t14+b0x
      t61 = t2+t55+1
      t62 = t61*lambda
      t63 = 3*a0x_de_z
      t64 = t53-1
      t65 = a0x_de_z-1
      t66 = 3*t2
      t67 = t57+t55+3
      t68 = t3+t14+b0x
      t69 = b2x*t10+t59*t6+t68*b0x_de_z
      t70 = t15+t1+t13
      t71 = a1x*a0x_de_z
      t72 = t71+a1x
      t73 = a2x*t6
      t74 = t73+t72*b0x_de_z+t2+t23+1
      t75 = 6*t2
      t76 = a0x_de_z^3
      t77 = a0x_de_z^4
      t78 = 3*a1x*a0x_de_z
      t79 = 3*a1x*t2
      t80 = a1x*t76
      t81 = a2x*t2
      t82 = -a0Fqz
      t83 = -3*a0Fqz*a0x_de_z
      t84 = -3*a0Fqz*t2
      t85 = -a0Fqz*t76
      t86 = -t76
      t87 = -a1x*a0Fqz
      t88 = -a1x*a0Fqz*t2
      t89 = -a1x
      t90 = -2*a1x*a0x_de_z
      t91 = -a1x*t2+t90+t89
      t92 = -a2x*a0Fqz
      t93 = -a2x*a0Fqz*a0x_de_z
      t94 = -a2x
      t95 = t94-a2x*a0x_de_z
      t96 = 2*a0Fqz*a0x_de_z
      t97 = a1x*a0Fqz
      t98 = a2x*a0Fqz
      t99 = a2x*a1Fqz
      t100 = (t99+t98)*t6+(t72*a1Fqz+a1x*a0Fqz*a0x_de_z+t97)*b0x_de_z+t24*a1Fqz..
        +a0Fqz*t2+t96+a0Fqz
      t101 = -a0Fqz*a0x_de_z
      t102 = -2*a2x*t6-2*a1x*a0x_de_z*b0x_de_z+t49+2
      t103 = -4*t77
      t104 = 2*a1x
      t105 = -4*a1x*t76
      t106 = -4*a2x*t2
      t107 = 4*a0Fqz*t76
      t108 = 4*a1x*a0Fqz*t2
      t109 = -2*a1x
      t110 = 4*a2x*a0Fqz*a0x_de_z
      t111 = 2*a1x*a0x_de_z
      t112 = -2*a0Fqz*a0x_de_z
      t113 = -a1x*a0x_de_z
      t114 = -a2x*a1Fqz
      t115 = (t114-3*a2x*a0Fqz)*t6+((t113+a1x)*a1Fqz-3*a1x*a0Fqz*a0x_de_z..
        +t87)*b0x_de_z+t58*a1Fqz+t84+t112+a0Fqz
      t116 = t71+t89
      t117 = t73+t116*b0x_de_z+t2+t55+1
      t118 = -3*a1x*t2
      t119 = 3*a0Fqz*t2
      t120 = (t114+3*a2x*a0Fqz)*t6+((t113+t89)*a1Fqz+3*a1x*a0Fqz*a0x_de_z..
        +t87)*b0x_de_z+t67*a1Fqz+t119+t112+t82
      t121 = a1x*t2+t90+a1x
      t122 = a2x*a0x_de_z+t94
      t123 = (t99+t92)*t6+(t116*a1Fqz-a1x*a0Fqz*a0x_de_z+t97)*b0x_de_z+t61*a1Fqz..
        -a0Fqz*t2+t96+t82
      N0w(1,1) = t8
      N0w(1,2) = t12+t5*t10+t9*t6
      N0w(1,3) = t21*b1Fqz+t20+t19*b0Fqz*t6+t16*b0Fqz*b0x_de_z
      N0w(1,4) = t21
      N0w(1,5) = t8*b1Fqz+b2x*b0Fqz*t6+t5*b0Fqz*b0x_de_z+t9*b0Fqz
      N0w(1,6) = 1
      N0w(1,7) = -b0x_de_z
      N0w(1,8) = b1Fqz+b0Fqz
      N0w(1,9) = t6
      N0w(1,10) = t22-b0x_de_z*b1Fqz
      N0w(1,11) = t8
      N0w(2,1) = t25
      N0w(2,2) = t6
      N0w(2,3) = t26*b0x_de_z*b1Fqz+t26*b0Fqz*b0x_de_z
      N0w(2,4) = t26*b0x_de_z
      N0w(2,5) = t24*b1Fqz+t24*b0Fqz
      N0w(2,11) = t24
      N1w(1,1) = t29
      N1w(1,2) = t34+(t33+t32)*t10+(t31+t30)*t6
      N1w(1,3) = (2*b2x*t10+2*b1x*a0x_de_z*t6+(2*b0x*t2+t40)*b0x_de_z)*b1Fqz..
        +t39+(t38+t37)*b0Fqz*t6+(t36+t35)*b0Fqz*b0x_de_z
      N1w(1,4) = 3*b2x*t10+(t42+b1x)*t6+(t41+t1+t13)*b0x_de_z
      N1w(1,5) = (t47+t46*b0x_de_z+t15+t1+t45)*b1Fqz-3*b2x*b0Fqz*t6+(t44..
        +t17)*b0Fqz*b0x_de_z+(t43+t14+b0x)*b0Fqz
      N1w(1,7) = b0x_de_z
      N1w(1,8) = b1Fqz-b0Fqz
      N1w(1,9) = t48
      N1w(1,10) = 2*b0Fqz*b0x_de_z
      N1w(1,11) = t29
      N1w(2,1) = t51
      N1w(2,2) = t48
      N1w(2,3) = t54*b0x_de_z*b1Fqz+(t52-1)*b0Fqz*b0x_de_z
      N1w(2,4) = -2*a0x_de_z*b0x_de_z
      N1w(2,5) = t58*b1Fqz+(t56+t55+1)*b0Fqz
      N1w(2,11) = t50
      N2w(1,1) = t60
      N2w(1,2) = 6*b2x*t11+6*b1x*a0x_de_z*t10+(6*b0x*t2+t40)*t6
      N2w(1,3) = (2*b1x*t6+4*b0x*a0x_de_z*b0x_de_z)*b1Fqz-6*b2x*b0Fqz*t10-6..
        *b1x*a0x_de_z*b0Fqz*t6+(t27-6*b0x*t2)*b0Fqz*b0x_de_z
      N2w(1,4) = -3*b2x*t10+(t44+b1x)*t6+(t43+t1+b0x)*b0x_de_z
      N2w(1,5) = (t47+t19*b0x_de_z+t15+t14+t45)*b1Fqz+3*b2x*b0Fqz*t6+(t42..
        +t17)*b0Fqz*b0x_de_z+(t41+t14+t13)*b0Fqz
      N2w(1,9) = t6
      N2w(1,10) = b0x_de_z*b1Fqz+t22
      N2w(1,11) = t60
      N2w(2,1) = t62
      N2w(2,2) = t6
      N2w(2,3) = t64*b0x_de_z*b1Fqz+(t63-1)*b0Fqz*b0x_de_z
      N2w(2,4) = t65*b0x_de_z
      N2w(2,5) = t67*b1Fqz+(t66+t55-1)*b0Fqz
      N2w(2,11) = t61
      N3w(1,2) = t34+(t33+t37)*t10+(t31+t35)*t6
      N3w(1,3) = (-2*b2x*t10-2*b1x*a0x_de_z*t6+(t28+t27)*b0x_de_z)*b1Fqz+t39..
        +(t38+t32)*b0Fqz*t6+(t36+t30)*b0Fqz*b0x_de_z
      N3w(1,4) = t69
      N3w(1,5) = t60*b1Fqz-b2x*b0Fqz*t6+t46*b0Fqz*b0x_de_z+t70*b0Fqz
      N3w(2,3) = t65*b0x_de_z*b1Fqz+t54*b0Fqz*b0x_de_z
      N3w(2,5) = t61*b1Fqz+(t57+t23-1)*b0Fqz
      N4w(1,2) = t12+t59*t10+t68*t6
      N4w(1,3) = t69*b1Fqz+t20+t46*b0Fqz*t6+t70*b0Fqz*b0x_de_z
      D0w(1,1) = t74
      D0w(1,2) = ((t81+2*a2x*a0x_de_z+a2x)*t6+(t80+t79+t78+a1x)*b0x_de_z+t77..
        +4*t76+t75+4*a0x_de_z+1)*lambda
      D0w(1,3) = ((t95*a1Fqz+t93+t92)*t6+(t91*a1Fqz+t88-2*a1x*a0Fqz*a0x_de_z..
        +t87)*b0x_de_z+(t86+t56+t52-1)*a1Fqz+t85+t84+t83+t82)*lambda
      D0w(1,4) = (t95*t6+t91*b0x_de_z+t86+t56+t52-1)*lambda
      D0w(1,5) = t100*lambda
      D0w(1,6) = lambda
      D0w(1,7) = t64*lambda
      D0w(1,8) = (a1Fqz+a0Fqz)*lambda
      D0w(1,9) = t25
      D0w(1,10) = (t64*a1Fqz+t101+t82)*lambda
      D0w(1,11) = t74*lambda
      D0w(2,1) = t74
      D0w(2,2) = t74
      D0w(2,3) = t100
      D0w(2,4) = t74
      D0w(2,5) = t100
      D0w(2,6) = 1
      D0w(2,7) = 1
      D0w(2,8) = 1
      D0w(2,9) = 1
      D0w(2,10) = 1
      D0w(2,11) = t74
      D1w(1,1) = t102
      D1w(1,2) = ((t106-4*a2x*a0x_de_z)*t6+(t105-6*a1x*t2+t104)*b0x_de_z+t103..
        -8*t76+8*a0x_de_z+4)*lambda
      D1w(1,3) = ((2*a2x*a0x_de_z*a1Fqz+t110+2*a2x*a0Fqz)*t6+((2*a1x*t2..
        +t109)*a1Fqz+t108+4*a1x*a0Fqz*a0x_de_z)*b0x_de_z+(2*t76-6*a0x_de_z-4)*a1Fqz..
        +t107+6*a0Fqz*t2-2*a0Fqz)*lambda
      D1w(1,4) = ((3*a2x*a0x_de_z+a2x)*t6+(t79+t111+t89)*b0x_de_z+3*t76+t66..
        +t52-3)*lambda
      D1w(1,5) = t115*lambda
      D1w(1,7) = t65*lambda
      D1w(1,8) = (a1Fqz+t82)*lambda
      D1w(1,9) = t51
      D1w(1,10) = (t96-2*a1Fqz)*lambda
      D1w(1,11) = t102*lambda
      D1w(2,1) = t102
      D1w(2,2) = t102
      D1w(2,3) = t115
      D1w(2,4) = t102
      D1w(2,5) = t115
      D1w(2,11) = t102
      D2w(1,1) = t117
      D2w(1,2) = ((6*a2x*t2-2*a2x)*t6+(6*a1x*t76-6*a1x*a0x_de_z)*b0x_de_z+6..
        *t77-12*t2+6)*lambda
      D2w(1,3) = ((2*a2x*a1Fqz-6*a2x*a0Fqz*a0x_de_z)*t6+(4*a1x*a0x_de_z*a1Fqz..
        -6*a1x*a0Fqz*t2+2*a1x*a0Fqz)*b0x_de_z+(t75-6)*a1Fqz-6*a0Fqz*t76+6..
        *a0Fqz*a0x_de_z)*lambda
      D2w(1,4) = ((a2x-3*a2x*a0x_de_z)*t6+(t118+t111+a1x)*b0x_de_z-3*t76+t66..
        +t63-3)*lambda
      D2w(1,5) = t120*lambda
      D2w(1,9) = t62
      D2w(1,10) = (t65*a1Fqz+t101+a0Fqz)*lambda
      D2w(1,11) = t117*lambda
      D2w(2,1) = t117
      D2w(2,2) = t117
      D2w(2,3) = t120
      D2w(2,4) = t117
      D2w(2,5) = t120
      D2w(2,11) = t117
      D3w(1,2) = ((t106+4*a2x*a0x_de_z)*t6+(t105+6*a1x*t2+t109)*b0x_de_z+t103..
        +8*t76-8*a0x_de_z+4)*lambda
      D3w(1,3) = ((-2*a2x*a0x_de_z*a1Fqz+t110-2*a2x*a0Fqz)*t6+((t104-2*a1x..
        *t2)*a1Fqz+t108-4*a1x*a0Fqz*a0x_de_z)*b0x_de_z+(-2*t76+6*a0x_de_z-4)*a1Fqz..
        +t107-6*a0Fqz*t2+2*a0Fqz)*lambda
      D3w(1,4) = (t122*t6+t121*b0x_de_z+t76+t56+t63-1)*lambda
      D3w(1,5) = t123*lambda
      D3w(2,3) = t123
      D3w(2,5) = t123
      D4w(1,2) = ((t81-2*a2x*a0x_de_z+a2x)*t6+(t80+t118+t78+t89)*b0x_de_z+t77..
        -4*t76+t75-4*a0x_de_z+1)*lambda
      D4w(1,3) = ((t122*a1Fqz+t93+t98)*t6+(t121*a1Fqz+t88+2*a1x*a0Fqz..
        *a0x_de_z+t87)*b0x_de_z+(t76+t56+t63-1)*a1Fqz+t85+t119+t83+a0Fqz)..
        *lambda
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);

endfunction
  function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_df2t_2(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
      m=3;n=7;
      z=poly(0,'z');
      w=poly(0,'w');
      z_=poly(0,'z_1');
      Zr= zeros(m,n);
      N0z= Zr;
      N1z= Zr;
      N2z= Zr;
      N3z= Zr;
      N4z= Zr;
      D0z= Zr;
      D1z= Zr;
      D2z= Zr;
      D3z= Zr;
      D4z= Zr;
      N0w= Zr;
      N1w= Zr;
      N2w= Zr;
      N3w= Zr;
      N4w= Zr;
      D0w= Zr;
      D1w= Zr;
      D2w= Zr;
      D3w= Zr;
      D4w= Zr;
      N0z_1= Zr;
      N1z_1= Zr;
      N2z_1= Zr;
      N3z_1= Zr;
      N4z_1= Zr;
      D0z_1= Zr;
      D1z_1= Zr;
      D2z_1= Zr;
      D3z_1= Zr;
      D4z_1= Zr;
      t1 = 2*b0x*a0x_de_z
      t2 = a0x_de_z^2
      t3 = b0x*t2
      t4 = b1x*a0x_de_z
      t5 = (t4+b1x)*b0x_de_z
      t6 = b0x_de_z^2
      t7 = b2x*t6
      t8 = t7+t5+t3+t1+b0x
      t9 = 2*a0x_de_z
      t10 = t2+t9+1
      t11 = a0x_de_z+1
      t12 = t11*b0x_de_z
      t13 = t10*b1Fqz+t10*b0Fqz
      t14 = t11*b0x_de_z*b1Fqz+t11*b0Fqz*b0x_de_z
      t15 = a1x*a0x_de_z
      t16 = t15+a1x
      t17 = a2x*t6
      t18 = t17+t16*b0x_de_z+t2+t9+1
      t19 = t18*lambda
      t20 = 2*b0x
      t21 = -2*b0x*t2
      t22 = -2*b1x*a0x_de_z*b0x_de_z
      t23 = -2*b2x*t6
      t24 = t23+t22+t21+t20
      t25 = -2*t2
      t26 = t25+2
      t27 = -2*a0x_de_z*b0x_de_z
      t28 = -2*a0x_de_z
      t29 = -t2
      t30 = t29+t9+3
      t31 = t30*b1Fqz+(-3*t2+t28+1)*b0Fqz
      t32 = -2*t6
      t33 = -a0x_de_z
      t34 = t33+1
      t35 = t34*b0x_de_z*b1Fqz+(-3*a0x_de_z-1)*b0Fqz*b0x_de_z
      t36 = -2*a2x*t6-2*a1x*a0x_de_z*b0x_de_z+t25+2
      t37 = t36*lambda
      t38 = -2*b0x*a0x_de_z
      t39 = (t4-b1x)*b0x_de_z
      t40 = t7+t39+t3+t38+b0x
      t41 = t2+t28+1
      t42 = a0x_de_z-1
      t43 = t42*b0x_de_z
      t44 = t29+t28+3
      t45 = t44*b1Fqz+(3*t2+t28-1)*b0Fqz
      t46 = (t33-1)*b0x_de_z*b1Fqz+(3*a0x_de_z-1)*b0Fqz*b0x_de_z
      t47 = -a1x
      t48 = t15+t47
      t49 = t17+t48*b0x_de_z+t2+t28+1
      t50 = t49*lambda
      t51 = t41*b1Fqz+(t29+t9-1)*b0Fqz
      t52 = t42*b0x_de_z*b1Fqz+t34*b0Fqz*b0x_de_z
      t53 = 2*a0Fqz*a0x_de_z
      t54 = a1x*a0Fqz
      t55 = a2x*a1Fqz
      t56 = (t55+a2x*a0Fqz)*t6+(t16*a1Fqz+a1x*a0Fqz*a0x_de_z+t54)*b0x_de_z+t10..
        *a1Fqz+a0Fqz*t2+t53+a0Fqz
      t57 = t56*lambda
      t58 = -2*a0Fqz*a0x_de_z
      t59 = -a1x*a0Fqz
      t60 = -a1x*a0x_de_z
      t61 = -a2x*a1Fqz
      t62 = (t61-3*a2x*a0Fqz)*t6+((t60+a1x)*a1Fqz-3*a1x*a0Fqz*a0x_de_z+t59)..
        *b0x_de_z+t30*a1Fqz-3*a0Fqz*t2+t58+a0Fqz
      t63 = t62*lambda
      t64 = -a0Fqz
      t65 = (t61+3*a2x*a0Fqz)*t6+((t60+t47)*a1Fqz+3*a1x*a0Fqz*a0x_de_z+t59)..
        *b0x_de_z+t44*a1Fqz+3*a0Fqz*t2+t58+t64
      t66 = t65*lambda
      t67 = (t55-a2x*a0Fqz)*t6+(t48*a1Fqz-a1x*a0Fqz*a0x_de_z+t54)*b0x_de_z+t41..
        *a1Fqz-a0Fqz*t2+t53+t64
      t68 = t67*lambda
      N0w(1,1) = t8
      N0w(1,2) = t10
      N0w(1,3) = t12
      N0w(1,4) = t13
      N0w(1,5) = t6
      N0w(1,6) = t14
      N0w(1,7) = t19+t7+t5+t3+t1+b0x
      N0w(2,1) = lambda
      N0w(2,7) = 1
      N0w(3,1) = t8*lambda
      N0w(3,2) = t10
      N0w(3,3) = t12
      N0w(3,4) = t13
      N0w(3,5) = t6
      N0w(3,6) = t14
      N0w(3,7) = t8
      N1w(1,1) = t24
      N1w(1,2) = t26
      N1w(1,3) = t27
      N1w(1,4) = t31
      N1w(1,5) = t32
      N1w(1,6) = t35
      N1w(1,7) = t37+t23+t22+t21+t20
      N1w(3,1) = t24*lambda
      N1w(3,2) = t26
      N1w(3,3) = t27
      N1w(3,4) = t31
      N1w(3,5) = t32
      N1w(3,6) = t35
      N1w(3,7) = t24
      N2w(1,1) = t40
      N2w(1,2) = t41
      N2w(1,3) = t43
      N2w(1,4) = t45
      N2w(1,5) = t6
      N2w(1,6) = t46
      N2w(1,7) = t50+t7+t39+t3+t38+b0x
      N2w(3,1) = t40*lambda
      N2w(3,2) = t41
      N2w(3,3) = t43
      N2w(3,4) = t45
      N2w(3,5) = t6
      N2w(3,6) = t46
      N2w(3,7) = t40
      N3w(1,4) = t51
      N3w(1,6) = t52
      N3w(3,4) = t51
      N3w(3,6) = t52
      D0w(1,1) = t18
      D0w(1,2) = t19
      D0w(1,3) = t19
      D0w(1,4) = t57
      D0w(1,5) = t19
      D0w(1,6) = t57
      D0w(1,7) = t19
      D0w(2,1) = 1
      D0w(2,2) = 1
      D0w(2,3) = 1
      D0w(2,4) = 1
      D0w(2,5) = 1
      D0w(2,6) = 1
      D0w(2,7) = 1
      D0w(3,1) = t18
      D0w(3,2) = t18
      D0w(3,3) = t18
      D0w(3,4) = t56
      D0w(3,5) = t18
      D0w(3,6) = t56
      D0w(3,7) = t18
      D1w(1,1) = t36
      D1w(1,2) = t37
      D1w(1,3) = t37
      D1w(1,4) = t63
      D1w(1,5) = t37
      D1w(1,6) = t63
      D1w(1,7) = t37
      D1w(3,1) = t36
      D1w(3,2) = t36
      D1w(3,3) = t36
      D1w(3,4) = t62
      D1w(3,5) = t36
      D1w(3,6) = t62
      D1w(3,7) = t36
      D2w(1,1) = t49
      D2w(1,2) = t50
      D2w(1,3) = t50
      D2w(1,4) = t66
      D2w(1,5) = t50
      D2w(1,6) = t66
      D2w(1,7) = t50
      D2w(3,1) = t49
      D2w(3,2) = t49
      D2w(3,3) = t49
      D2w(3,4) = t65
      D2w(3,5) = t49
      D2w(3,6) = t65
      D2w(3,7) = t49
      D3w(1,4) = t68
      D3w(1,6) = t68
      D3w(3,4) = t67
      D3w(3,6) = t67
      w=poly(0,'w');
      Nw=real(N0w+N1w*w+N2w*w^2+N3w*w^3+N4w*w^4);
      Dw=real(D0w+D1w*w+D2w*w^2+D3w*w^3+D4w*w^4);
      z=poly(0,'z');
      z_1=poly(0,'z_1');
      w_de_z=(z-1)/(z+1);
      w_de_z_1=(1-z_1)/(1+z_1);
     [Nw,Dw]=make_as_list(Nw,Dw,%t);
     Fw=make_as_F(Nw,Dw);
     Fz=hornerij(Fw,w_de_z,'hd');
     [Nz,Dz]=make_as_ND(Fz);
     Fz_1=hornerij(Fw,w_de_z_1,'ld');
     [Nz_1,Dz_1]=make_as_ND(Fz_1);
  endfunction
  function [b0x,b1x,b2x,a0x,a1x,a2x]=clc_Fx_de_Fw(b0w,b1w,b2w,a0w,a1w,a2w,b0x_de_z,a0x_de_z)
    old_simp_mode=simp_mode();
    simp_mode(%f);
    w=poly(0,"w");
    z=poly(0,"z");
    f_de_w=(b0w+b1w*w+b2w*w^2)/(a0w+a1w*w+a2w*w^2);
    x_de_z=b0x_de_z/(z+a0x_de_z);
    z_de_w=(1+w)/(1-w);
    x_de_w=hornerij(x_de_z,z_de_w);
    w_de_x=horner11_inv(x_de_w,'x');
    f_de_x=hornerij(f_de_w,w_de_x,"ld");
    num_f_de_x=numer(f_de_x);
    den_f_de_x=denom(f_de_x);
    b0x = coeff(num_f_de_x,0)
    b1x = coeff(num_f_de_x,1)
    b2x = coeff(num_f_de_x,2)
    a0x = coeff(den_f_de_x,0)
    a1x = coeff(den_f_de_x,1)
    a2x = coeff(den_f_de_x,2)
    simp_mode(old_simp_mode);
  endfunction
function v_noise=clc_var_noise(Nz,Dz,NBECH_NORME2)
  sigmai=norme_ND(Nz(1),Dz(1),NBECH_NORME2,2);
  i_noise=definedfields(sigmai);
  i=find(i_noise>1);
  i_noise=i_noise(i);
  var_noise=[];
  for i=i_noise,
    vi=sigmai(i)^2;
    var_noise=[var_noise,vi];
  end
  v_noise=sum(var_noise);
endfunction
function mx_noise=clc_max_noise(Nz,Dz,NBECH_NORME1)
  mx_noise=norme_ND(Nz(1),Dz(1),NBECH_NORME1,1);
  i_noise=definedfields(mx_noise);
  i=find(i_noise>1);// ignore input
  i_noise=i_noise(i);
  max_noise=[];
  for i=i_noise,
    mxi=mx_noise(i);
    max_noise=[max_noise,mxi];
  end
  mx_noise=sum(abs(max_noise));
endfunction
function vx=compute_vx(vn,switch_c_ideal)
  vx=vn;
  if (vn==[]) then
    vx=1;
    return
  end
  if (switch_c_ideal==%t) then
    return
  end
  if (real(vx)<=1e-10) then
    error("unstable system :vx="+string(vx));
  end
// z transfer function associated to (1-w)/(1+w/vn) is b0/(z+a0)
  b0=2*vx/(1+vx);
  a0=(vx-1)/(1+vx);
  a=abs(a0);
// now find integer L such as a0=+/-[1-2^L]<=> 2^L=1-abs(a0);
  L=log2(1-a);
  L=round(L);
  a=1-2^L;
// now get new a0 and compute vx for this value;
  a0=sign(a0)*a;
  vx =(1+a0)/(1-a0);
endfunction

