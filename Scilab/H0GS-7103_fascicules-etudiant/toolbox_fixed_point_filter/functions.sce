function result=clc_sens_nd(X,n0,n1,n2,d0,d1,d2)
  NB_X=max(size(X));
  l_DH=list();
  DHND=zeros(2,3);
  for i=1:NB_X,
      x=X(i);
      t1 = x^2
      t2 = d2*t1+d1*x+d0
      t3 = 1/t2
      t4 = 1/t2^2
      t5 = n2*t1+n1*x+n0
      DHND(1,1) = t3
      DHND(1,2) = x*t3
      DHND(1,3) = t1*t3
      DHND(2,1) = -t4*t5
      DHND(2,2) = -x*t4*t5
      DHND(2,3) = -t1*t4*t5
      l_DH(i)=DHND;
  end
  if (NB_X==1) then
    result=DHND;
  else
    result=l_DH;
  end
endfunction

function result=clc_sens_abcd(X,A,B,C,D)
  a11=A(1,1);a12=A(1,2);
  a21=A(2,1);a22=A(2,2);
  b1=B(1);b2=B(2);
  c1=C(1);c2=C(2);
  d=D;
  NB_X=max(size(X));
  l_DH=list();
  DHABCD=zeros(3,3);
  for i=1:NB_X,
      x=X(i);
      t1 = -d*x
      t2 = x^2
      t3 = t2-a22*x-a11*x+a11*a22-a12*a21
      t4 = 1/t3
      t5 = -x
      t6 = 1/t3^2
      t7 = d*t2-a22*d*x-a11*d*x+b2*c2*x+b1*c1*x+a11*a22*d-a12*a21*d..
          -a11*b2*c2+a21*b1*c2+a12*b2*c1-a22*b1*c1
      DHABCD(1,1) = (t1+a22*d-b2*c2)*t4-(t5+a22)*t6*t7
      DHABCD(1,2) = a21*t6*t7+(b2*c1-a21*d)*t4
      DHABCD(1,3) = (c1*x+a21*c2-a22*c1)*t4
      DHABCD(2,1) = a12*t6*t7+(b1*c2-a12*d)*t4
      DHABCD(2,2) = (t1+a11*d-b1*c1)*t4-(t5+a11)*t6*t7
      DHABCD(2,3) = (c2*x-a11*c2+a12*c1)*t4
      DHABCD(3,1) = (b1*x+a12*b2-a22*b1)*t4
      DHABCD(3,2) = (b2*x-a11*b2+a21*b1)*t4
      DHABCD(3,3) = 1
      l_DH(i)=DHABCD;
  end
  if (NB_X==1) then
    result=DHABCD;
  else
    result=l_DH;
  end
endfunction
  function [x_de_y]=horner11_inv(y_de_x,namey)
    [lhs,rhs]=argn(0);
    if (rhs<2) then
      namey='y';
    end
      byx=numer(y_de_x);
      ayx=denom(y_de_x);
      b0yx=coeff(byx,0);
      b1yx=coeff(byx,1);
      a0yx=coeff(ayx,0);
      a1yx=coeff(ayx,1);
      b0xy = b0yx
      b1xy = -a0yx
      a0xy = -b1yx
      a1xy = a1yx
      old_simp_mod=simp_mode(); 
      simp_mode(%f);
      bfx=poly([b0xy,b1xy],namey,"coeff");
      afx=poly([a0xy,a1xy],namey,"coeff");
      x_de_y=bfx/afx;
      simp_mode(old_simp_mod);

  endfunction
  function [val_x1,val_x2]=inv_horner_2(y_de_x,val_y)
    tol=1e-50;
    byx=numer(y_de_x);
    ayx=denom(y_de_x);
    b0yx=coeff(byx,0);
    b1yx=coeff(byx,1);
    b2yx=coeff(byx,2);
    a0yx=coeff(ayx,0);
    a1yx=coeff(ayx,1);
    a2yx=coeff(ayx,2);
  // merci maxima
    nx1 = -sqrt((a1yx^2-4*a0yx*a2yx)*val_y^2+(4*a0yx*b2yx-2*a1yx..
     *b1yx+4*a2yx*b0yx)*val_y-4*b0yx*b2yx+b1yx^2)-a1yx*val_y+b1yx;
    nx2 = sqrt((a1yx^2-4*a0yx*a2yx)*val_y^2+(4*a0yx*b2yx-2*a1yx..
        *b1yx+4*a2yx*b0yx)*val_y-4*b0yx*b2yx+b1yx^2)-a1yx*val_y+b1yx
    dx1 = 2*a2yx*val_y-2*b2yx
    dx2 = 2*a2yx*val_y-2*b2yx
    if (abs(dx1)<=tol*abs(nx1)) then
      val_x1=%inf
    else
      val_x1=nx1/dx1;
    end
    if (abs(dx2)<=tol*abs(nx2)) then
      val_x2=%inf
    else
      val_x2=nx2/dx2;
    end

  endfunction
  function vn=my_varn(x)
    if (typeof(x)=="list") then
      for i=definedfields(x),
        xi=x(i);
        vi=my_varn(xi);
        if (vi~=[]) then
          vn=vi;
          return; 
        end
      end
      vn=[];
      return;
    end
    n=numer(x);
    if (typeof(n)=="polynomial" ) then
      vn=varn(n);
      return
    end
    d=numer(x);
    if (typeof(d)=="polynomial" ) then
      vn=varn(d);
      return
    end
    vn=[];
  endfunction
  function f_de_x=horner12(f_de_y,y_de_x)
     byx=numer(y_de_x);
     ayx=denom(y_de_x);
     nx=my_varn(y_de_x);
     if (nx==[]) then
       nx="x";
     end
     x=poly(0,nx);
     b0yx=coeff(byx,0);
     b1yx=coeff(byx,1);
     b2yx=coeff(byx,2);
     a0yx=coeff(ayx,0);
     a1yx=coeff(ayx,1);
     a2yx=coeff(ayx,2);
     bfy=numer(f_de_y);
     afy=denom(f_de_y);
     b0fy=coeff(bfy,0);
     b1fy=coeff(bfy,1);
     a0fy=coeff(afy,0);
     a1fy=coeff(afy,1);

     b0fx = b0yx*b1fy+a0yx*b0fy
     b1fx = b1fy*b1yx+a1yx*b0fy
     b2fx = b1fy*b2yx+a2yx*b0fy
     a0fx = a1fy*b0yx+a0fy*a0yx
     a1fx = a1fy*b1yx+a0fy*a1yx
     a2fx = a1fy*b2yx+a0fy*a2yx

     old_simp_mod=simp_mode();
     simp_mode(%f);
     bfx=poly([b0fx,b1fx,b2fx],nx,"coeff");
     afx=poly([a0fx,a1fx,a2fx],nx,"coeff");
     f_de_x=bfx/afx;
     simp_mode(old_simp_mod);

  endfunction
  function [f_de_x]=horner22(f_de_y,y_de_x)
      byx=numer(y_de_x);
      ayx=denom(y_de_x);
      if (my_degree(byx)>0) then
         nx=my_varn(byx);
      elseif (my_degree(ayx)>0) then
         nx=my_varn(byx);
      else
        nx="x";
      end
      x=poly(0,nx);
      b0yx=coeff(byx,0);
      b1yx=coeff(byx,1);
      b2yx=coeff(byx,2);
      a0yx=coeff(ayx,0);
      a1yx=coeff(ayx,1);
      a2yx=coeff(ayx,2);
      bfy=numer(f_de_y);
      afy=denom(f_de_y);
      b0fy=coeff(bfy,0);
      b1fy=coeff(bfy,1);
      b2fy=coeff(bfy,2);
      a0fy=coeff(afy,0);
      a1fy=coeff(afy,1);
      a2fy=coeff(afy,2);
      t1 = a0yx^2
      t2 = b0yx^2
      t3 = a1yx^2
      t4 = b1yx^2
      t5 = a2yx^2
      t6 = b2yx^2
      t7 = 2*a2fy*b0yx+a0yx*a1fy
      b0fx = t2*b2fy+a0yx*b0yx*b1fy+t1*b0fy
      b1fx = 2*b0yx*b1yx*b2fy+a0yx*b1fy*b1yx+a1yx..
        *b0yx*b1fy+2*a0yx*a1yx*b0fy
      b2fx = (2*b0yx*b2fy+a0yx*b1fy)*b2yx+t4*b2fy+a1yx..
        *b1fy*b1yx+a2yx*b0yx*b1fy+(2*a0yx*a2yx+t3)..
        *b0fy
      b3fx = (2*b1yx*b2fy+a1yx*b1fy)*b2yx+a2yx*b1fy..
        *b1yx+2*a1yx*a2yx*b0fy
      b4fx = b2fy*t6+a2yx*b1fy*b2yx+t5*b0fy
      a0fx = a2fy*t2+a0yx*a1fy*b0yx+a0fy*t1
      a1fx = t7*b1yx+a1fy*a1yx*b0yx+2*a0fy*a0yx..
        *a1yx
      a2fx = t7*b2yx+a2fy*t4+a1fy*a1yx*b1yx+a1fy*a2yx..
        *b0yx+2*a0fy*a0yx*a2yx+a0fy*t3
      a3fx = (2*a2fy*b1yx+a1fy*a1yx)*b2yx+a1fy*a2yx..
        *b1yx+2*a0fy*a1yx*a2yx
      a4fx = a2fy*t6+a1fy*a2yx*b2yx+a0fy*t5
      old_simp_mod=simp_mode(); 
      simp_mode(%f);
      bfx=poly([b0fx,b1fx,b2fx,b3fx,b4fx],nx,"coeff");
      afx=poly([a0fx,a1fx,a2fx,a3fx,a4fx],nx,"coeff");
      f_de_x=bfx/afx;
      simp_mode(old_simp_mod);

  endfunction
  function Fn=normalize(F,switch_normalize)
    [lhs,rhs]=argn(0);
    if (rhs<2) then
      switch_normalize="hd"; // higher denomcoeff
    end 
    if (typeof(F)=="list") then
      l=length(F);
      Fn=list();
      for i=1:l,
        Fn(i)=normalize(F(i),switch_normalize);
      end
      return 
    end
    old_simp_mode=simp_mode();
    simp_mode(%f);
    dF=denom(F);
    cfs_den=coeff(dF);
    nF=numer(F);
    cfs_num=coeff(nF);
    deg_F=max([my_degree(nF),my_degree(dF)]);
    if (switch_normalize=='hd') then
      cnorm=cfs_den($);
    elseif (switch_normalize=='ld') then
      cnorm=cfs_den(1);
    elseif (switch_normalize=='hn') then
      cnorm=cfs_num($);
    elseif (switch_normalize=='ln') then
      cnorm=cfs_num(1);
    else
      Fn=F;
      return
    end
    if (deg_F==0) then
      Fn=(nF/cnorm)/(dF/cnorm);
      return
    end
    name_x=my_varn(F); // get name of variable x
    Fn=poly(cfs_num/cnorm,name_x,"coeff")/poly(cfs_den/cnorm,name_x,"coeff");
    simp_mode(old_simp_mode);
  endfunction
  function [degree_n,degree_d]=order_filter(list_F)
    degree_n=0;degree_d=0;
    for i=1:length(list_F),
      Ni=numer(list_F(i));
      Di=denom(list_F(i));
      degree_n=degree_n+my_degree(Ni);
      degree_d=degree_d+my_degree(Di);
    end

  endfunction 
  function list_F_scaled=distribute_gain(gain,list_F)
    sign_gain=sign(gain);
    gain=abs(gain);
    [degree_N,order]=order_filter(list_F);
    list_F_scaled=list();
    if (order==0) then
      N1=numer(list_F(1));
      D1=denom(list_F(1));
      list_F_scaled(1)=sign_gain*gain*coeff(N1,0)/coeff(D1,0);
      return;
    end
    old_simp_mode=simp_mode();
    simp_mode(%f);
    gain=gain^(1/order);
    for i=1:length(list_F),
      Ni=numer(list_F(i));
      Di=denom(list_F(i));
      Ni=Ni*gain^(my_degree(Di));
      list_F_scaled(i)=Ni/Di;
    end
    list_F_scaled(1)=sign_gain*list_F_scaled(1);
    simp_mode(old_simp_mode);
  endfunction
  function res=get_as_product(l)
    res=[];
    for li=l,
      if res==[] then
        res=li; 
      else 
        res=res.*li;
      end 
    end 
  endfunction
  function res=get_as_sum(l)
    res=[];
    for li=l,
      res=res+li;
    end
  endfunction
  function [f_de_x]=hornerij(f_de_y,y_de_x,switch_normalize)
    [lhs,rhs]=argn(0);
    if (rhs<3) then
      switch_normalize=[];
    end
    if (typeof(f_de_y)=="list") then
      fd=definedfields(f_de_y);
      f_de_x=list();
      if (max(size(fd))==0) then
        return;
      end
      if (fd(1)==0) then
        f_de_x(0)=fd(0);
      end
      i_fd=find(fd>0);
      for i=fd(i_fd),
        f_de_x(i)=hornerij(f_de_y(i),y_de_x,switch_normalize);
      end
      return
    end
    f_de_x="bad";
    if (y_de_x==[]) then
      f_de_x=[];
      return
    end
    i=max([my_degree(numer(f_de_y)),my_degree(denom(f_de_y))]);
    j=max([my_degree(numer(y_de_x)),my_degree(denom(y_de_x))]);
    if (i==0) then
      f_de_x=f_de_y;
    end
    if (j==0) then
      f_de_x=my_horner(f_de_y,y_de_x);
    end
    if (i==1) then
      if (j==1) then
        f_de_x=horner11(f_de_y,y_de_x);
      end
      if (j==2) then
        f_de_x=horner12(f_de_y,y_de_x);
      end
    end
    if (i==2) then
      if (j==1) then
        f_de_x=horner21(f_de_y,y_de_x);
      end
      if (j==2) then
        f_de_x=horner22(f_de_y,y_de_x);
      end
    end
    if (i==3) then
      if (j==1) then
        f_de_x=horner31(f_de_y,y_de_x);
      end
    end
    if (i==4) then
      if (j==1) then
        f_de_x=horner41(f_de_y,y_de_x);
      end
    end
    if (typeof(f_de_x)=='string') then
      pause
      error("bad input : horner"+string(i)+string(j)+"(f_de_y,y_de_x) not yet implemented");
    end
    if (switch_normalize~=[]) then
      f_de_x=normalize(f_de_x,switch_normalize);
    end
  endfunction
  function [f_de_x]=horner11(f_de_y,y_de_x)

    byx=numer(y_de_x);
    ayx=denom(y_de_x);
    if (my_degree(byx)>0) then
       nx=my_varn(byx);
    elseif (my_degree(ayx)>0) then
       nx=my_varn(byx);
    else
      nx="x";
    end
    x=poly(0,nx);
    b0yx=coeff(byx,0);
    b1yx=coeff(byx,1);
    a0yx=coeff(ayx,0);
    a1yx=coeff(ayx,1);
    bfy=numer(f_de_y);
    afy=denom(f_de_y);
    b0fy=coeff(bfy,0);
    b1fy=coeff(bfy,1);
    a0fy=coeff(afy,0);
    a1fy=coeff(afy,1);
    b0fx = b0yx*b1fy+a0yx*b0fy
    b1fx = b1fy*b1yx+a1yx*b0fy
    a0fx = a1fy*b0yx+a0fy*a0yx
    a1fx = a1fy*b1yx+a0fy*a1yx
    old_simp_mod=simp_mode();
    simp_mode(%f);
    bfx=poly([b0fx,b1fx],nx,"coeff");
    afx=poly([a0fx,a1fx],nx,"coeff");
    f_de_x=bfx/afx;
    simp_mode(old_simp_mod);
  endfunction
  function [f_de_x]=horner21(f_de_y,y_de_x)
      byx=numer(y_de_x);
      ayx=denom(y_de_x);
      if (my_degree(byx)>0) then
         nx=my_varn(byx);
      elseif (my_degree(ayx)>0) then
         nx=my_varn(byx);
      else
        nx="x";
      end
      x=poly(0,nx);
      b0yx=coeff(byx,0);
      b1yx=coeff(byx,1);
      a0yx=coeff(ayx,0);
      a1yx=coeff(ayx,1);
      bfy=numer(f_de_y);
      afy=denom(f_de_y);
      b0fy=coeff(bfy,0);
      b1fy=coeff(bfy,1);
      b2fy=coeff(bfy,2);
      a0fy=coeff(afy,0);
      a1fy=coeff(afy,1);
      a2fy=coeff(afy,2);
      t1 = a0yx^2
      t2 = b0yx^2
      t3 = a1yx^2
      t4 = b1yx^2
      b0fx = t2*b2fy+a0yx*b0yx*b1fy+t1*b0fy
      b1fx = 2*b0yx*b1yx*b2fy+a0yx*b1fy*b1yx+a1yx*b0yx*b1fy+2*a0yx*a1yx..
        *b0fy
      b2fx = t4*b2fy+a1yx*b1fy*b1yx+t3*b0fy
      a0fx = a2fy*t2+a0yx*a1fy*b0yx+a0fy*t1
      a1fx = (2*a2fy*b0yx+a0yx*a1fy)*b1yx+a1fy*a1yx*b0yx+2*a0fy*a0yx..
        *a1yx
      a2fx = a2fy*t4+a1fy*a1yx*b1yx+a0fy*t3
      old_simp_mod=simp_mode(); 
      simp_mode(%f);
      bfx=poly([b0fx,b1fx,b2fx],nx,"coeff");
      afx=poly([a0fx,a1fx,a2fx],nx,"coeff");
      f_de_x=bfx/afx;
      simp_mode(old_simp_mod);
  endfunction
  function [f_de_x]=horner31(f_de_y,y_de_x)
      byx=numer(y_de_x);
      ayx=denom(y_de_x);
      if (my_degree(byx)>0) then
         nx=my_varn(byx);
      elseif (my_degree(ayx)>0) then
         nx=my_varn(byx);
      else
        nx="x";
      end
      x=poly(0,nx);
      b0yx=coeff(byx,0);
      b1yx=coeff(byx,1);
      a0yx=coeff(ayx,0);
      a1yx=coeff(ayx,1);
      bfy=numer(f_de_y);
      afy=denom(f_de_y);
      b0fy=coeff(bfy,0);
      b1fy=coeff(bfy,1);
      b2fy=coeff(bfy,2);
      b3fy=coeff(bfy,3);
      a0fy=coeff(afy,0);
      a1fy=coeff(afy,1);
      a2fy=coeff(afy,2);
      a3fy=coeff(afy,3);
      t1 = a0yx^3
      t2 = a0yx^2
      t3 = b0yx^2
      t4 = b0yx^3
      t5 = a1yx^2
      t6 = b1yx^2
      t7 = a1yx^3
      t8 = b1yx^3
      b0fx = t4*b3fy+a0yx*t3*b2fy+t2*b0yx*b1fy+t1*b0fy
      b1fx = 3*t3*b1yx*b3fy+(2*a0yx*b0yx*b1yx+a1yx*t3)*b2fy+t2*b1fy*b1yx..
        +2*a0yx*a1yx*b0yx*b1fy+3*t2*a1yx*b0fy
      b2fx = 3*b0yx*t6*b3fy+(a0yx*t6+2*a1yx*b0yx*b1yx)*b2fy+2*a0yx*a1yx..
        *b1fy*b1yx+t5*b0yx*b1fy+3*a0yx*t5*b0fy
      b3fx = t8*b3fy+a1yx*t6*b2fy+t5*b1fy*b1yx+t7*b0fy
      a0fx = a3fy*t4+a0yx*a2fy*t3+t2*a1fy*b0yx+a0fy*t1
      a1fx = (3*a3fy*t3+2*a0yx*a2fy*b0yx+t2*a1fy)*b1yx+a1yx*a2fy*t3+2..
        *a0yx*a1fy*a1yx*b0yx+3*a0fy*t2*a1yx
      a2fx = (3*a3fy*b0yx+a0yx*a2fy)*t6+(2*a1yx*a2fy*b0yx+2*a0yx*a1fy..
        *a1yx)*b1yx+a1fy*t5*b0yx+3*a0fy*a0yx*t5
      a3fx = a3fy*t8+a1yx*a2fy*t6+a1fy*t5*b1yx+a0fy*t7
      old_simp_mod=simp_mode();
      simp_mode(%f);
      bfx=poly([b0fx,b1fx,b2fx,b3fx],nx,"coeff");
      afx=poly([a0fx,a1fx,a2fx,a3fx],nx,"coeff");
      f_de_x=bfx/afx;
      simp_mode(old_simp_mod);
  endfunction
  function [f_de_x]=horner41(f_de_y,y_de_x)
      byx=numer(y_de_x);
      ayx=denom(y_de_x);
      if (my_degree(byx)>0) then
         nx=my_varn(byx);
      elseif (my_degree(ayx)>0) then
         nx=my_varn(byx);
      else
        nx="x";
      end
      x=poly(0,nx);
      b0yx=coeff(byx,0);
      b1yx=coeff(byx,1);
      a0yx=coeff(ayx,0);
      a1yx=coeff(ayx,1);
      bfy=numer(f_de_y);
      afy=denom(f_de_y);
      b0fy=coeff(bfy,0);
      b1fy=coeff(bfy,1);
      b2fy=coeff(bfy,2);
      b3fy=coeff(bfy,3);
      b4fy=coeff(bfy,4);
      a0fy=coeff(afy,0);
      a1fy=coeff(afy,1);
      a2fy=coeff(afy,2);
      a3fy=coeff(afy,3);
      a4fy=coeff(afy,4);
      t1 = a0yx^4
      t2 = a0yx^3
      t3 = a0yx^2
      t4 = b0yx^2
      t5 = b0yx^3
      t6 = b0yx^4
      t7 = a1yx^2
      t8 = b1yx^2
      t9 = a1yx^3
      t10 = b1yx^3
      t11 = a1yx^4
      t12 = b1yx^4
      b0fx = t6*b4fy+a0yx*t5*b3fy+t3*t4*b2fy+t2*b0yx*b1fy+t1*b0fy
      b1fx = 4*t5*b1yx*b4fy+(3*a0yx*t4*b1yx+a1yx*t5)*b3fy+(2*t3*b0yx..
        *b1yx+2*a0yx*a1yx*t4)*b2fy+t2*b1fy*b1yx+3*t3*a1yx*b0yx*b1fy+4..
        *t2*a1yx*b0fy
      b2fx = 6*t4*t8*b4fy+(3*a0yx*b0yx*t8+3*a1yx*t4*b1yx)*b3fy+(t3*t8..
        +4*a0yx*a1yx*b0yx*b1yx+t7*t4)*b2fy+3*t3*a1yx*b1fy*b1yx+3*a0yx..
        *t7*b0yx*b1fy+6*t3*t7*b0fy
      b3fx = 4*b0yx*t10*b4fy+(a0yx*t10+3*a1yx*b0yx*t8)*b3fy+(2*a0yx..
        *a1yx*t8+2*t7*b0yx*b1yx)*b2fy+3*a0yx*t7*b1fy*b1yx+t9*b0yx*b1fy..
        +4*a0yx*t9*b0fy
      b4fx = t12*b4fy+a1yx*t10*b3fy+t7*t8*b2fy+t9*b1fy*b1yx+t11*b0fy
      a0fx = a4fy*t6+a0yx*a3fy*t5+t3*a2fy*t4+t2*a1fy*b0yx+a0fy*t1
      a1fx = (4*a4fy*t5+3*a0yx*a3fy*t4+2*t3*a2fy*b0yx+t2*a1fy)*b1yx..
        +a1yx*a3fy*t5+2*a0yx*a1yx*a2fy*t4+3*t3*a1fy*a1yx*b0yx+4*a0fy*t2..
        *a1yx
      a2fx = (6*a4fy*t4+3*a0yx*a3fy*b0yx+t3*a2fy)*t8+(3*a1yx*a3fy*t4..
        +4*a0yx*a1yx*a2fy*b0yx+3*t3*a1fy*a1yx)*b1yx+t7*a2fy*t4+3*a0yx..
        *a1fy*t7*b0yx+6*a0fy*t3*t7
      a3fx = (4*a4fy*b0yx+a0yx*a3fy)*t10+(3*a1yx*a3fy*b0yx+2*a0yx*a1yx..
        *a2fy)*t8+(2*t7*a2fy*b0yx+3*a0yx*a1fy*t7)*b1yx+a1fy*t9*b0yx+4..
        *a0fy*a0yx*t9
      a4fx = a4fy*t12+a1yx*a3fy*t10+t7*a2fy*t8+a1fy*t9*b1yx+a0fy..
        *t11
      old_simp_mod=simp_mode();
      simp_mode(%f);
      bfx=poly([b0fx,b1fx,b2fx,b3fx,b4fx],nx,"coeff");
      afx=poly([a0fx,a1fx,a2fx,a3fx,a4fx],nx,"coeff");
      f_de_x=bfx/afx;
      simp_mode(old_simp_mod);
  endfunction

  function new_x=clean_conjugate_pairs(x_,rtol)
    [lhs,rhs]=argn(0);
    if (rhs<2) then
      rtol=1e-3;
    end
    x=x_;
    new_x=[];
    while x~=[] do,
      val_en_cours=x(1);
      new_x=[new_x;val_en_cours];
      x=x(2:$);// on enleve la premiere composante de x
    // on enleve le premier complexe conjugue de x
      if ((imag(val_en_cours)~=0 ) & (x~=[])) then
        x_moins_conjug_val=x-conj(val_en_cours);
        [best_conj,indice_a_enlever]=min(abs(x_moins_conjug_val));
        if (best_conj>rtol*abs(val_en_cours)) then
          error('cant find conjugate value');
        end
        indices_a_garder=1:(indice_a_enlever-1);
        indices_a_garder=[indices_a_garder,...
                         (indice_a_enlever+1):max(size(x))];
        x=x(indices_a_garder); 
      end

    end
  endfunction
  function F_de_x=filtre_from_roots(roots_N,roots_D,name_var_x)
    F_de_x=list();ind_Fi=0;
  // 1-on ne garde qu'un pole-zero des paires complexes conjugues
    roots_N=clean_conjugate_pairs(roots_N);

    roots_D=clean_conjugate_pairs(roots_D);
 // zeros reels en premier
    i_real=find(imag(roots_N)==0);
    i_imag=find(imag(roots_N)~=0);
    new_i_real=1:max(size(i_real));
    new_i_imag=1:max(size(i_imag));
    if new_i_imag~=[] then
      new_i_imag=new_i_imag+max(size(i_real));
    end
    roots_N=roots_N([new_i_real,new_i_imag]);
  // poles reels en premier
    i_real=find(imag(roots_D)==0);
    i_imag=find(imag(roots_D)~=0);
    new_i_real=1:max(size(i_real));
    new_i_imag=1:max(size(i_imag));
    if new_i_imag~=[] then
      new_i_imag=new_i_imag+max(size(i_real));
    end
    roots_D=roots_D([new_i_real,new_i_imag]);
  // factorisation
    nb_roots_N=max(size(roots_N));
    nb_roots_D=max(size(roots_D));

    i_root_N=1;i_root_D=1;
    while (i_root_N<=nb_roots_N)|(i_root_D<=nb_roots_D) do
    // racines du numerateur N de la ieme cellule
      roots_N_i=[];
      if (i_root_N<=nb_roots_N) then
        roots_N_i=roots_N(i_root_N);
        if (imag(roots_N_i))~=0 then
          roots_N_i=[roots_N_i;conj(roots_N_i)]
        end
        i_root_N=i_root_N+1
      end
      nb_roots_N_i=max(size(roots_N_i));
    // racines du denominateur D de la ieme cellule
      roots_D_i=[];
      if (i_root_D<=nb_roots_D) then
        roots_D_i=roots_D(i_root_D);
        if (imag(roots_D_i))~=0 then
          roots_D_i=[roots_D_i;conj(roots_D_i)]
        end
        i_root_D=i_root_D+1
      end
      nb_roots_D_i=max(size(roots_D_i));
    // on essaye de rajouter eventuellement une racine reelle au numerateur
      if (nb_roots_D_i>nb_roots_N_i)...
        &(nb_roots_N_i>0)...
        &(i_root_N<=nb_roots_N) then
        tmp=roots_N(i_root_N);
        if imag(tmp)==0 then
          roots_N_i=[roots_N_i;tmp];
          i_root_N=i_root_N+1;
        end
      end
    // on essaye de rajouter eventuellement une racine reelle au denominateur
      
      if (nb_roots_N_i>nb_roots_D_i)...
        &(nb_roots_D_i>0)...
        &(i_root_D<=nb_roots_D) then
        tmp=roots_D(i_root_D);
        if imag(tmp)==0 then
          roots_D_i=[roots_D_i;tmp];
          i_root_D=i_root_D+1;
        end
      end
    // ecriture de la ieme cellule du filtre 
      num_Fi=real(poly(roots_N_i,name_var_x,'roots'));
      den_Fi=real(poly(roots_D_i,name_var_x,'roots'));
      ind_Fi=ind_Fi+1;
      F_de_x(ind_Fi)=num_Fi/den_Fi;
    end
  endfunction
  function [y]=my_horner(y_de_x,x)
    type_y=typeof(y_de_x);
    if ((type_y=='rational')|(type_y=='polynomial')) then
      y=horner(y_de_x,x);
      return
    end
    if (type_y~='constant') then
      error('unhandled type of y:'+type_y+',y='+string(y_de_x)+' in function my_horner');
    end
    type_x=typeof(y_de_x);
    if (type_x=='constant') then
      y=ones(x)*y_de_x;
    end
    y=y_de_x;
  endfunction
  function [fact,F_de_x]=flts_horner(F_de_y,y_de_x,name_var_x,val_x_for_normalisation)
  // poles et zeros finis de F(y)
    roots_N_F_de_y=roots(numer(F_de_y));
    roots_D_F_de_y=roots(denom(F_de_y));
    N_y_de_x=numer(y_de_x);D_y_de_x=denom(y_de_x);
  // poles et zeros a l'infini de F(y)
    degre_relatif_F_de_y=my_degree(numer(F_de_y)) - my_degree(denom(F_de_y));
    nb_infinite_zero_F_de_y = max([0,-degre_relatif_F_de_y]);
    nb_infinite_pole_F_de_y = max([0, degre_relatif_F_de_y]);
  // on cherche les racines de F(y(name_var_x))
  // connaissant la racine root_y de F(y), alors
  // y(x)=root_y <=> N(x)/D(x)=root_y <=> N(x)-root_y.D(x) =0
  // <=> root_x=racine(N(x)-root_y.D(x)
  //-----------------------------------------------------------
  // zeros finis de F(y)
    roots_N_F_de_x=[];
    for i=1:max(size(roots_N_F_de_y)),
      root_y=roots_N_F_de_y(i);
      roots_x=roots(N_y_de_x-root_y*D_y_de_x);
      roots_N_F_de_x=[roots_N_F_de_x;roots_x];
    end
  // poles finis de F(y)
    roots_D_F_de_x=[];
    for i=1:max(size(roots_D_F_de_y)),
      root_y=roots_D_F_de_y(i);
      roots_x=roots(N_y_de_x-root_y*D_y_de_x);
      roots_D_F_de_x=[roots_D_F_de_x;roots_x];
    end
  // zeros infinis de F(y)
    for i_z=1:nb_infinite_zero_F_de_y,
      roots_x=roots(D_y_de_x);// root_y est implicitement egale a l'infini
      roots_N_F_de_x=[roots_x;roots_N_F_de_x];
    end
  // poles infinis de F(y)
    for i_z=1:nb_infinite_pole_F_de_y,
      roots_x=roots(D_y_de_x);// root_y est implicitement egale a l'infini
      roots_D_F_de_x=[roots_x;roots_D_F_de_x];
    end
  // racines classes par ordre de partie reelle decroissante
  // calcul du filtre F(x)
    F_de_x=filtre_from_roots(roots_N_F_de_x,roots_D_F_de_x,name_var_x);
  //---------------------------
  // normalisation , on doit avoir F_de_x(val_x_for_normalisation) / F_de_y(y(val_x_for_normalisation)) =1
  //---------------------------
    F_de_x0=1;
    for i_F=1:length(F_de_x),
      F_de_x0=F_de_x0*my_horner(F_de_x(i_F),val_x_for_normalisation);
    end
    y_de_x0=my_horner(y_de_x,val_x_for_normalisation);
    F_de_y_de_x0=my_horner(F_de_y,y_de_x0);
    fact=F_de_y_de_x0/F_de_x0;
    if (imag(fact)>=1e-3*real(fact)) then
     error('fact must be real, probleme in my my_horner :fact='+string(fact));
    end 
   fact=real(F_de_y_de_x0/F_de_x0);

  endfunction
function [fact,F1_de_x,F2_de_x]=old_my_horner(F_de_y,y_de_x,x,x0)
  nb_infinite_zero=my_degree(denom(F_de_y))-my_degree(numer(F_de_y));
  r_ni=roots(numer(F_de_y));
  r_di=roots(denom(F_de_y));
  N=numer(y_de_x);D=denom(y_de_x);
  r_ni_new=[];
  for i=1:max(size(r_ni)),
    r=r_ni(i); 
    r_ni_new=[r_ni_new;roots(N-r*D)];
  end
  r_di_new=[];
  for i=1:max(size(r_di)),
    r=r_di(i); 
    r_di_new=[r_di_new;roots(N-r*D)];
  end
// prise en compte des zeros infinis de F(y)
  for i_z=1:nb_infinite_zero,
    r_ni_new=[roots(D);r_ni_new]
  end
  r_ni_new=gsort(r_ni_new);
  r_di_new=gsort(r_di_new);
  k_n=round(max(size(r_ni_new)));k_n=min([k_n,2]);i_n=1:k_n;
  k_d=round(max(size(r_di_new)));k_d=min([k_d,2]);i_d=1:k_d;
  F1_de_x=(real(poly(r_ni_new(i_n),x,'roots')))/real(poly(r_di_new(i_d),x,'roots'));
  i_n=i_n+k_n;i_d=i_d+k_d;
  F2_de_x=[];
//  k_n=max(i_n);k_d=max(i_d);
  if (k_n<=max(size(r_ni_new)))&(k_d<max(size(r_di_new))) then
    F2_de_x=(real(poly(r_ni_new(i_n),x,'roots')))/real(poly(r_di_new(i_d),x,'roots'));
  end 

//---------------------------
// normalisation
//---------------------------
  F1_de_x0=my_horner(F1_de_x,x0);
  F2_de_x0=1;
  if F2_de_x~=[] then
    F2_de_x0=my_horner(F2_de_x,x0);
  end
  F_de_x0=F1_de_x0*F2_de_x0;
  y_de_x0=my_horner(y_de_x,x0);
  F_de_y_de_x0=my_horner(F_de_y,y_de_x0);
  fact=real(F_de_y_de_x0/F_de_x0);

endfunction
  function [re_pole_bessel,im_pole_bessel ]=poles_proto_bessel()
    i=0;re_pole_bessel=list();
    i=i+1;re_pole_bessel(i)=[-1.0];
    i=i+1;re_pole_bessel(i)=[-1.5];
    i=i+1;re_pole_bessel(i)=[-2.322185354626085,-1.838907322686957];
    i=i+1;re_pole_bessel(i)=[-2.896210602820374,-2.103789397179629];
    i=i+1;re_pole_bessel(i)=[-3.646738595329644,-3.351956399153533,-2.324674303181644];
    i=i+1;re_pole_bessel(i)=[-3.735708356325809,-4.248359395863341,-2.515932247810828];
    i=i+1;re_pole_bessel(i)=[-4.070139163638149,-4.758290528154692,-4.971786858527809,-2.68567687894326];
    i=i+1;re_pole_bessel(i)=[-5.204840790636815,-5.587886043263018,-4.368289217202387,-2.838983948897633];
    i=i+1;re_pole_bessel(i)=[-4.638439887180549,-5.604421819506745,-6.129367904278312,-6.297019181709255,-2.979260798180035];
    i=i+1;re_pole_bessel(i)=[-4.886219566859507,-5.967528328581106,-6.615290965494207,-6.922044905416984,-3.108916233649162];
    i=i+1;re_pole_bessel(i)=[-6.30133745487348,-7.057892387660837,-7.484229860753138,-7.622339845772002,...
     -3.229722089920449,-5.115648283907852];
    i=i+1;re_pole_bessel(i)=[-5.329708590878566,-6.611004249910838,-7.465571240514628,-7.997270599361981,...
     -8.253422011636266,-3.343023307802694];
    i=i+1;re_pole_bessel(i)=[-5.530680983342782,-6.900372826093448,-7.844380277461518,-8.47059177024474,...
     -8.947709674777842,-8.830252085723162,-3.449867220629461];
    i=i+1;re_pole_bessel(i)=[-5.720352383822838,-7.172395962267669,-8.198846969444732,-8.911000557393482,...
     -9.363145847908745,-9.583171393278866,-3.551086883379813];
    i=i+1;re_pole_bessel(i)=[-5.900151713687716,-7.42939699318654,-8.532459047914712,-9.323599337766417,...
     -9.859567223998978,-10.17091388640943,-10.27310993876788,-3.647356862485458];
    i=i+1;re_pole_bessel(i)=[-6.071241382947313,-3.739231797159573,-7.673240791008458,-8.847968191018845,...
     -9.712326360859841,-10.32511955359469,-10.71898580274073,-10.91188625070318];
    i=i+1;re_pole_bessel(i)=[-6.234580988593818,-3.827173785011302,-7.905449522045254,-9.147588340593824,...
     -10.08029848553065,-10.76412240742331,-11.23344656753372,-11.50809331727801,...
     -11.59848454321608,];
    i=i+1;re_pole_bessel(i)=[-6.390972783692626,-3.911572291160853,-8.127283941271747,-9.433132260052812,...
     -10.43001285429006,-11.18003887450456,-11.71895021768431,-12.06813272273588,...
     -12.23990490862936];
    i=i+1;re_pole_bessel(i)=[-6.541095062542047,-8.339800709613513,-11.57559912328394,-10.76353846485466,...
     -12.17923987205332,-12.59704643134085,-12.84283851209436,-12.92397579668734,...
     -9.706102465706795,-3.992758917882263];
    i=i+1;re_pole_bessel(i)=[-6.685526878189102,-8.543895719256225,-9.967762720318099,-11.08257941294922,...
     -11.95308243627589,-12.61735131888803,-13.09862982043165,-13.56762989801964,...
     -13.41277809702974,-4.071018561841822];
    i=0;im_pole_bessel=list();
    i=i+1;im_pole_bessel(i)=[0];
    i=i+1;im_pole_bessel(i)=[0.86602540378444];
    i=i+1;im_pole_bessel(i)=[0,1.754380959783722];
    i=i+1;im_pole_bessel(i)=[0.8672341289345,2.657418041856754];
    i=i+1;im_pole_bessel(i)=[0,1.742661416183204,3.571022920337974];
    i=i+1;im_pole_bessel(i)=[2.626272311447122,0.86750967323137,4.492672953653942];
    i=i+1;im_pole_bessel(i)=[3.517174047709739,1.739286061130635,0,5.420694130716743];
    i=i+1;im_pole_bessel(i)=[2.616175152642604,0.8676144453523,4.414442500471697,6.353911298604798];
    i=i+1;im_pole_bessel(i)=[5.317271675435613,3.498156917886484,1.737848383482586,0,7.291463688342146];
    i=i+1;im_pole_bessel(i)=[6.224985482471359,4.384947188941209,2.61156792080814,0.86766519543152,8.232699459073626];
    i=i+1;im_pole_bessel(i)=[5.276191743698154,3.489014503548059,1.737102820773622,0,9.177111568708765,7.13702075889276];
    i=i+1;im_pole_bessel(i)=[8.052906864250822,6.171534993057999,4.37016959336726,2.609066536843458,...
     0.86769357213821,10.12429680724093];
    i=i+1;im_pole_bessel(i)=[8.972247775156472,7.07064431216521,5.254903406609251,3.483868450145312,0,...
     1.73666640270322,11.07392855221587];
    i=i+1;im_pole_bessel(i)=[9.894707597494403,7.973217354176189,6.143041071333911,4.361604179803054,...
     2.607553317068085,0.86771104644945,12.02573803225442];
    i=i+1;im_pole_bessel(i)=[10.81999913775889,8.878982620776016,7.034393626316676,5.24225890859423,...
     3.480671138276991,1.736389052705585,0,12.97950107076093];
    i=i+1;im_pole_bessel(i)=[11.7478749385052,13.93502847581603,9.787697437274312,7.928772861190858,...
     6.125760893502319,4.356163310850401,2.606567190789165,0.86772233377829];
    i=i+1;im_pole_bessel(i)=[12.67812022905628,14.89215892490543,10.69914495727756,8.825999233731873,...
     7.012008364356669,5.234069581867707,3.478569415579056,1.736162435917267,0];
    i=i+1;im_pole_bessel(i)=[13.61054734894788,15.85075359693572,11.61313175301585,9.725900322624815,...
     7.90089294945306,6.114394709302814,4.352478880944004,2.605887380548245,0.86773382069103];
    i=i+1;im_pole_bessel(i)=[14.5449913027998,12.52948382020522,6.997078532577777,8.792292322546651,...
     5.228449302416018,3.477045160214775,1.736098184711914,0,10.62832119340769,16.81069206013159];
    i=i+1;im_pole_bessel(i)=[15.48130618753662,13.44804529107192,11.53311474299619,9.686090721543133,...
     7.882074294518934,6.106456437907657,4.349777737448759,0.86705403884221,...
     2.605809287037464,17.7718690688634];
    nb_F=length(re_pole_bessel);
    for i_F=1:nb_F,
      new_re=re_pole_bessel(i_F);
      new_im=im_pole_bessel(i_F);
    // classement
      [tmp,i_pol]=gsort(-new_im);
    // mise a jour
       new_re=new_re(i_pol);
       new_im=new_im(i_pol);
       re_pole_bessel(i_F)=new_re;
       im_pole_bessel(i_F)=new_im;
    end
  endfunction
  function F=all_filters_from_re_im(re_poles_F,im_poles_F)
    F=list();
    p=poly(0,'p');
    for i_F=1:length(re_b),
      re_pi=re_poles_F(i_F);
      im_pi=im_poles_F(i_F);
      [m,n]=size(re_pi);
      cells_filter=list();
      for i_pol=1:max(m,n),
         
        re=re_pi(i_pol);
        im=im_pi(i_pol);
        if (im~=0) then
          a2=1/(re^2+im^2);a1=-2*re*a2;a0=1;
          cells_filter(i_pol)=1/(a2*p^2+a1*p+a0)
        else
          a1=-1/re;a0=1;
          cells_filter(i_pol)=1/(a1*p+a0)
        end
      end
      tmp.fact=1;
      tmp.cells_filter=cells_filter;
      F(i_F)=tmp; 
    end
  endfunction
  function retard_groupe=grp_delay_from_arg_dg(w,arg_F)
    if max(size(arg_F))<2 then
      retard_groupe=zeros(arg_F);
      return 
    end
    derivateur=syslin('d',(%z-1)/%z);
    delta_arg_radians=flts(arg_F.',%pi/180*derivateur);
    delta_w=flts(w.',derivateur);
    retard_groupe=zeros(delta_arg_radians);
    i=find(delta_w~=0);
    retard_groupe(i)=delta_arg_radians(i)./delta_w(i);
    retard_groupe=retard_groupe.';
  endfunction 
  function val_continue=supprime_modulo(val_non_continue,val_mod)
  // correction des sauts > val_mod dans le vecteur val_non_continue
    [m,n]= size(val_non_continue);
  // on veut val_non_continue vecteur ligne
    if (m>n) then
      val_non_continue=val_non_continue.';
    end
    nb=max([n,m]);
    if nb>1 then
    // Other examples
      derivateur=syslin('d',(%z-1)/%z); 
      delta_val=flts(val_non_continue,derivateur);
      i=find(abs(delta_val)>val_mod/2);
      if (i~=[]) then
        sauts_delta_val=-val_mod*round(delta_val(i)/val_mod);
        delta_val=zeros(delta_val);
        delta_val(i)=sauts_delta_val;
        integrateur=1/derivateur;
        correction_val=flts(delta_val,integrateur);
        val_non_continue=val_non_continue+correction_val;
      end
    end
    if (m>n) then
      val_non_continue=val_non_continue.';
    end
    val_continue=val_non_continue;
  endfunction
  function [module_F,arg_F]=mag_arg_filter(w_bode,F_de_p)
    if typeof(F_de_p)=='rational' then
      L=list();L(1)=F_de_p;F_de_p=L;
    end
    [n,m]=size(w_bode);
    if (m>n) then 
      w_bode=w_bode.'; // on, transpose w_bode pour en faire un vecteur colonne
    end
    rep_F=ones(w_bode);
    
    NB_CELLULES=length(F_de_p);
    for i_c=1:NB_CELLULES,
      rep_Fi=my_horner( F_de_p(i_c) , %i*w_bode); //rep_Fi = F_de_p[i]( w = i. w_bode) 
      rep_F=rep_F .* rep_Fi;//  on multiplie terme a terme, d ou le .*
    end 
    module_F    = abs(rep_F);
    arg_F=imag(log(rep_F));
    arg_F=arg_F*180/%pi;
  // correction des sauts de phase
    arg_F=supprime_modulo(arg_F,360);
  endfunction
  function module_F=mag_filter(w_bode,F_de_p)
    if typeof(F_de_p)=='rational' then
      L=list();L(1)=F_de_p;F_de_p=L;
    end
    [n,m]=size(w_bode);
    if (m>n) then 
      w_bode=w_bode.'; // on, transpose w_bode pour en faire un vecteur colonne
    end
    rep_F=ones(w_bode);
    
    NB_CELLULES=length(F_de_p);
    for i_c=1:NB_CELLULES,
      rep_Fi=my_horner( F_de_p(i_c) , %i*w_bode); //rep_Fi = F_de_p[i]( w = i. w_bode) 
      rep_F=rep_F .* rep_Fi;//  on multiplie terme a terme, d ou le .*
    end 
    module_F    = abs(rep_F);
  endfunction
  function w0=find_w_for_mag(F_low_pass_de_p,mag)
    if mag>=(1-1e-20) then
      error('impossible de trouver w0 pour gain='+string(mag));
    end
    w0=1;mag0=mag_filter(w0,F_low_pass_de_p);facteur=10;
    seuil=1.01;
    if (mag>1/seuil) then
      seuil=(1-mag)/10;
      if seuil==0 then
        seuil=1e-10;
      end
      seuil=1+seuil;
    end
    while ( mag0>mag*seuil )|( mag0< mag/seuil) do
      if mag0>mag then
        w0=w0*facteur;
        newmag=mag_filter(w0,F_low_pass_de_p);
        if newmag<mag then
          facteur=sqrt(facteur)
        end
      else
        w0=w0/facteur;
        newmag=mag_filter(w0,F_low_pass_de_p);
        if newmag>mag then
          facteur=sqrt(facteur)
        end
      end
      newmag=mag_filter(w0,F_low_pass_de_p);
      mag0=newmag; 
    end 
  endfunction
  function cells=proto_lp_bessel_en_p(w1,gain0_db,gain1_db)
    p=poly(0,'p');
    cells=list();
    [re_b,im_b]=poles_proto_bessel();
    filtres=all_filters_from_re_im(re_b,im_b);
  // recherche des pulsations pour lesquelles les filtres ont une reponse egale a gain0
    gain0=10^(gain0_db/20);
    gain1=10^(gain1_db/20);
    NB_F=length(filtres);
    for i=1:NB_F,
      F_de_p=filtres(i).cells_filter;
      w0_i=find_w_for_mag(F_de_p,gain0);
      w1_i=w1*w0_i; 
      mag1_i=mag_filter(w1_i,F_de_p);
      if mag1_i<=gain1 then
      // on a trouve le filtre de degre minimum, on le denormalise et on degage
        for i_c=1:length(F_de_p),
          cells(i_c)=my_horner(F_de_p(i_c),p*w0_i);
        end
        return
      end
    end
    disp('too high order bessel filter, internal limit to highest order');
    F_de_p=filtres(NB_F).cells_filter;
    for i_c=1:length(F_de_p),
      cells(i_c)=my_horner(F_de_p(i_c),p*w0_i);
    end

  endfunction
  function cells=low_pass_bessel_order_n(w0,gain0_db,ordre)
    p=poly(0,'p');
    cells=list();
    [re_b,im_b]=poles_proto_bessel();
    filtres=all_filters_from_re_im(re_b,im_b);
  // recherche des pulsations pour lesquelles les filtres ont une reponse egale a gain0
    gain0=10^(gain0_db/20);
    NB_F=length(filtres);
    i=ordre;
    i=max([i,1]);
    i=min([i,NB_F]);
    F_de_p=filtres(i).cells_filter;
  // normatlisation
    w0_i=find_w_for_mag(F_de_p,gain0);
    for i_c=1:length(F_de_p),
      cells(i_c)=my_horner(F_de_p(i_c),p*(w0_i/w0));
    end

  endfunction
  function cpx_round=round_to_real(cpx,rel_tol)
    if (cpx==[]) then
      cpx_round=[];
      return
    end
    re=real(cpx);
    im=imag(cpx);
    modu=abs(cpx);
    i=find(abs(im)<rel_tol*modu);
    if (i~=[]) then
      im(i)=0*im(i);
      cpx_round=re+%i*im;
    else
      cpx_round=cpx;
    end 
  endfunction
function    [fact,F_p]=make_as_cascade(gain,zers,pols,name_var_x,is_real);
  if (pols~=[]) then
    [rp,ip]=gsort(real(pols));
    pols=pols(ip);
  end
  if (zers~=[]) then
    [rz,iz]=gsort(real(zers));
    zers=zers(iz);
  end
  F_p=filtre_from_roots(zers,pols,name_var_x);
  if (is_real==%t) then
    for i=1:length(F_p),
      Fi=F_p(i);
      ni= real(numer(Fi));
      di=real(denom(Fi));
      F_p(i)=ni/di;
    end
  end
  fact=gain;

endfunction
function [fact,F_p]=proto_lp_en_p_order_n(type_flt,n,gain03_db,gain12_db,must_be_odd)
  [lhs,rhs]=argn(0);
  if (rhs<5) then
    must_be_odd=%f;
  end
  is_even=modulo(n,2)==0;
  type_flt=convstr(type_flt,'l');// convert to lower case
  tmp=strindex(type_flt,'bes');// search indexes of string 'bes'
  is_bessel=tmp~=[]; 
  tmp=strindex(type_flt,'but');
  is_butterworth=tmp~=[];
  if ((must_be_odd==%t)&(is_even==%t)) then
    n=n+1;
  end
  if (~is_bessel) then
  // filtres autres que bessel
    ripple_1=1-10^(gain03_db/20);   // Gain > -3dB pour f<F1
    ripple_2=10^(gain12_db/20);     // Gain <-40dB pour f>F2
    if (is_butterworth) then
      g1=(1-ripple_1)^2;
      x1=(1-g1)/g1;
      w0=x1^(-1/(2*n));
    else
      w0=1;
    end
  // the order n of the filter is known, now compute it with analpf
    [hs,pols,zers,gain]=analpf(n,type_flt,[ripple_1,ripple_2],w0);
    must_be_real=%t;
    zers=round_to_real(zers,1e-6);
    pols=round_to_real(pols,1e-6);
    [fact,F_p]=make_as_cascade(gain,zers,pols,'s',must_be_real);
  else
  // filtres de bessel
    fact=1;F_p=proto_lp_bessel_en_p(w1,gain03_db,gain12_db)
  end
//  F_w(1)=fact*F_w(1);
endfunction
function [fact,F_p]=proto_low_pass_en_p(type_flt,w1,gain03_db,gain12_db,must_be_odd)
  [lhs,rhs]=argn(0);
  if (rhs<5) then
    must_be_odd=%f;
  end
  N_MAX=50; // max order for prototype filters
  type_flt=convstr(type_flt,'l');// convert to lower case
  tmp=strindex(type_flt,'bes');// search indexes of string 'bes'
  if tmp ==[] then
  // filtres autres que bessel
    Omeg1 = 2*atan(1); // pulsation 2.pi.f/fe for Att1
    Omeg2 = 2*atan(w1); // pulsation 2.pi.f/fe for Att2
    Omeg3 = 0;
    Omeg4 = 0;
    ripple_1=1-10^(gain03_db/20);   // Gain > -3dB pour f<F1
    ripple_2=10^(gain12_db/20);     // Gain <-40dB pour f>F2
    tmp1=strindex(type_flt,'but');
    is_butterworth=tmp1~=[];
    if (is_butterworth) then
      g1=(1-ripple_1)^2;
      g2=(ripple_2)^2;
      x1=(1-g1)/g1;
      x2=(1-g2)/g2;
      w2_sur_w1=w1/1;
      n=ceil(1/2*log(x2/x1)/log(w2_sur_w1));
      w0=x1^(-1/(2*n));
      if (n>N_MAX) then
        disp("WARNING in functions.sce->proto_low_pass_en_p ");
        disp("  prototype filter must have order = "+string(n));
        disp("  automatically limited to order = "+string(N_MAX));
        n=N_MAX;
      end
    else
      w0=1;
      n=1;

      while (n>0),
        if (type_flt=="cheb2") then
        // bug de scilab pour chebycheff type 2?...
          [hs,pols,zers,gain]=analpf(n,type_flt,[ripple_1,ripple_2],w1);
        else
          [hs,pols,zers,gain]=analpf(n,type_flt,[ripple_1,ripple_2],w0);
        end
        must_be_real=%t;
        zers=round_to_real(zers,1e-6);
        pols=round_to_real(pols,1e-6);
        [fact,F_p]=make_as_cascade(gain,zers,pols,'s',must_be_real);
        gain_w1=abs(fact*get_as_product(hornerij(F_p,%i*w1)));
        gain_w0=abs(fact*get_as_product(hornerij(F_p,%i*w0)));
        ok=(gain_w1<ripple_2*1.01)&((1-gain_w0)<ripple_1*1.01);
        if (ok) then
          n=-n;
        else
          n=n+1;
        end
        
        if (n>=N_MAX) then
          disp("WARNING in functions.sce->proto_low_pass_en_p");
          disp("  prototype filter must have order > "+string(N_MAX));
          disp("  automatically limited to order = "+string(N_MAX));
          n=-n;
        end
      end
      n=-n; 
    end
    is_even=modulo(n,2)==0;
    if ((must_be_odd==%t)&(is_even==%t)) then
      n=n+1;
      if (is_butterworth) then
        w0=x1^(-1/(2*n));
      end
    end
  // the order n of the filter is known, now compute it with analpf 
    if (type_flt=="cheb2") then
    // bug de scilab pour chebycheff type 2?...
      [hs,pols,zers,gain]=analpf(n,type_flt,[ripple_1,ripple_2],w1);
    else
      [hs,pols,zers,gain]=analpf(n,type_flt,[ripple_1,ripple_2],w0);
    end
    must_be_real=%t;
    zers=round_to_real(zers,1e-6);
    pols=round_to_real(pols,1e-6);
    [fact,F_p]=make_as_cascade(gain,zers,pols,'s',must_be_real);
  else
  // filtres de bessel
    fact=1;F_p=proto_lp_bessel_en_p(w1,gain03_db,gain12_db)
  end
//  F_w(1)=fact*F_w(1);
endfunction
function degre_P=my_degree(P)
// modif juin 2010, bug de la function degree
  m=length(P);
  if (m>1) then
    degre_P=degree(P);
    return
  end
  c=coeff(P);
  i=length(c);
  if (i>0) then
    while ((c(i)==0)&(i>1)) do
      i=i-1;
    end
  end
  degre_P=i-1;
endfunction
function [fact,F_p]=low_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db)
  if ( gain03_db <= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
    error('MAUVAIS GABARIT');
  end
  if ( w1 <= w0 ) then
    error('MAUVAIS GABARIT');
  end
  [fact,F_p]=proto_low_pass_en_p(type_flt,w1/w0,gain03_db,gain12_db);
  proto_vers_low_pass=%s/w0; // proto -> low_pass
  NB_F=length(F_p);
  new_Fp=list();k_f=0;
  for i_f=1:NB_F,
  //  simp_mode(%f);
    tmp=hornerij(F_p(i_f),proto_vers_low_pass,"hd");
  //  simp_mode(%t);
    N=numer(tmp);
    D=denom(tmp);
    dn=coeff(D,my_degree(D));
    nn=coeff(N,my_degree(N));
    if (nn==0)|(dn==0) then
      pause
    end
    N=N/nn;
    D=D/dn;
    tmp=N/D;
    fact=fact*nn/dn;
    k_f=k_f+1;new_Fp(k_f)=tmp;
  end
  F_p=new_Fp;
endfunction
function [fact,F_p]=high_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db)
  if ( gain03_db >= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
    error('MAUVAIS GABARIT');
  end
  if ( w1 <= w0 ) then
    error('MAUVAIS GABARIT');
  end
  [fact,F_p]=proto_low_pass_en_p(type_flt,w1/w0,gain12_db,gain03_db);
  proto_vers_high_pass=w1/%s; // proto -> high_pass
  NB_F=length(F_p);
  new_Fp=list();k_f=0;
  for i_f=1:NB_F,
    tmp=hornerij(F_p(i_f),proto_vers_high_pass,"hd");
    N=numer(tmp);
    D=denom(tmp);
    dn=coeff(D,my_degree(D));
    nn=coeff(N,my_degree(N));
    N=N/nn;
    D=D/dn;
    tmp=N/D;
    fact=fact*nn/dn;
    k_f=k_f+1;new_Fp(k_f)=tmp;
  end
  F_p=new_Fp;
endfunction
  function [S1_w,S2_w,sigma1,sigma2]=allpass_low_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db)
    [fact_proto_w,F_proto_w,sproto_de_s]=get_proto_low_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db,%t);
    NB_F=length(F_proto_w);
    fct_norm=fact_proto_w^(1/NB_F);
    roots_w=[];
    deg_g=0;
    deg_f=0;
    s_ref_proto=%i*1;
    s_de_sproto=horner11_inv(sproto_de_s,'s');
    s_ref_reel=horner(s_de_sproto,s_ref_proto);
    for i=1:length(F_proto_w),
      ni= numer(F_proto_w(i));
      di= denom(F_proto_w(i))
      deg_f=deg_f+my_degree(ni);
      deg_g=deg_g+my_degree(di);
      ri=roots(di);
      roots_w=[roots_w;ri];
    end
    i=find(imag(roots_w)>=0);
    roots_w=roots_w(i);
  // work only for odd prototype denominators,
    if (modulo(deg_g,2)==0) then
      error("sorry, works only for odd my_degree prototype filter");
    end
    if (modulo(deg_f,2)==0) then
      sigma1=-1;
    else
      sigma1=1;
    end; 
    [zr,ir]=gsort(-real(roots_w));
    roots_w=roots_w(ir);
    nb_r=max(size(roots_w));
    S1_proto_w=list();
    val_S1_proto=1;val_S1_reel=1;
    k=0;k1=0;
    S1_w=list();
    w=poly(0,"w");
    moins_w=-w;
    for i_g1=1:2:nb_r,
      rk=roots_w(i_g1);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S1_proto_w(k)=nw/dw;
      val_S1_proto=val_S1_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S1_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k1=k1+1;S1_w(k1)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k1=k1+1;
        S1_w(k1)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    end
    sign_S1=round(real(val_S1_proto/val_S1_reel));
    S2_proto_w=list();
    val_S2_proto=1;val_S2_reel=1;
    k=0;k2=0;S2_w=list();
    for i_g2=2:2:nb_r,
      rk=roots_w(i_g2);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S2_proto_w(k)=nw/dw;
      val_S2_proto=val_S2_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S2_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k2=k2+1;S2_w(k2)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k2=k2+1;
        S2_w(k2)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    end

    sign_S2=round(real(val_S2_proto/val_S2_reel));
    NB_S1=length(S1_w);
    if (NB_S1==0) then
      S1_proto_w(1)=1;
      S1_w(1)=1;
    end
  // traitement 2eme branche S2
    NB_S2=length(S2_w);
    if (NB_S2==0) then
      S2_proto_w(1)=1;
      S2_w(1)=1;
    end
    sigma1=sign_S1*(-sigma1);
    sigma2=sign_S2;
  endfunction
  function [fact,F_p,sproto_de_s]=get_proto_low_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db,must_be_odd)
    [lhs,rhs]=argn(0);
    if (rhs<6) then
      must_be_odd=%f;
    end
    if ( gain03_db <= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
      error('MAUVAIS GABARIT');
    end
    if ( w1 <= w0 ) then
      error('MAUVAIS GABARIT');
    end
    [fact,F_p]=proto_low_pass_en_p(type_flt,w1/w0,gain03_db,gain12_db,must_be_odd);
    sproto_de_s=%s/w0; // proto -> low_pass
  endfunction

  function [S1_w,S2_w,sigma1,sigma2]=allpass_high_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db)
    [fact_proto_w,F_proto_w,sproto_de_s]=get_proto_high_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db,%t);
    NB_F=length(F_proto_w);
    fct_norm=fact_proto_w^(1/NB_F);
    roots_w=[];
    deg_g=0;
    deg_f=0;
    s_ref_proto=%i*1;
    s_de_sproto=horner11_inv(sproto_de_s,'s');
    s_ref_reel=horner(s_de_sproto,s_ref_proto);
    for i=1:length(F_proto_w),
      ni= numer(F_proto_w(i));
      di= denom(F_proto_w(i))
      deg_f=deg_f+my_degree(ni);
      deg_g=deg_g+my_degree(di);
      ri=roots(di);
      roots_w=[roots_w;ri];
    end
    i=find(imag(roots_w)>=0);
    roots_w=roots_w(i);
  // work only for odd prototype denominators,
    if (modulo(deg_g,2)==0) then
      error("sorry, works only for odd my_degree prototype filter");
    end
    if (modulo(deg_f,2)==0) then
      sigma1=-1;
    else
      sigma1=1;
    end; 
    [zr,ir]=gsort(-real(roots_w));
    roots_w=roots_w(ir);
    nb_r=max(size(roots_w));
    S1_proto_w=list();
    val_S1_proto=1;val_S1_reel=1;
    k=0;k1=0;
    S1_w=list();
    for i_g1=1:2:nb_r,
      rk=roots_w(i_g1);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S1_proto_w(k)=nw/dw;
      val_S1_proto=val_S1_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S1_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k1=k1+1;S1_w(k1)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k1=k1+1;
        S1_w(k1)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    end
    sign_S1=round(real(val_S1_proto/val_S1_reel));
    S2_proto_w=list();
    val_S2_proto=1;val_S2_reel=1;
    k=0;k2=0;S2_w=list();
    for i_g2=2:2:nb_r,
      rk=roots_w(i_g2);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S2_proto_w(k)=nw/dw;
      val_S2_proto=val_S2_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S2_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k2=k2+1;S2_w(k2)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k2=k2+1;
        S2_w(k2)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    end

    sign_S2=round(real(val_S2_proto/val_S2_reel));
    NB_S1=length(S1_w);
    if (NB_S1==0) then
      S1_proto_w(1)=1;
      S1_w(1)=1;
    end
  // traitement 2eme branche S2
    NB_S2=length(S2_w);
    if (NB_S2==0) then
      S2_proto_w(1)=1;
      S2_w(1)=1;
    end
    sigma1=sign_S1*(-sigma1);
    sigma2=sign_S2;
  endfunction
  function [fact,F_p,sproto_de_s]=get_proto_high_pass_en_p(type_flt,w0,w1,gain03_db,gain12_db,must_be_odd)
    [lhs,rhs]=argn(0);
    if (rhs<6) then
      must_be_odd=%f;
    end
    if ( gain03_db >= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
      error('MAUVAIS GABARIT');
    end
    if ( w1 <= w0 ) then
      error('MAUVAIS GABARIT');
    end
    [fact,F_p]=proto_low_pass_en_p(type_flt,w1/w0,gain12_db,gain03_db,must_be_odd);
    sproto_de_s=w1/%s; // proto -> high_pass
  endfunction

  function [S1_w,S2_w,sigma1,sigma2]=allpass_band_pass_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db)
    [fact_proto_w,F_proto_w,sproto_de_s]=get_proto_band_pass_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db,%t);
    NB_F=length(F_proto_w);
    fct_norm=fact_proto_w^(1/NB_F);
    roots_w=[];
    deg_g=0;
    deg_f=0;
    s_ref_proto=%i*1;
    [s_ref_reel,tmp]=inv_horner_2(sproto_de_s,s_ref_proto);
    for i=1:length(F_proto_w),
      ni= numer(F_proto_w(i));
      di= denom(F_proto_w(i))
      deg_f=deg_f+my_degree(ni);
      deg_g=deg_g+my_degree(di);
      ri=roots(di);
      roots_w=[roots_w;ri];
    end
    i=find(imag(roots_w)>=0);
    roots_w=roots_w(i);
  // work only for odd prototype denominators,
    if (modulo(deg_g,2)==0) then
      error("sorry, works only for odd my_degree prototype filter");
    end
    if (modulo(deg_f,2)==0) then
      sigma1=-1;
    else
      sigma1=1;
    end; 
    [zr,ir]=gsort(-real(roots_w));
    roots_w=roots_w(ir);
    nb_r=max(size(roots_w));
    S1_proto_w=list();
    val_S1_proto=1;val_S1_reel=1;
    k=0;k1=0;
    S1_w=list();
    for i_g1=1:2:nb_r,
      rk=roots_w(i_g1);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S1_proto_w(k)=nw/dw;
      val_S1_proto=val_S1_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S1_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k1=k1+1;S1_w(k1)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k1=k1+1;
        S1_w(k1)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    end
    sign_S1=round(real(val_S1_proto/val_S1_reel));
    S2_proto_w=list();
    val_S2_proto=1;val_S2_reel=1;
    k=0;k2=0;S2_w=list();
    for i_g2=2:2:nb_r,
      rk=roots_w(i_g2);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S2_proto_w(k)=nw/dw;
      val_S2_proto=val_S2_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S2_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k2=k2+1;S2_w(k2)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k2=k2+1;
        S2_w(k2)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    end

    sign_S2=round(real(val_S2_proto/val_S2_reel));
    NB_S1=length(S1_w);
    if (NB_S1==0) then
      S1_proto_w(1)=1;
      S1_w(1)=1;
    end
  // traitement 2eme branche S2
    NB_S2=length(S2_w);
    if (NB_S2==0) then
      S2_proto_w(1)=1;
      S2_w(1)=1;
    end
    sigma1=sign_S1*(-sigma1);
    sigma2=sign_S2;
  endfunction

function [fact,F_p,sproto_de_s]=get_proto_band_pass_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db,must_be_odd)
  [lhs,rhs]=argn(0);
  if (rhs<8) then
    must_be_odd=%f;
  end
  if ( gain03_db >= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
    error('MAUVAIS GABARIT');
  end
  if ( w1 <= w0 )|(w2<=w1)|(w3<=w2) then
    error('MAUVAIS GABARIT');
  end

  wc=sqrt(w1*w2);
  B=(w2-w1)/wc;
  sproto_de_s=1/B*(wc/%s+%s/wc); // proto -> band_pass
  w_proto=imag(my_horner(sproto_de_s,%i*[w0,w1,w2,w3]));
  w1_proto=min(abs([w_proto(1),w_proto(4)]));
  [fact,F_p]=proto_low_pass_en_p(type_flt,w1_proto,gain12_db,gain03_db,must_be_odd);
endfunction
function [fact,F_p]=band_pass_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db)
  if ( gain03_db >= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
    error('MAUVAIS GABARIT');
  end
  if ( w1 <= w0 )|(w2<=w1)|(w3<=w2) then
    error('MAUVAIS GABARIT');
  end

  wc=sqrt(w1*w2);
  B=(w2-w1)/wc;
  proto_vers_band_pass=1/B*(wc/%s+%s/wc); // proto -> band_pass
  w_proto=imag(my_horner(proto_vers_band_pass,%i*[w0,w1,w2,w3]));
  w1_proto=min(abs([w_proto(1),w_proto(4)]));
  [fact,F_p]=proto_low_pass_en_p(type_flt,w1_proto,gain12_db,gain03_db);
  NB_F=length(F_p);
  new_Fp=list();k_f=0;
  for i_f=1:NB_F,  
    [fct,new_cells]=flts_horner(F_p(i_f),proto_vers_band_pass,'s',%i*1);
    //tmp1=my_horner(F_p(i_f),proto_vers_band_pass);fct=1;tmp2=1;
    for i_cell=1:length(new_cells),
      k_f=k_f+1;new_Fp(k_f)=new_cells(i_cell);
    end
    fact=fact*fct;
  end
  F_p=new_Fp;
  NB_F=length(F_p);
  new_Fp=list();k_f=0;
  for i_f=1:NB_F,
    tmp=F_p(i_f);
    N=numer(tmp);
    D=denom(tmp);
    dn=coeff(D,my_degree(D));
    nn=coeff(N,my_degree(N));
    N=N/nn;
    D=D/dn;
    tmp=N/D;
    k_f=k_f+1;new_Fp(k_f)=tmp;  
    fact=fact*nn/dn;
  end
  F_p=new_Fp;
endfunction
  function [S1_w,S2_w,sigma1,sigma2]=allpass_band_stop_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db)
    [fact_proto_w,F_proto_w,sproto_de_s]=get_proto_band_stop_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db,%t);
    NB_F=length(F_proto_w);
    fct_norm=fact_proto_w^(1/NB_F);
    roots_w=[];
    deg_g=0;
    deg_f=0;
    s_ref_proto=%i*1;
    [s_ref_reel,tmp]=inv_horner_2(sproto_de_s,s_ref_proto);
    for i=1:length(F_proto_w),
      ni= numer(F_proto_w(i));
      di= denom(F_proto_w(i))
      deg_f=deg_f+my_degree(ni);
      deg_g=deg_g+my_degree(di);
      ri=roots(di);
      roots_w=[roots_w;ri];
    end
    i=find(imag(roots_w)>=0);
    roots_w=roots_w(i);
  // work only for odd prototype denominators,
    if (modulo(deg_g,2)==0) then
      error("sorry, works only for odd my_degree prototype filter");
    end
    if (modulo(deg_f,2)==0) then
      sigma1=-1;
    else
      sigma1=1;
    end; 
    [zr,ir]=gsort(-real(roots_w));
    roots_w=roots_w(ir);
    nb_r=max(size(roots_w));
    S1_proto_w=list();
    val_S1_proto=1;val_S1_reel=1;
    k=0;k1=0;
    S1_w=list();
    for i_g1=1:2:nb_r,
      rk=roots_w(i_g1);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S1_proto_w(k)=nw/dw;
      val_S1_proto=val_S1_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S1_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k1=k1+1;S1_w(k1)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k1=k1+1;
        S1_w(k1)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S1_reel=val_S1_reel*horner(S1_w(k1),s_ref_reel);
      end
    end
    sign_S1=round(real(val_S1_proto/val_S1_reel));
    S2_proto_w=list();
    val_S2_proto=1;val_S2_reel=1;
    k=0;k2=0;S2_w=list();
    for i_g2=2:2:nb_r,
      rk=roots_w(i_g2);
      if (imag(rk)==0) then
        dw=poly(rk,"w");
      else
        dw=poly([rk;conj(rk)],"w");
        dw=real(dw);
      end
      nw=horner(dw,moins_w);
      k=k+1;
      S2_proto_w(k)=nw/dw;
      val_S2_proto=val_S2_proto*horner(nw/dw,s_ref_proto);
      tmp=hornerij(S2_proto_w(k),sproto_de_s);
      nx=my_varn(dw);
      rdn=roots(denom(tmp));
    // real roots
      ip=find(imag(rdn)==0);
      rd=rdn(ip);
      for ir=1:max(size(rd)),
        rdi=rd(ir);
        rni=-rdi;
        k2=k2+1;S2_w(k2)=real(poly(rni,nx))/real(poly(rdi,nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    // complex roots
      ip=find(imag(rdn)>0);
      rd=rdn(ip);
      for ir=1:max(size(ip)),
        rdi=rd(ir);
        rni=-real(rdi)+%i*imag(rdi);
        k2=k2+1;
        S2_w(k2)=real(poly([rni;conj(rni)],nx))/real(poly([rdi;conj(rdi)],nx));
        val_S2_reel=val_S2_reel*horner(S2_w(k2),s_ref_reel);
      end
    end

    sign_S2=round(real(val_S2_proto/val_S2_reel));
    NB_S1=length(S1_w);
    if (NB_S1==0) then
      S1_proto_w(1)=1;
      S1_w(1)=1;
    end
  // traitement 2eme branche S2
    NB_S2=length(S2_w);
    if (NB_S2==0) then
      S2_proto_w(1)=1;
      S2_w(1)=1;
    end
    sigma1=sign_S1*(-sigma1);
    sigma2=sign_S2;
  endfunction
  function [fact,F_p,sproto_de_s]=get_proto_band_stop_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db,must_be_odd)
    [lhs,rhs]=argn(0);
    if (rhs<8) then
      must_be_odd=%f;
    end
    if ( gain03_db <= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
      error('MAUVAIS GABARIT');
    end
    if ( w1 <= w0 )|(w2<=w1)|(w3<=w2) then
      error('MAUVAIS GABARIT');
    end
    wc=sqrt(w0*w3);
    B=(w3-w0)/wc;
    sproto_de_s=B/(wc/%s+%s/wc); // proto -> coupe-bande
    // to avoid division by zero
    un_sur_w_proto=my_horner(1/sproto_de_s,%i*[w0,w1,w2,w3]);
    un_sur_w1_proto= max(abs(imag([un_sur_w_proto(2),un_sur_w_proto(3)])));
    w1_proto=1/un_sur_w1_proto;
    [fact,F_p]=proto_low_pass_en_p(type_flt,w1_proto,gain03_db,gain12_db,must_be_odd);
  endfunction

function [fact,F_p]=band_stop_en_p(type_flt,w0,w1,w2,w3,gain03_db,gain12_db)
  if ( gain03_db <= gain12_db )|(gain03_db>=0)|(gain12_db>=0) then
    error('MAUVAIS GABARIT');
  end
  if ( w1 <= w0 )|(w2<=w1)|(w3<=w2) then
    error('MAUVAIS GABARIT');
  end
  wc=sqrt(w0*w3);
  B=(w3-w0)/wc;
  proto_vers_band_stop=B/(wc/%s+%s/wc); // proto -> coupe-bande
  // to avoid division by zero
  un_sur_w_proto=my_horner(1/proto_vers_band_stop,%i*[w0,w1,w2,w3]);
  un_sur_w1_proto= max(abs(imag([un_sur_w_proto(2),un_sur_w_proto(3)])));
  w1_proto=1/un_sur_w1_proto;
  [fact,F_p]=proto_low_pass_en_p(type_flt,w1_proto,gain03_db,gain12_db);
  NB_F=length(F_p);
  new_Fp=list();k_f=0;

  for i_f=1:NB_F,
    [fct,new_cells]=flts_horner(F_p(i_f),proto_vers_band_stop,'s',%i*1);
    for i_cell=1:length(new_cells),
      k_f=k_f+1;new_Fp(k_f)=new_cells(i_cell);
    end
    fact=fact*fct;
  end
  F_p=new_Fp;
  NB_F=length(F_p);
  new_Fp=list();k_f=0;
  for i_f=1:NB_F,
    tmp=F_p(i_f);
    N=numer(tmp);
    D=denom(tmp);
    dn=coeff(D,my_degree(D));
    nn=coeff(N,my_degree(N));
    N=N/nn;
    D=D/dn;
    tmp=N/D;
    k_f=k_f+1;new_Fp(k_f)=tmp;  
    fact=fact*nn/dn;
  end
  F_p=new_Fp;
endfunction
function [fact,F_z]=low_pass_en_z(type_flt,f0_sur_fe,f1_sur_fe,gain03_db,gain12_db)
  v0=tan(%pi*f0_sur_fe);
  v1=tan(%pi*f1_sur_fe);
  [fact,F_w]=low_pass_en_p(type_flt,v0,v1,gain03_db,gain12_db)
  w_de_z=(%z-1)/(%z+1);
  F_z=list();
  for i_f=1:length(F_w),
    F_z(i_f)=my_horner(F_w(i_f),w_de_z);
  end
endfunction
function [fact,F_z]=high_pass_en_z(type_flt,f0_sur_fe,f1_sur_fe,gain03_db,gain12_db)
  v0=tan(%pi*f0_sur_fe);
  v1=tan(%pi*f1_sur_fe);
  [fact,F_w]=high_pass_en_p(type_flt,v0,v1,gain03_db,gain12_db)
  w_de_z=(%z-1)/(%z+1);
  F_z=list();
  for i_f=1:length(F_w),
    F_z(i_f)=my_horner(F_w(i_f),w_de_z);
  end
endfunction
function [fact,F_z]=band_pass_en_z(type_flt,f0_sur_fe,f1_sur_fe,f2_sur_fe,f3_sur_fe,gain03_db,gain12_db)
  v0=tan(%pi*f0_sur_fe);
  v1=tan(%pi*f1_sur_fe);
  v2=tan(%pi*f2_sur_fe);
  v3=tan(%pi*f3_sur_fe);
  [fact,F_w]=band_pass_en_p(type_flt,v0,v1,v2,v3,gain03_db,gain12_db)
  w_de_z=(%z-1)/(%z+1);
  F_z=list();
  for i_f=1:length(F_w),
    F_z(i_f)=my_horner(F_w(i_f),w_de_z);
  end
endfunction
function [fact,F_z]=band_stop_en_z(type_flt,f0_sur_fe,f1_sur_fe,f2_sur_fe,f3_sur_fe,gain03_db,gain12_db)
  v0=tan(%pi*f0_sur_fe);
  v1=tan(%pi*f1_sur_fe);
  v2=tan(%pi*f2_sur_fe);
  v3=tan(%pi*f3_sur_fe);
  [fact,F_w]=band_stop_en_p(type_flt,v0,v1,v2,v3,gain03_db,gain12_db)
  w_de_z=(%z-1)/(%z+1);
  F_z=list();
  for i_f=1:length(F_w),
    F_z(i_f)=my_horner(F_w(i_f),w_de_z);
  end
endfunction
  function y=simule_f_de_w(F_de_w,e)
    z_1=poly(0,'z_1');
    w_de_z_1=(1-z_1)/(1+z_1);
    F_de_z_1=F_de_w;
    for i=1:length(F_de_z_1),
      F_de_z_1(i)=hornerij(F_de_z_1(i),w_de_z_1,"ld");
    end
    y=simule_f_de_z_1(F_de_z_1,e);
  endfunction
  function y=simule_f_de_z(F_de_z,e)
    z_1=poly(0,'z_1');
    z_de_z_1=1/z_1;
    F_de_z_1=F_de_z;
    for i=1:length(F_de_z_1),
      F_de_z_1(i)=hornerij(F_de_z_1(i),z_de_z_1,"ld");
    end
    y=simule_f_de_z_1(Fz_1,e);
  endfunction
  function y=simule_f_de_z_1(F_de_z_1,e)
    [m,n]=size(e);
    if (m>n) then
      e=e.';
    end
    if typeof(F_de_z_1) == 'rational' then
      if (my_degree(numer(F_de_z_1))==0)&(my_degree(denom(F_de_z_1))==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=coeff(numer(F_de_z_1),0)/coeff(denom(F_de_z_1),0)*e.';
        return 
      end
      Fz=hornerij(F_de_z_1,1/%z,"hd"); // F(z) en fonction de F(z^-1)
      Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
      y=flts(e,sys_Fz);// dn=reponse impulsionnelle de F(z)
      y=y.';
      return
    end //    if typeof(F_de_z_1) == 'rational' then
    if typeof(F_de_z_1) == 'constant' then
      y=abs(F_de_z_1); 
      return
    end//    if typeof(F_de_z_1) == 'constante' then
    if typeof(F_de_z_1) == 'list' then
      y=e; 
      for i_f=length(F_de_z_1):-1:1,
        Fz_1i=F_de_z_1(i_f);
        if typeof(Fz_1i) == 'constant' then
          y=y*Fz_1i; 
        end//    if typeof(F_de_z_1) == 'constante' then
        if typeof(Fz_1i) == 'rational' then
          if (my_degree(numer(Fz_1i))==0)&(my_degree(denom(Fz_1i))==0) then
          // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
            y=y*coeff(numer(Fz_1i),0)/coeff(denom(Fz_1i),0);
          end
          if (my_degree(numer(Fz_1i))>0)|(my_degree(denom(Fz_1i))>0) then
            Fz=hornerij(Fz_1i,1/%z,"hd"); // F(z) en fonction de F(z^-1)
            Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
            y=flts(y,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end
        end //    if typeof(Fz_1i) == 'rational' then
      end //for i_f=length(F_de_z_1):-1:1,
      y=y.'; // norme1 de F(z) = somme (module(f(n))
      return
    end //    if typeof(F_de_z_1) == 'list' then
    error('type d entree non gere');
  endfunction
function z_b0gm=mydscr(sys,TEch,Retard);
  if type(sys)~=16 then
    error('arg 1 must be a linear system, see : syslin');
  end
  type_sys=typeof(sys);
  if type_sys=='rational' then
    sys=tf2ss(sys);
  end
  if typeof(sys)~='state-space' then
    error('arg 1 must be a linear system, see : syslin');
  end
  if ( sys.dt~='c' ) then
    error('sys must be a continuous system');
  end
  Retard1 = modulo( Retard , TEch )/TEch;
  Retard2 = floor( Retard / TEch );
  if Retard1 < 1e-4 then
    sys_z=dscr(sys,TEch); // z(BOG) avec fonction scilab dscr
  else
  // Tr en z modifiee de Z(BO.G), voir DE LARMINAT...
    Ap=sys.A;
    Bp=sys.B;
    Cp=sys.C;
    Dp=sys.D;

    [tmp,nx]  =size(Ap);
    [ny,nu]   =size(Dp);

    Aprime =[ Ap , Bp ; zeros( nu , nx+nu) ] ;
    A1     = expm( Aprime *    Retard1  * TEch );
    A2     = expm( Aprime *( 1-Retard1) * TEch );
    Aprime = expm( Aprime  * TEch)
    if nx > 0 then
      B1 = A1(1:nx,(nx+1):(nx+nu));
      B2 = A2(1:nx,(nx+1):(nx+nu));
      B1 = A2(1:nx,1:nx) * B1 ;
    else
      B1=[];
      B2=[];
    end
  // Rep D'etat du systeme discret
    Az = [ Aprime(1:nx,1:nx) , B1 ; zeros(nu , nx+nu ) ] ;
    Bz = [ B2 ; eye(nu,nu) ] ;
    Cz = [ Cp , Dp   ] ;
    Dz = zeros( ny,nu  );
    sys_z=syslin(TEch,Az,Bz,Cz,Dz);
  end
// ajout du nombre entier de retards
  if Retard2>0 then
    sys_z=myss2tf(sys_z)/(%z^Retard2);
    if type_sys~='rational' then
      sys_z=tf2ss(sys_z);
    end
  else
    if type_sys=='rational' then
      sys_z=myss2tf(sys_z);
    end
  end
  z_b0gm=sys_z;
endfunction
function [Z,CovZ] = clccovz(pol,CovCoeffs)
// etant donne un polyneme dont on connaet la matrice de covariance des coefficients
// La fonction ClcCovZ calcule ses zeros et leur matrice de covariance dans Z et CovZ
//
//	[Z,CovZ]=ClcCovZ(pol,CovCoeffs);
//
//	- Pol est le polyneme ( format matlab )
//	- CovCoeffs est la matrice de covariance de ses coefficients
//         Si CovCoeffs est de dimension stsct. inferieure  au nombre de coefficients du polyneme,
//         alors le coeff de plus haut degre de POL ( POL(1) ) est suppose constant et egal e 1
// 
//       - Dans le cas de zeros complexes conjugues, situes dans les ligne i et i+1 de Zeros
//         La ligne i   de CovZ concerne la partie reelle du zero
//         La ligne i+1 de CovZ concerne la partie imaginaire

lpol=length(pol);
for i=1:lpol
	polb(i)=pol(lpol-i+1);
end

// DimCov <- Dimension de la matrice de covariance des coeffs
// lp <- Degre du polyneme
[DimCov,dc]=size(CovCoeffs);
[lp,cp]=size(pol);
if lp>cp then pol=pol';polb=polb'; end

// r <- racines du polyneme
r=roots(poly(polb,'x','coeff'));
n=length(r);

// Phase 1
// Soit le polyneme
//                              n-1   n
//     C(x) = C0 +C1.x + +Cn-1.x   + x  
// correspondant au produit des racines du polyneme POL
//     C(x) =(x-z1).(x-z2). (x-zn)
//   
// On calcule les derivees des coefficients 0..n-1 de C(x) par rapport
// e ses racines zk , dans la matrice D

D=zeros(n,n);
k=1;
while k<n+1
	if imag(r(k))==0 then
        // cas d'une racine reelle zk
        // on a alors C(x) = (x-zk) . produit {( x- zj );(j different de k) }
        //                                   
        // et donc D(C(x)) / D(zk) = -produit{(x-zj);(j different de k)}
		D(k,:)=coeff(real(-poly(r([1:k-1,k+1:n]),'x','roots')));
		k=k+1;
	else
        // cas d'une racine complexe zk= rk + j. ik
        // on a alors C(x) = (x^2-2.rk.x + (rk^2+ik^2) . produit {( x- zj ); (j different de k)}
        //                                   
        // et donc D(C(x)) / D(rk) = -2.(x-rk).produit{(x-zj);(j different de k)}
        // que l'on range dans la ligne k de D	
		D(k,:)=coeff(real(-2*poly([r([1:k-1,k+2:n]);real(r(k))],'x','roots')));

        // de plus D(C(x)) / D(ik) = 2.ik.produit {( x- zj ); (j different de k)}
        // que l'on range dans la ligne k+1 de D
		D(k+1,:)=real([2*imag(r(k))*coeff(poly(r([1:k-1,k+2:n]),'x','roots')),0]);
		k=k+2;
	end
end

Db=zeros(n,n);
for i=1:n
	Db(:,i)=D(:,n-i+1);
end
D=Db;

// On inverse D, puis on la transpose
// => D contient e present les derivees des zeros z1..zk par rapport
// aux coefficients cn-1.. c0 du polyneme C

D=inv(D)';
CovZ=zeros(n,n);

if n~=DimCov then
// Si la dimension de la matrice de covariance est differente
// du nombre de zeros, alors le coeff en x^n de P {pol(1)} n'est pas normalise e 1
// P(x) s'ecrit : P(x) = P0 + P1.x + Pn.x^n { P0 = Pol(n) , Pn=Pol(1) }
// soit encore  : P(x) = C(x) . Pn = C(x).Pol(1) => C(x) = P(x) / Pn
// les coeffs Cj de C(x) s'ecrivent donc Cj = Pj / Pn
//
// Les derivees des zeros de P par rapport e ses coeffs pouvant s'ecrire
// D(zi) / D(Pk) = Somme{j=0..n-1 ; D(Zi) / D(Cj) . D(Cj) / D(Pk) }
//   On a donc D(zi) / D(Pk) = Somme { j= 0..n-1 ; D(Zi)/ D(Cj) ) / Pn } Si k <> n
     CovZ(:,2:lp)=D/pol(1);
     
//   Et D(zi) / D(Pn) = Somme{ j=0..n-1; ( D(Zi)/ D(Cj) ) . - Pj / Pn^2 }
     CovZ(:,1)=-D*pol(2:lp)'/(pol(1)*pol(1));

else
// Si on a le meme nombre de coefficients, c'est beaucoup plus simple,
// le coeff de plus haut degre de P est egal e 1, et donc P(x) = C(x)
     CovZ=D;
end

// Cf Cours, La matrice de covariance est egale e DZ.CovCoeff.DZ'
 CovZ=CovZ * CovCoeffs * CovZ';
 Z=r;

endfunction
function ecrit_lut(z,nom_fichier);
// creation d'un fichier de lut pour pcaxe, contenant la variable z
  mopen(nom_fichier,'wb');
  mput(z,'f');
  mclose();
endfunction
function [x]=ellips(x0,mx,alpha);   
//    x = ellips( x0 , mx ,alpha );
// ou     ellips( x0 , mx ,alpha );                            
// calcule ou trace l'ellipse associe e l'equation : ( x - x0 )' . Mx . ( x - x0 ) = alpha
// x0 est un vecteur de dimension 2
// Mx une matrice 2 X 2
[T,D]=spec(mx) ;
// mx n'est pas definie positive
if min(real(diag(D)))<= 0 then
 error('mx pas definie positive'); 
end
LengthTeta =40;
teta=0:(LengthTeta - 1 ); 
teta= 2 * %pi * teta / (LengthTeta-1) ;
y = sqrt(alpha)*[ cos(teta) / sqrt(D(1,1)) ; sin(teta) / sqrt(D(2,2)) ];
x1 =T*y  ; x1(1,:) = x1(1,:)+x0(1) ; x1(2,:) = x1(2,:)+x0(2) ;
x1=x1';
x=x1;
endfunction
function data=loaddat(nom_fichier);
//ouverture du fichier
  [fd,err]=mopen(nom_fichier,'rb');
  if err~=0 then
    error('impossible d ouvrir le fichier :'+nom_fichier);
  end
  nb_float=4000000;
// lecture du nombre de donnees differentes, et des donnees
  nb_col=round(mget(1,'f',fd));
  disp(nb_col);
  z=mget(nb_float,'f',fd);
  z=z.';
// fermeture fichier
  mclose(fd);
// verification du format
  nb_sample=round( length(z)/nb_col);
  disp(nb_sample);
  if (nb_sample * nb_col ) ~= length(z) then
    error('probleme de format du fichier');
  end
// mise en forme du data
  data=[];
  k=1:nb_col:(nb_sample*nb_col);
  for j=1:nb_col,
    data=[data,z(k)];
    k=k+1;
  end
endfunction
function [teta,cov,err,fivu]=mco(y,u,na,nb,nk);
imax=na+nb+1;
kmax=length(u);
	for k=1:kmax
		for i=1:(nb+1)
			nbb=i-1;
			if (k-nk-nbb)<1
				fi(k,i)=0;
			else
				fi(k,i)=[u(k-nk-nbb)];
			end
		end
		for i=0:(na-1)
			if (k-i-1)<1
				fi(k,nb+2+i)=0;
			else
				fi(k,nb+2+i)=-y(k-i-1);
			end
		end
	end
fivu=fi;
nbzero=max(na,nb+nk);
fi=fi(1+nbzero:kmax,:);
y=y(1+nbzero:kmax);
teta=pinv(fi'*fi)*fi'*y;
err=y-fi*teta;
cov=(1/kmax)*err'*err*pinv(fi'*fi);
endfunction
function [teta,covteta,err]=mc(Z,nn);
// function [teta,covteta,err]=mc(Z,nn);
// 
// Identification d'un modele Arx par la methode des moindres carres
//
// renvoie - le vecteur teta=[B0,..., Bnb, A1,...,Ana,]'
//         - une estimation de la matrice de covariance de teta
//         - le vecteur d'erreur err= Y - YEst
//
// en fonction des releves experimentaux
//   - Z = [Sortie Y(1..NbEch),entree U(1..NbEch) ]
// et de la structure de modele
//   - nn= [na,nb,nk]

  na=nn(1);
  nb=nn(2);
  nk=nn(3);
  ndeb=1+max(nb+nk,na);
  [nfin,ncol]=size(Z);
  if ncol>2 then error('dimension de Z incorrect'); end
  H=zeros(nfin-ndeb+1,na+nb+1);
// calcul de H
  for i=0:nb,
    H(:,i+1)=Z((ndeb-i-nk):(nfin-i-nk),2); 
  end
  for i=1:na,
    H(:,nb+i+1)=-Z((ndeb-i):(nfin-i),1); 
  end
//                    T  -1   T
// calcul de teta = (H H)  . H . Y
  Y=Z(ndeb:nfin,1);
  teta=pinv(H'*H)*H'*Y;
// calcul de l'erreur 
  err=Y-H*teta;
// estimation de la variance Lambda de l'erreur
  NbEch   = nfin - ndeb + 1 ;
  NbParam = na + nb + 1 ;
  Lambda=err'*err/(NbEch-NbParam);
// estimation de la Matrice de covariance cov 
  covteta= Lambda * pinv(H'*H);

endfunction
function [Ac,Bc,Cc,Dc]=myh2lqg(A,B1,B2,C1,C2,D11,D12,D21,D22);
  SIGNE_REG=-1;// Signe regulateur par defaut
// Definition fonction interne de partitionnement de matrices
// function [M1,M2]=partitio(Matr,n);
// Partition d'une matrice suivant les colonnes:
// Matr(nl,nc)=[ M1(nl,n) , M2(nl,nc-n)  ]
// Pour partitionner suivant les lignes, il suffit de partitionner
// la transposee de Matr, puis de transposer M1 et M2
  txt_partitio=[];
  txt_partitio=[txt_partitio;'if n<0 then'];
  txt_partitio=[txt_partitio;'  n=0 ;'];
  txt_partitio=[txt_partitio;'end'];
  txt_partitio=[txt_partitio;'[nl,nc] = size(Matr);'];
  txt_partitio=[txt_partitio;'if n<0 then'];
  txt_partitio=[txt_partitio;'   n=0 ;'];
  txt_partitio=[txt_partitio;'end'];
  txt_partitio=[txt_partitio;'if n> nc then'];
  txt_partitio=[txt_partitio;' n=nc;'];
  txt_partitio=[txt_partitio;'end'];
  txt_partitio=[txt_partitio;'if n > 0 then'];
  txt_partitio=[txt_partitio;'  M1= Matr(: , 1:n);'];
  txt_partitio=[txt_partitio;'else'];
  txt_partitio=[txt_partitio;'  M1 =[];'];
  txt_partitio=[txt_partitio;'end'];
  txt_partitio=[txt_partitio;'if n < nc then'];
  txt_partitio=[txt_partitio;'  M2 = Matr( : , (n+1) : nc);'];
  txt_partitio=[txt_partitio;'else'];
  txt_partitio=[txt_partitio;'  M2 =[];'];
  txt_partitio=[txt_partitio;'end'];
  deff('[M1,M2]=partitio(Matr,n)',txt_partitio);
//fonction addmat, par souci de compatibilite de code avec matlab
  deff('Matr=addmat( M1 , M2 )','Matr=M1+M2;');

//***********************************************************
// RESOLUTION DU PROBLEME DE RANG SUR MATRICE D11
//
// CALCUL DU GAIN INSTANTANE DK, ET DU NOUVEAU PROBLEME H2,
// CONNAISSANT DK
//
//
//***********************************************************

//*******************************************
// test de rang de D11
//*******************************************
  Rang_D11 = rank( D11 );
  if ( Rang_D11 > 0 ),
    disp('D11 = 0                   : FAIL!... ' );
    disp(' => Compensation gain instantane D11 ( transfert u1->y1 )' );
    disp('                      par        D12. Dc . D21           ' );
  else
    disp('D11 = 0                   : OK ' );
  end

  NbStates = size( A );
  Dk =-pinv( D12 ) * D11 * pinv( D21 );
// MLQG=inv( Id - D22.DK )
  MLQG = D22 * Dk ; MLQG = eye( MLQG ) - MLQG ; MLQG=pinv(MLQG);
  if ( NbStates > 0 ),
    a  = A    + B2  * Dk * C2  ;
    b1 = B1   + B2  * Dk * D21 ;
    b2 = B2   + B2  * Dk * D22 ;
    c1 = C1   + D12 * Dk * C2  ;
    c2 = C2                    ;
  end
  d11  = D11  + D12 * Dk * D21 ;
  S11  = svd( D11  ) ;
  Sp11 = svd( d11  ) ;
  if ( max( S11 ) > 100 * %eps * max( size(D11) ) ) & ( max( Sp11 ) > max( S11 ) * 1e-10 ),
    disp(' gain instantane D11 non compensable par D12.Dk.D21, probleme sans solution') ;
    return
  end
  d12   = D12                 ;
  d21   = D21                 ;
  d22   = D22                 ;
  if NbStates==0,
    Ac=[];
    Bc=[];
    Cc=[];
    Dc=Dk;
  //************************************************
  // PRISE EN COMPTE DE D22 <> 0 => Dc'= Dc
  //************************************************

  ID22D    = d22 * Dc + eye( d22 * Dc );
  InvID22D = pinv( ID22D ) ;

  //************************************
  //                 -1
  // D' =D .[I+D22.D]
  //************************************
    Dc =  Dc * InvID22D      ;

    disp('probleme non dynamique: solution = gainpur Dc');
    [n21,m21]=size(D21);
    if ( rank(D21) < n21 ),
      disp(' Remarque : Mesures y2 redondantes');
    end
    return
  end

//*******************************************************
// A CE STADE, D11 doit etre = 0, sinon pas de solution
//*******************************************************
//*******************************************
// test de rang sur D12
//*******************************************
  [n,m] = size( d12 );
  Rg = rank( d12 );
  if ( Rg ~= m ),
    disp('D12 de plein rang colonne : FAIL!... ' );
    for i=1:m,
      Rg = rank( d12(:,i) );
      if Rg == 0,
        disp(['  -> L''entree U2',string(i),' doit etre ponderee!... ']);
      end
    end
    error(' pas de solution realisable au probleme LQG pos?, il manque des ponderations sur les entrees u2');
  else
    disp('D12 de plein rang colonne : OK' );
  end

//*******************************************
// test de rang sur D21
//*******************************************
  [n,m] = size( d21 );
  Rg = rank( d21 );
  if ( Rg ~= n ),
    disp('D21 de plein rang ligne   : FAIL!... ' );
    for i=1:n,
      Rg = rank( d21(i,:) );
      if Rg == 0,
        disp(['  -> La mesure Y2',string(i),' n''est pas attaquee partiellement par du bruit blanc!... ']);
      end
    end
  else
    disp('D21 de plein rang ligne   : OK ' );
  end

//****************************************************************
// Filtrage opt dans le cas ou on a deja calcule Kc
//*******************************************************
// RESOLUTION PROBLEME DE RANG SUR MATRICE D21
// KALMAN BUCY FILTER mal pose -> LUENBERGER FILTER
//*******************************************************

  [U_D21,S_D21,V_D21]=svd(d21);
  [n_d21,m_d21]=size(d21);
//*****************************************************
// On pose Y'= U_D21'.Y2 =>                           *
//                        | S_D21.V_D21' |            *
//  Y'  = [U_D21'.C2].X + |              | . U1       *
//                        |     0        |            *
//                                                    *
// soit encore                                        *
//           Cp           Dp                          *
//  |Y'1|   |Cp1|       | D'11 |                      *
//  |   | = |   | . X + |      | . U1                 *
//  |Y'2|   |Cp2|       |   0  |                      *
//*****************************************************

  Cp   = U_D21' * c2     ;
  Dp   = S_D21  * V_D21' ;

//  Determination du Rang de Dp

  RangDp = min( find( diag( S_D21 ) == 0 )) ;
  if RangDp==[],
    RangDp = min( size(S_D21) );
  else
    RangDp = RangDp - 1 ;
  end

// Extraction de Cp1,Cp2,Dp11 ( et Dp21 qui normalement est egale ? 0 )

  [Cp1 ,Cp2 ] = partitio(Cp', RangDp ); Cp1=Cp1' ; Cp2=Cp2' ;
  [Dp11,Dp21] = partitio(Dp', RangDp ); Dp11=Dp11' ; Dp21=Dp21' ;

//************************************************************************
// On isole la partie de l'etat que l'on peut reconstruire sans erreur : *
// Celle qui se trouve dans l'orthogonal du noyau de C'2                 *
// Pour cela on considere la Svd De C'2
// 1- C'2 = U_Cp2 . [ S_C2 , 0 ] . V_Cp2'
//
// 2- On pose X' = V_Cp2' . X
// => l'equation d'etat se reecrit
//
//              | A'11 A'12 |   | X'1  |    | B'1 |                   *
//  d/dt(X')  = |           | . |      |  + |     | . U1              *
//              | A'21 A'22 |   | X'2  |    | B'2 |                   *
//                                                                    *                                                        *
//                                                                    *
//  |Y'1|   |C'11 C'12   |   | X'1 |    | D'11 |                      *
//  |   | = |            | . |     |  + |      | . U1                 *
//  |Y'2|   |C'21 0      |   | X'2 |    |   0  |                      *
//                                                                    *
//                                                                    *
// Avec                                                               *
//                                                                    *
//  | A'11 A'12 |                                                     *
//  |           |  = V_C2' . A . V_C2                                 *
//  | A'21 A'22 |                                                     *
//                                                                    *
//  | B'11 |                                                          *
//  |      |  = V_C2' . B1                                            *
//  | B'21 |                                                          *
//                                                                    *
//  | C'11 C'12 |                                                     *
//  |           |  = C . V_C2      => C'22 = 0                        *
//  | C'21 C'22 |                                                     *
//                                                                    *
//                                                                    *
//*********************************************************************



//*****************************
// Svd de C'2
//*****************************
  if min( size( Cp2 ) ) > 0, // Cp2 est non vide
    [U_Cp2,S_Cp2,V_Cp2]=svd(Cp2);

    //  Determination du Rang de Cp2

    RangCp2 = min( find( diag( S_Cp2 ) == 0 )) ;
    if RangCp2==[],
      RangCp2 = min( size(S_Cp2) );
    else
      RangCp2 = RangCp2 - 1 ;
    end
  else // Cp2 est vide , on ne fait rien
    V_Cp2=eye( a );
    RangCp2 = 0 ;
  end
//*******************************************************************
// Chgt de base : X'=V_Cp2' * X
//****************************************************************
  a  = V_Cp2' * a * V_Cp2 ;
  b1 = V_Cp2' * b1        ;
  b2 = V_Cp2' * b2       ; ;
  c1 = c1     * V_Cp2 ;
  c2 = c2     * V_Cp2 ;
//**************************************************
//                                         T
// application du chgt de base ? C' = U_D21 . C2
//**************************************************
  Cp   = Cp  * V_Cp2  ;
  Cp1  = Cp1 * V_Cp2 ;
  Cp2  = Cp2 * V_Cp2 ; // Attention ! : definition recursive de Cp1 et Cp2


//**************************************************************************************
// Calcul du regulateur optimal dans ma nouvelle base ( pas de regularisation sur D12 )
// ( pour le moment )
//**************************************************************************************
// Gestion des modes non commandables => dans le cas ou les modes non commandables
// ne sont pas instables au sens strict
//1- On commence par reduire y1 a sa partie observable,
//2- On exprime un critere LQR Reduit, portant uniquement sur la partie observable de y1
// une fois qu'on a le gain kkx optimal, on revient dans la base de depart,
// et normalement, le tour est joue
//*************************************************************************************
  SYS_LQR=syslin('c',a,b2,c1,d12);
  [kkx,tmp_X]=lqr(SYS_LQR);
  switch_lqr_1=0;
  if switch_lqr_1==1 then
    obsM=c2;
    for i=1:max(size(a)),
      obsM=[c2;obsM*a];
    end
    [Uo,So,Vo]=svd(obsM);
  // changement de base :
  //  |x_obs    |
  //  |         |=V_obs.x
  //  |x_non_obs|
    a_o=Vo'*a*Vo;b2_o=Vo'*b2;c1_o=c1*Vo;d12_o=d12;
    i_non_obs=find(diag(So)<=1e-6*So(1,1));
    i_obs=find(diag(So)>1e-6*So(1,1));
    a_o=a_o(i_obs,i_obs);
    b2_o=b2_o(i_obs,:);
    c1_o=c1_o(:,i_obs);
    SYS_LQR=syslin('c',a_o,b2_o,c1_o,d12_o);
    [kkx,tmp_X]=lqr(SYS_LQR);
  //**************************************************************
  // retour a la base de depart pour gain complet
  // on a : u2= kkx .x_obs
  // =>     u2= [kkx,0].|x_obs     =[kkx,0].V_obs.x
  //                    |x_non_obs
  //**************************************************************
    kkx=[kkx,zeros(i_non_obs)]*Vo;
  end
// version MATLAB
//  ax = a;
//  bx = b2;
//  Mc =[c1,d12];
//  qrnx = Mc' * Mc;
//  [kkx,x2,xerr] = lqrc(ax,bx,qrnx,aretype);
  KC = SIGNE_REG*kkx ; // a verifier, je ne suis pas tres sur

// Extraction de Cp11,Cp12,Cp21, ( et Cp22 qui normalement est egale ? 0 )

  Ap   = a ;
  Bp   = b1        ;
  [ SizeYp1 , n ] = size( Cp1 );
  [ SizeYp2 , n ] = size( Cp2 );

//****************************************************************************
// ATTENTION : Ce changement de base modifie les ?quations du regulateur !.. *
//****************************************************************************

  [Cp11,Cp12] = partitio( Cp1 , RangCp2 );
  [Cp21,Cp22] = partitio( Cp2 , RangCp2 );


  [Ap1,Ap2]=partitio(Ap',RangCp2); Ap1=Ap1' ; Ap2 = Ap2' ;
  [Ap11,Ap12] = partitio( Ap1 , RangCp2 );
  [Ap21,Ap22] = partitio( Ap2 , RangCp2 );

//*********************************************************************
// Calcul du DeltaA' du au terme de retour d'etat -KC.X <=>
//                T
// DeltaA' =-VC'2 . B2 . KC . VC'2
//***********************************
  DeltaAp=-b2 * KC ;
  [DeltaAp1,DeltaAp2]=partitio(DeltaAp',RangCp2);
  DeltaAp1=DeltaAp1' ; DeltaAp2 = DeltaAp2' ;
  [DeltaAp11,DeltaAp12] = partitio( DeltaAp1 , RangCp2 );
  [DeltaAp21,DeltaAp22] = partitio( DeltaAp2 , RangCp2 );

  [Bp1,Bp2]=partitio(Bp',RangCp2); Bp1=Bp1' ; Bp2 = Bp2' ;


//**********************************************************************************
// On isole la partie de l'etat que l'on peut reconstruire sans erreur :
// Celle qui se trouve dans l'orthogonal du noyau de C'2                           *
// Pour cela on considere la Svd De C'2
// 1- C'2 = U_C2 . [ S_C2 , 0 ] . V_C2'
//
// 2- On pose X' = V_C2' . X
// => l'equation d'etat se reecrit
//
//              | A'11 A'12 |   | X'1  |    | B'1 |                   *
//  d/dt(X')  = |           | . |      |  + |     | . U1              *
//              | A'21 A'22 |   | X'2  |    | B'2 |                   *
//                                                                    *                                                        *
//                                                                    *
//  |Y'1|   |C'11 C'12   |   | X'1 |    | D'11 |                      *
//  |   | = |            | . |     |  + |      | . U1                 *
//  |Y'2|   |C'21 0      |   | X'2 |    |   0  |                      *
//                                                                    *
//                                                                    *
// Avec                                                               *
//                                                                    *
//  | A'11 A'12 |                                                     *
//  |           |  = V_C2' . A . V_C2                                 *
//  | A'21 A'22 |                                                     *
//                                                                    *
//  | B'11 |                                                          *
//  |      |  = V_C2' . B1                                            *
//  | B'21 |                                                          *
//                                                                    *
//  | C'11 C'12 |                                                     *
//  |           |  = C . V_C2      => C'22 = 0                        *
//  | C'21 C'22 |                                                     *
//                                                                    *
//                                                                    *
//*********************************************************************
//**********************************************************************************
// Dans le cas ou le rang de C'2 est > 0 , on peut observer une partie de
// l'etat ( X'1) en utilisant la pseudo-inverse de C'21
//
// Seule la partie de l'etat non directement observee ( X'2 )
// devra etre reconstruite dynamiquement
// Dans cette partie, on precise les donnees pour l'observateur d'ORDRE REDUIT                          *
// **********************************************************************************
// 1- La premiere remarque est que toutes les observations dans Y'2
//    ne sont pas forcement utiles pour reconstruire X'1
//    Il se peut que le rang Nc2 de C'21 soit < a la dimension de Y'2
//    Dans ce cas on peut ne garder que les Nc2 premieres composantes
//    de Y'2 pour reconstruire X'1 ( C'21 est reduite ? ses Nc2 premieres lignes ).
// 2- Ensuite, ayant Pos? : X'1 = Inv(C'21) . Y'2, on peut reecrire les equations
//    sous la forme
//
//  Observation relative a X'2 :
//                   .
//                 | X'1 - A'11.X'1     | A'12 |        | B'1 |
//    Y''=(def)    |                  = |      |. X'2 + |     | . U1
//                 | Y'1 - C'11 . X'1   | C'12 |        | D'11|
//
//  Evolution de X'2 :
//    d/dt(X'2)=A'22.X'2 + [ A'21 . X'1 ] + B'2 . U1
//                         -> mesure n'intervenant pas dans
//                            l'eq de Riccati
// => On est ramene a un probleme classique de Filtrage de Kalman
//
// d/dt(X) = Af.X + Bf. ex                             Af= A'22 , Cf = C'12
//     Y   = Cf.X + Df. ey                             Bf= B'2  , Df = [B'1;D'11]
//                               T          T
//                       |Bf . Bf  , Bf . Df   |
//    Cov([Bf.ex,Df.ey])=|        T          T | .Delta(Tau)
//                       |Df . Bf  , Df . Df   |
//*********************************************************************

// Calcul des matrices de ponderation
  [n , SizeXp1  ] = size( Ap11  );
  [n , SizeXp2  ] = size( Ap22 );
  if  SizeXp1 > 0 ,
    disp ( '=> Resolution Pb de rang sur D21 , Calcul LUENBERGER optimal ' );
    Af = Ap22            ;
    Bf = Bp2             ;
    Cf = [ Ap12 ; Cp12 ] ;
    Df = [ Bp1  ; Dp11 ] ;
  //************************************
  // test de rang sur la matrice C'21
  //************************************
    [U,S,V]= svd( Cp21 ) ;
    RangCp21 = min( find( diag( S ) == 0 )) ;
    if RangCp21==[],
      RangCp21 = min( size(S) );
    else
      RangCp21 = RangCp21 - 1 ;
    end
    [n,m]=size(Cp21) ;
    if RangCp21 < n ,
      disp(' Remarque :Sorties mesurees redondantes, vous pourriez-supprimer des capteurs ...');
    end
    InvCp21 = pinv( Cp21 );
  //****************************************************
  // test de rang sur la matrice Df =[ B'1 ; D'11 ]    *
  //****************************************************
    [U,S,V]= svd( Df ) ;
    RangDf = min( find( diag( S ) == 0 )) ;
    if RangDf==[],
      RangDf = min( size(S) );
    else
      RangDf = RangDf - 1 ;
    end
    [n,m]=size(Df) ;
    if RangDf < n ,
      disp(' le filtre optimal est impropre , impossible a decrire sous forme rep d''etat');
      disp(' les ponderations sur les sorties mesurees ( y2 )  ' );
      disp(' ont un degre relatif insuffisant ' );
      error(' abandon du calcul ' );
    end
  else // Size( X'1 ) = 0
  //*****************************************************************
  // Cas ou D'21 est de plein rang ligne => Kalman standard
  //*****************************************************************
    InvCp21=[];
    Af = Ap22 ;
    Bf = Bp2  ;
    Cf = Cp12 ;
    Df = Dp11 ;
  end


//**************************************************************
// Calcul de la partie : Filtre de KALMAN bien pose
// ---- KF Riccati:
//
//************************************************************
  switch_kbf_1=0;
  if switch_kbf_1==1 then
    obsM=Bf';
    for i=1:max(size(a)),
      obsM=[Bf';obsM*Af'];
    end
    [Uo,So,Vo]=svd(obsM);
  // changement de base :
  //  |x_obs    |
  //  |         |=V_obs.x
  //  |x_non_obs|
    a_o=Vo'*Af'*Vo;b2_o=Vo'*Cf';c1_o=Bf'*Vo;d12_o=Df';
    i_non_obs=find(diag(So)<=1e-6*So(1,1));
    i_obs=find(diag(So)>1e-6*So(1,1));
    a_o=a_o(i_obs,i_obs);
    b2_o=b2_o(i_obs,:);
    c1_o=c1_o(:,i_obs);
    SYS_KBF=syslin('c',a_o,b2_o,c1_o,d12_o);
    [kky,tmp_Y]=lqr(SYS_KBF);
  //**************************************************************
  // retour a la base de depart pour gain complet
  // on a : u2= kkx .x_obs
  // =>     u2= [kkx,0].|x_obs     =[kkx,0].V_obs.x
  //                    |x_non_obs
  //**************************************************************
    kky=[kky,zeros(i_non_obs)]*Vo;
  else
    SYS_KBF=syslin('c',Af',Cf',Bf',Df'); // l'inversion C,D n'est pas une faute de frappe !...
    [kky,tmp_Y]=lqr(SYS_KBF);
  end
// VERSION MATLAB
//  ay = Af'        ;
//  by = Cf'        ;
//  Mf=[Bf;Df ]     ;
//  qrny =Mf*Mf'    ;
//  [kky,y2,yerr] = lqrc(ay,by,qrny,aretype);

  KF=SIGNE_REG*kky' ;

//********************************************************
// TOUS LES PARAMETRES SONT DETERMINES,                  *
// ON N'A PLUS QU'A CALCULER LE REGULATEUR GLOBAL        *
// = Connection du gain KC sur l'estimateur d'etat       *
// en parallele avec le gain instantane DK               *
//********************************************************

//*********************************************************
// Representation d'etat observateur optimal ,
// entree = y'2 = C'2.x(t)
//           '       '
// sortie [ x1est ; x2est ]
//*********************************************************

  [KF1,KF2]= partitio(KF,SizeXp1);
// 1 - Observateur , entree y2, sortie x_est
  App22 = addmat(Ap22 + DeltaAp22 , -KF1 * ( Ap12 + DeltaAp12 ) ) ;
  App22 = addmat( App22 , -KF2 * Cp12 ) ;

//*******************************************************
// App21 = App22 * KF1 + [ Ap21 - KF1 Ap11 - Kf2 Cp11 ]
//*******************************************************
  App21 = addmat( App22 * KF1 , Ap21 + DeltaAp21 ) ;
  App21 = addmat( App21       , - KF1 * ( Ap11 + DeltaAp11) ) ;
  App21 = addmat( App21       , - KF2 * Cp11 ) ;

//**********************************************************
// Correcteur entree Y2, sortie u2
//
//**********************************************************

//*************************************************************************
// On partitionne KC  entre KC1, relatif ? x'1
//                          KC2, relatif ? X'2 ( de meme taille que X2 )
//*************************************************************************


 [ KC1 , KC2 ] = partitio( KC , SizeXp1 );


  Ac = App22 ;

//****************************************
// Bc = [ KF2 , App21 *InvCp21 ]  U_D21' *
//****************************************
  [ UT_D21_Yp1 , UT_D21_Yp2 ] = partitio( U_D21 , SizeYp1 ) ;
    UT_D21_Yp1 = UT_D21_Yp1' ; UT_D21_Yp2 = UT_D21_Yp2' ;


  Bc = addmat( KF2 * UT_D21_Yp1 , App21 * InvCp21 * UT_D21_Yp2 );

//****************************************
// Cc = - KC * [ 0 ; Id( SizeX2 ) ]
//****************************************
  Cc = - KC2 ;

//***********************************************
//                                            T
// Dc = Dk - KC * InvCp21 * [ 0 ; I ] * U_D21
//***********************************************

  Dc = - KC * [ eye(SizeXp1,SizeYp2) ; KF1  ] * InvCp21 * UT_D21_Yp2 ;
  Dc =   Dc * UT_D21_Yp2 ;
  Dc = addmat( Dc , Dk );

//************************************************
// PRISE EN COMPTE DE D22 <> 0 => C'=f(C)
//************************************************

  ID22D    = d22 * Dc + eye( d22 * Dc );
  InvID22D = pinv( ID22D ) ;

//************************************
//                 -1
// D' =D .[I+D22.D]
//************************************
  Dc =  Dc * InvID22D      ;
//************************************
//                  -1
// B' =B . [I+D22.D]
//************************************
  Bc = Bc * InvID22D      ;
//************************************
//
// A' = A - B' . D22 . C
//************************************
  Ac = Ac - Bc * d22 * Cc ;
//************************************
//
// C' = [I - D' . D22] . C
//************************************
  Cc = ( eye( Dc * d22 ) - Dc * d22 ) * Cc ;
endfunction
function [DSP11,DSP12,DSP21,DSP22,frq]=my_inter_psd(wind,nfft,Fe,x1,x2);

FECH=Fe;


// Estimation de l'inter densite spectrale de deux
// signaux Sig1 et Sig2 , par moyennage
// Phi_12=E{conj(FFT(Sig1.Fenetre)).FFT(Sig2.Fenetre)}
// Exemple
// Fenetre=window(256,'Hamming');

  tx1=size(x1);
  if tx1(1)==1 then x1=x1.'; end
  tx2=size(x2);
  if tx2(1)==1 then x2=x2.'; end
 
  Sig1=x1;
  Sig2=x2;
  N_FFT=nfft;
  TYPE_FENETRE=wind;
  NB_FEN=100000;
// Frequences pour tracer
  Freqs=0:(N_FFT-1);Freqs=Freqs.';
  Freqs=Freqs*FECH/N_FFT;
//1- Calcul Fenetre
   Fenetre=window(TYPE_FENETRE,N_FFT);
   Fenetre=Fenetre.';
// Energie de la fenetre normalisee e 1
  Fenetre=Fenetre/sqrt(Fenetre'*Fenetre);
  
  N_FFT=length(Fenetre);
  NB_ECH=max([length(Sig1),length(Sig2)]);
  NB_FEN_MAX=floor(NB_ECH/N_FFT);
  if (NB_FEN> NB_FEN_MAX) then
	NB_FEN=NB_FEN_MAX; 
  end
//2- Centrage Signal
  Sig1=Sig1-mean(Sig1);
  Sig2=Sig2-mean(Sig2);
 
//*****************************************
// ESTIMATION INTER-DENSITE SPECTRALE 
//*****************************************
// DSP Estimee = Moyenne des conj(FFT(Sig1.Fen)).FFT(Sig2.Fen))
  i=1:N_FFT;
  DSP_11=zeros(N_FFT,1);
  DSP_12=DSP_11;
  DSP_22=DSP_11;

  for i_fen=1:NB_FEN,
    Sig1_i=Sig1(i);
    FFT1_i=fft(Sig1_i.*Fenetre,-1);
    Sig2_i=Sig2(i);
    FFT2_i=fft(Sig2_i.*Fenetre,-1);
    DSP11_i=FFT1_i.*conj(FFT1_i);
    DSP12_i=FFT1_i.*conj(FFT2_i);
    DSP22_i=FFT2_i.*conj(FFT2_i);
    DSP_11=DSP_11+DSP11_i ;
    DSP_12=DSP_12+DSP12_i ;
    DSP_22=DSP_22+DSP22_i ;
    i=i+N_FFT;
  end
  DSP_11=DSP_11/NB_FEN;
  DSP_12=DSP_12/NB_FEN;
  DSP_21=conj(DSP_12);
  DSP_22=DSP_22/NB_FEN;
  t_dsp=length(Freqs);
  frq=Freqs(1:t_dsp/2);
  DSP11=DSP_11(1:t_dsp/2);
  DSP12=DSP_12(1:t_dsp/2);
  DSP21=DSP_21(1:t_dsp/2);
  DSP22=DSP_22(1:t_dsp/2);

endfunction
function [Pxx,frq]=my_psd(wind,nfft,Fe,x1,x2);

FECH=Fe;

if exists('x2')==0 then
  tx1=size(x1);
  if tx1(1)==1 then x1=x1'; end
   
// CHOIX DU SIGNAL A ANALYSER 
Sig=x1;
//***********************************************
// PARAMETRES POUR
// ESTIMATION DES DENSITES SPECTRALES
//***********************************************
  N_FFT=nfft;
  TYPE_FENETRE=wind;
  NB_ECH=length(Sig);
  NB_FEN=floor(NB_ECH/N_FFT);
// Frequences pour tracer
  Freqs=0:(N_FFT-1);Freqs=Freqs.';Freqs=Freqs*FECH/N_FFT;
// 1- Calcul Fenetre
  Fenetre=window(TYPE_FENETRE,N_FFT);
  Fenetre=Fenetre';
// Energie de la fenetre normalisee e 1
  Fenetre=Fenetre/sqrt(Fenetre'*Fenetre);
// 2- Centrage Signal
  Sig=Sig-mean(Sig);

//*****************************************
// ESTIMATION DENSITE SPECTRALE DU SIGNAL
//*****************************************
// DSP Estimee = Moyenne des FFT(Sig.Fen).FFT conj ((Sig.Fen)))
  i=1:N_FFT;
  k=find(Freqs <=FECH/2); k=k'; 
  DSP_EST=zeros(N_FFT,1);
  for i_fen=1:NB_FEN,
    Sig_i=Sig(i);
    FFT_i=fft(Sig_i.*Fenetre,-1);
    DSP_i=FFT_i.*conj(FFT_i);
    DSP_EST=DSP_EST+DSP_i;
    i=i+N_FFT;
  end;
  DSP_EST=DSP_EST/NB_FEN;
  //**************************
  // DSP_ESTIMEE
  //***************************
  t_dsp=length(Freqs);
  frq=Freqs(2:t_dsp/2);
  Pxx=DSP_EST(2:t_dsp/2);

  
end;

if exists('x2')==1 then

// Estimation de l'inter densite spectrale de deux
// signaux Sig1 et Sig2 , par moyennage
// Phi_12=E{conj(FFT(Sig1.Fenetre)).FFT(Sig2.Fenetre)}
// Exemple
// Fenetre=window(256,'Hamming');

  tx1=size(x1);
  if tx1(1)==1 then x1=x1'; end
  tx2=size(x2);
  if tx2(1)==1 then x2=x2'; end
 
  Sig1=x1;
  Sig2=x2;
  N_FFT=nfft;
  TYPE_FENETRE=wind;
  NB_FEN=100000;
// Frequences pour tracer
  Freqs=0:(N_FFT-1);Freqs=Freqs.';Freqs=Freqs*FECH/N_FFT;
//1- Calcul Fenetre
   Fenetre=window(TYPE_FENETRE,N_FFT);
   Fenetre=Fenetre';
// Energie de la fenetre normalisee e 1
  Fenetre=Fenetre/sqrt(Fenetre'*Fenetre);
  
  N_FFT=length(Fenetre);
  NB_ECH=max([length(Sig1),length(Sig2)]);
  NB_FEN_MAX=floor(NB_ECH/N_FFT);
  if (NB_FEN> NB_FEN_MAX) then
	NB_FEN=NB_FEN_MAX; 
  end
//2- Centrage Signal
  Sig1=Sig1-mean(Sig1);
  Sig2=Sig2-mean(Sig2);
 
//*****************************************
// ESTIMATION INTER-DENSITE SPECTRALE 
//*****************************************
// DSP Estimee = Moyenne des conj(FFT(Sig1.Fen)).FFT(Sig2.Fen))
  i=1:N_FFT;
  DSP_EST=zeros(N_FFT,1);
  for i_fen=1:NB_FEN,
    Sig1_i=Sig1(i);
    FFT1_i=fft(Sig1_i.*Fenetre,-1);
    Sig2_i=Sig2(i);
    FFT2_i=fft(Sig2_i.*Fenetre,-1);
    DSP_i=FFT1_i.*conj(FFT2_i);
    DSP_EST=DSP_EST+DSP_i ;
    i=i+N_FFT;
  end
 DSP_EST=DSP_EST/NB_FEN;
 t_dsp=length(Freqs);
 frq=Freqs(2:t_dsp/2);
 Pxx=DSP_EST(2:t_dsp/2);
 end;

endfunction
function [db,phi]=myrepf(sys,omega,max_pha,retard)
  [lhs,rhs]=argn(0);
// moins de deux arguments en entrees => aide
  if rhs<2 then
    disp('[rep]=myrepf(sys,omega);');
    disp('[db_,phi_]=myrepf(sys,omega);');
    disp('[db_,phi_]=myrepf(sys,omega,max_pha);');
    disp('[db_,phi_]=myrepf(sys,omega,max_pha,retard);');
    disp('-------EXPLICATION-------');
    disp('la fonction mybod calcule ');
    disp('le module en db_     ( vecteur colonne)');
    disp('largument en  degres( vecteur colonne)');
    disp('de la reponse frequentielle du systeme sys');

    disp('omega est le vecteur de pulsations  en radians/s');
    disp('max_pha en degres, fixe la determination de phase');
    disp('=>phase initiale dans l intervalle ]max_pha-360,max_pha]');
    disp('retard(optionnel) est le retard en secondes en serie avec le systeme');
    return;
  end

// omega => vecteur colonne
  [n,m]=size(omega);
  if n==1 then
    omega=omega.';
  end

// Phase max en degres
  if rhs<3 then
    max_pha=90;
  end
// Retard en secondes
  if rhs<4 then
    retard=0;
  end
// reponse frequentielle => vecteur colonne
  if typeof(sys)=='constant' then
    repf=sys*ones(omega);
  end
  if typeof(sys)=='state-space' then
    if sys.A==[] then
      repf=sys.D*ones(omega);
    else
      repf=repfreq(sys,omega/(2*%pi));
    end
  end
  if (typeof(sys)=="list") then
    repf=ones(omega);
    is=definedfields(sys);
    is=is(find(is>0));
    for i=is,
      sysi=sys(i);
      repfi=myrepf(sys(i),omega);
      repf=repf.*repfi;
    end
  end

  if (typeof(sys)=='polynomial')|(typeof(sys)=='rational') then
    if (sys.dt==[]) then
      name_var=varn(numer(sys));
      if (name_var=='s')|(name_var=='w')|(name_var=='p') then
        sys.dt='c';
      elseif name_var=='z' then
        sys.dt='d';
      elseif name_var=='z_1' then
        sys.dt='z_1';
      end
    end
    if (sys.dt=='c') then
      x=%i*omega;
    elseif (sys.dt=='d') then
      Te=1;
      x=exp(%i*omega*Te);
    elseif (sys.dt=='z_1') then
      Te=1;
      x=exp(-%i*omega*Te);
    else
    // sys.dt is Te, use name_var to determine if z or z_1
      Te=sys.dt;
      if (name_var=='z_1') then
        x=exp(-%i*omega*Te);
      else
        x=exp(%i*omega*Te);
      end    
    end
    repf=my_horner(sys,x);
  end //  if (typeof(sys)=='polynomial')|(typeof(sys)=='rational') then
  [n,m]=size(repf);
  if n==1 then
    repf=repf.';
  end
  if (lhs<2) then
  // only one ouput argument, return frequency response
    db=repf;
    return;
  end
  [db,phi]=get_module_arg(repf,max_pha);
endfunction
function [mod_db,arg_degres]=get_module_arg(repf,max_arg_degres,retard)
  [lhs,rhs]=argn(0);

  if rhs<3 then
   retard=0;
  end
  if rhs<2 then
   max_arg_degres=90;
  end
// Pour eviter les underflow sur module en db_
  max_repf=max(abs(repf));
  if max_repf==0 then 
    max_repf=1e-30;
  end
  i=find(abs(repf)<1e-20*max_repf);
  repf(i)=max_repf*ones(repf(i));
// calcul module et phase
//  [phi_,db_]=phasemag(repf,'c')
  [db_,phi_]=dbphi(repf);
// unwrap phase ( il semblerait que la fonction dbphi ne le fasse pas correctement )
  l=length(phi_);
  if l>1 then
    deltaphi=phi_(2:l)-phi_(1:(l-1));
    deltaphi=round(deltaphi/360);
    i=find(abs(deltaphi)~=0);
    if length(i)>0 then
      M=zeros(phi_);
      M(i+1) =-360* deltaphi(i);
    // integration des pulses de phase
      sys_integ=syslin('d',%z/(%z-1));sys_integ=tf2ss(sys_integ);sys_integ.X0=0;
      M=dsimul(sys_integ,M.').';   
      phi_=phi_+M;
    end
  end


// db_ et phi_ en colonnes
  [n,m]=size(db_);
  if n==1 then
    db_=db_.';
    phi_=phi_.';
  end
// prise en compte du retard
  if retard ~=0 then
    phi_=phi_-( (retard*180/%pi) * omega );
  end

// determination de phase dans l'intervalle ]pha_max-360,pha_max]
  while phi_(1)>max_arg_degres,
    phi_=phi_-360;
  end
  while phi_(1)<=max_arg_degres-360,
    phi_=phi_+360;
  end
  mod_db=db_;
  if (lhs>1) then
    arg_degres=phi_;
  end

endfunction
function tf=myss2tf(sys)
  if typeof(sys)=='state-space' then
    tf=ss2tf(sys,norm(sys.A,1));
  end
  if typeof(tf)=='constant' then
    sys=tf;
    [ny,nu]=size(sys);
    tf=syslin('c',sys/%s);
    for iy=1:ny,
      for iu=1:nu,
        tf.num(iy,iu)=sys(iy,iu);
        tf.den(iy,iu)=1;
      end
    end
  end

endfunction
function sysGz=my_sysd(numG,denG,Te);

nnumG=length(numG);ndenG=length(denG);
numGb=zeros(nnumG,1);denGb=zeros(ndenG,1);

for i=1:nnumG 
 numGb(i)=numG(nnumG-i+1); 
end
for i=1:ndenG 
 denGb(i)=denG(ndenG-i+1); 
end	

nG=poly(numGb,'z','coeffs');
dG=poly(denGb,'z','coeffs');
sysGz=syslin('d',nG/dG);
sysGz(4)=Te;

endfunction
function ret=my_zpplot(teta,covteta,nn,ifig);

 
alpha1=0.45;
alpha2=1.39;
alpha=1;

[n,c]=size(teta);
if c>n then
 teta=teta'; 
end

na=nn(1);
nb=nn(2);

// On traite les zeros
nnum=1:(nb+1);
[z,covz]=clccovz(teta(nnum),covteta(nnum,nnum));
invc=pinv(covz);
k=1;k1=k ; l=length(z);
xset('window',ifig);clf(ifig,"reset");
while k<=l,  
  if imag(z(k))== 0 then
  // zero reel
    deltax=sqrt(alpha1/invc(k,k));
    x=linspace(real(z(k))-deltax,real(z(k))+deltax);x=x';
    [nl,nc]=size(x);
    plot2d(x,zeros(nl,nc),5);
    plot2d(real(z(k)),imag(z(k)),-1);
    k=k+1;
  else 
  // zero complexe
    m=invc(k:(k+1),k:(k+1));
    x1=ellips([real(z(k));imag(z(k))],m,alpha2); 
    plot2d(x1(:,1),x1(:,2),3)
    plot2d(real(z(k)),imag(z(k)),-1);
    k=k+2;
  end,
end

// Maitenant les peles
nden=(nb+2):(nb+2+na-1);
pden=[1;teta(nden)];
[z,covz]=clccovz(pden,covteta(nden,nden));
invc=pinv(covz);
k=1;k1=k ; l=length(z) ;
while k<=l,  
  if imag(z(k))==0 then
    deltax=sqrt(alpha1/invc(k,k));
    x=linspace(real(z(k))-deltax,real(z(k))+deltax);x=x';
    [nl,nc]=size(x);
    plot2d(x,zeros(nl,nc),5);
    plot2d(real(z(k)),imag(z(k)),-5);
    k=k+1;
  else 
    m=invc(k:(k+1),k:(k+1));
    x1=ellips([real(z(k));imag(z(k))],m,alpha2); 
    plot2d(x1(:,1),x1(:,2),3)
    plot2d(real(z(k)),imag(z(k)),-5);
    k=k+2;
  end,
  k1=k1+1;
end

xset('line style',4)
xgrid(2)
xset('line style',1)
xtitle('Vert: complexe conjugue / Rouge: reel - o: poles / +: zeros');
ret=[alpha1,alpha2];
endfunction
function [NumC,DenC]= plcpol(DG , NG , DBF, NCforce , DCforce ) ;
//function [NumC,DenC]= plcpol(DG , NG , DBF, NCforce , DCforce ) ;
// Appel Typique    :
//        [NC,DC]=plcpol(DG,NG,DBF,1,[1,0]); on veut une integration
// Remarque DBF Doit etre de degre superieur ou egal a 2.eDG + eNCforce + eDCforce
  DG=coeff(DG);DG=DG(length(DG):-1:1);
  NG=coeff(NG);NG=NG(length(NG):-1:1);
  DBF=coeff(DBF);DBF=DBF(length(DBF):-1:1);
  NCforce=coeff(NCforce);NCforce=NCforce(length(NCforce):-1:1);
  DCforce=coeff(DCforce);DCforce=DCforce(length(DCforce):-1:1);
 
//  if (nargin == 3 ),
//    NCforce =[1] ; DCforce =[1] ;
//  end
//  if (nargin == 4 ),
//    DCforce =[1] ;
//  end
  NA =max(size(DG ))-1;NB =max(size(NG )) - 1;
  NRf=max(size(NCforce))-1;NSf=max(size(DCforce)) - 1;
  NP =max(size(DBF ))-1;
  if ( NP < ( 2 * NA + NRf + NSf ) ) | ( NP == 0 ),
    error([' DBF doit etre d''ordre >= a ',num2str(2 * NA + NRf + NSf) ] ) ;
  end
// * Normalisation : DCforce(NSf) = 1 , DG(Na) = 1 , DBF(Np) = 1 ***}
  DCforce =DCforce / DCforce(1) ;
  NCforce =NCforce / NCforce(1 );
  NG = NG  / DG(1)  ;
  DG = DG  / DG(1)  ;
  DBF = DBF  / DBF(1)  ;
// ** Determination des ordres ***}
  NR    = NA + NSf - 1 ;
  NS    = NP - NSf - NA;
//  NSMin = NA + NRf
  DenC=zeros(1,NS+1) ; DenC(1) = 1 ;
// * Determination de Af = DG * DCforce , Bf = NG * NCforce ***}
  Af = convol( DG , DCforce ) ;
  Bf = convol( NG , NCforce ) ;
  NAf=max(size(Af))-1;NBf=max(size(Bf)) - 1;
// * formation de la matrice M du placement de poles **}
  M = zeros( NP,NP ) ;
  V = zeros( NP, 1 ) ; 
  for i = 0:NP-1,  //  i : coeff de DBF(i) <=> Lignes de M **}
  // * Vecteur V(i) de l'equation M . X = V = coeff DBF(i) **}
    V( i + 1 ) = DBF(NP+1-i) ;
  // * on s'occuppe des coeffs de Af . DenC **}
    for j = 0:NS,  //  j est le coeff de DenC(j)  *}
      k = i - j ;                 //  k est le coeff de Af(k) *}
      if ( k >= 0 ) & ( k <= NAf ),
        Trv = Af( NAf+1-k );
      else                  
        Trv = 0 ;
      end
      if ( j < NS ),
         M( i + 1 , j + 1 ) = Trv ;
      else 
        V( i + 1 ) = V( i + 1 ) - Trv ;
      end
    end
  // * on s'occuppe des coeffs de Bf . NumC **}
    for j = 0:NR,  //  j est le coeff de NumC(j)  *}
      k = i - j ;  //  k est le coeff de Bf(k) *}
      if ( k >= 0 ) & ( k <= NBf ) ,
        Trv = Bf( NBf + 1 - k );
      else                  
        Trv = 0;
      end
      M( i + 1 , j + NS + 1 ) = Trv ;
    end
  end
// * Solution = M-1. V [s0..sn-1],[r0,rnr] **}
  Sols = pinv(M) * V ;
//* Solution du probleme  | DenC[0..NS-1] |     -1        *
//*                         |            | = M   * V     *
//*                         | NumC[0..NR ]  |               *}
  DenC= [ 1;Sols(NS:-1:1) ];
  NumC= Sols(NS+NR+1:-1:NS+1);
  DenC =convol(DenC,DCforce); NumC = convol(NumC,NCforce);
  [n,m]=size(DenC);
  if n>1,
    DenC=DenC';
  end
  [n,m]=size(NumC);
  if n>1,
    NumC=NumC';
  end
  NumC=NumC(length(NumC):-1:1);
  DenC=DenC(length(DenC):-1:1);
  NumC=poly(NumC,'p','coeff');
  DenC=poly(DenC,'p','coeff');
  

endfunction
function H_simplif=simplif_transfert(H,wmin,wmax,wref);
num=numer(H);
den=denom(H);
wmin=0.01;
wmax=1000;
wref=1;
seuil=0.01;
rn=roots(num);wn=abs(rn);
rd=roots(den);wd=abs(rd);

deg_num=length(rn);
deg_den=length(rd);

// saturation pulsation de coupures entre wmin et wmax
i=find(wn<wmin);rn(i)=-wmin*ones(rn(i));
i=find(wn>wmax);rn(i)=-wmax*ones(rn(i));
i=find(wd<wmin);rd(i)=-wmin*ones(rd(i));
i=find(wd>wmax);rd(i)=-wmax*ones(rd(i));

for i=1:(deg_den-deg_num),
  rn=[rn;-wmax];
end
list_simplif=list();
p_rn=1;
for i=1:deg_den,
  [min_rel,i_min]=min(abs(rn(i)-rd) / abs(rn(i)) );
  if min_rel<seuil then
  // ce terme sera degage, mais ne sera plus simplifie!...
    rd(i_min)=-2*wmax;
  else
    if ( abs(rn(i)) < wmax ) then
      p_rn=p_rn*(%s-rn(i));
    end
  end
end

p_rd=1;
for i=1:deg_den
  if abs(rd(i))<=1.5*wmax then
    p_rd=p_rd*(%s-rd(i));
  end
end

p_rn=real(p_rn);
p_rd=real(p_rd);
// calcul du gain
h0=my_horner(num/den,sqrt(-1)*wref);
h1=my_horner(p_rn/p_rd,sqrt(-1)*wref);
gain=real(h0/h1);
p_rn=p_rn*gain;
H_simplif=p_rn/p_rd;
endfunction
function Sys_H=transfert(A,B,C,D,nu,ny);
  B=B(:,nu);
  C=C(ny,:);
  D=D(ny,nu);
  Sys_ABCD=syslin('c',A,B,C,D);
  Sys_H=myss2tf(Sys_ABCD);
endfunction
  function omega=my_compute_omega(F_w)
    W_MIN=1e-10;
    W_MAX=1e10;
    // au moins NB_POINTS_RES points entre freq res et freq propre
    NB_POINTS_RES=10;
    // au moins NB_POINTS_DEC points par decade
    NB_POINTS_DEC=20;
    if (typeof(F_w)~='list') then
       l=list();
       l(1)=F_w;
       F_w=l;
    end
    NB_F=length(F_w);
    omega=[];
    r=[];
    for i=1:NB_F,
      Fwi=F_w(i);
      ni=numer(Fwi);
      di=denom(Fwi);
      r=[r;roots(ni)];
      r=[r;roots(di)];
    end
    i=find(imag(r)>=0);
    r=r(i);
    wn=abs(r);
    i=find(wn>=W_MIN);
    r=r(i);
    wn=wn(i);
    z=abs(real(r)./wn);
    ir=find( z<0.6);
    wnr=wn(ir);
    zr=z(ir);
    kres=sqrt(1-2*zr.*zr);
    for i=1:length(zr),
      kresi=kres(i);
      w1=wnr(i);
      w0=kresi^2*w1;
      wi=logspace(log10(w0),log10(w1),2*NB_POINTS_RES+1).';
      omega=[omega;wi];
    end
    // au moins NB_POINTS_RES points par decade
    wmin=0.3*min(wn);wmax=3*max(wn);
    delta_decade=log10(wmax/wmin);
    NB_POINTS=ceil(NB_POINTS_DEC*delta_decade);
    wi=logspace(log10(wmin),log10(wmax),NB_POINTS).';
    omega=[omega;wi];
    omega=-gsort(-omega);
  endfunction
  function [K_inf,cels]=my__parfrac(F_de_x,switch_real)
    [lhs,rhs]=argn(0);
    if (rhs<2) then
      switch_real="real";
    end
    nx=[];
    // compute F_de_x= cels(1)+ cels(2)+ etc
    if (typeof(F_de_x)~='list') then
      l=list();l(1)=F_de_x;F_de_x=l;
    end
    poles=[];
    Nx=list();
    k=0;
    deg_N=0;
    deg_D=0;
    ni_inf=1;
    for i=definedfields(F_de_x),
      Fi=F_de_x(i);
      Fi=normalize(Fi,"hd");
      Ni=numer(Fi);
      Di=denom(Fi);
      deg_Di=my_degree(Di);
      deg_D=deg_D+deg_Di;
      deg_N=deg_N+my_degree(Ni);
      if (my_degree(Di)>0)&(nx==[]) then
        nx=varn(Di) 
      end
      k=k+1;
      Nx(k)=numer(Fi);
      rDi=roots(Di);
      if (switch_real=="real") then
        Di=real(Di);
        Ni=real(Ni);
        if (deg_Di<2) then
          rDi=real(rDi);
        elseif (deg_Di==2) then
          if (imag(rDi(1))~=0) then
            rDi(2)=conj(rDi(1));
          end
        else
          error("works only for 1st and 2nd order cels");
        end
      end
      ni_inf=ni_inf*coeff(Ni,my_degree(Ni));
      poles=[poles;rDi];
    end

    if (deg_N>deg_D) then
       error("my_degree num>my_degree den in my_parfrac");
    end
    nb_pi=max(size(poles));
    Dx=list();
    for i=1:nb_pi,
      Dx(i)=poly(poles(i),nx);
    end
    if (switch_real=="real") then
      i_poles=find(imag(poles)>=0);
    else
      i_poles=1:max(size(poles)); 
    end 
    x=poly(0,nx);
    cels=list();k=0;
    if (deg_N==deg_D) then
      K_inf=ni_inf;
    else
     K_inf=0;
    end
    for i=i_poles,
      pi=poles(i);
      Dxi=Dx;
      Dxi(i)=null(); // delete term (x-pi)
      num_Ai=get_as_product(hornerij(Nx,pi));
      den_Ai=get_as_product(hornerij(Dxi,pi));
      if (den_Ai==[]) then
        den_Ai=1;
      end
      Ai=num_Ai/den_Ai;
      if (switch_real=="real") then
        if (imag(pi)~=0) then
          n_ci=Ai * ( x-conj(pi) ) + conj(Ai) * ( x - pi );
          n_ci=real(n_ci);
          d_ci=( x-conj(pi) ) * ( x - pi );
          d_ci=real(d_ci);
          k=k+1;cels(k)=n_ci/d_ci;
        else
          k=k+1;cels(k)=real(Ai)/(x-pi);
        end
      else
        pause
        k=k+1;cels(k)=real(Ai)/(x-pi);
      end
    end
  endfunction

  function cels=my_parfrac(F_w,x,seuil_group)
    SEUIL_MAX=1e6;
    SEUIL_MOD_FW=0.1;
    [lhs,rhs]=argn(0);
    if (rhs<3) then
      SEUIL_GROUP=2*SEUIL_MAX;// desactive group
    else
      SEUIL_GROUP=seuil_group;
    end
    switch_compute_x=rhs<2;

    if (typeof(F_w)~='list') then
       l=list();
       l(1)=F_w;
       F_w=l;
    end
    if (switch_compute_x) then
      x=%i*my_compute_omega(F_w);
    end

    w=poly(0,'w');
    ZERO_W=(1-w);
    LOWEST_ORDER_POL=(1-w);
    x_orig=x;
    val_ZERO_W=horner(ZERO_W,x);
    if (typeof(LOWEST_ORDER_POL)~='polynomial') then
      val_LOWEST_ORDER_POL=ones(x)*LOWEST_ORDER_POL;
    else
      val_LOWEST_ORDER_POL=horner(LOWEST_ORDER_POL,x);
    end
    val_Fw=ones(x);
    NB_F=length(F_w);
    M=[val_Fw];
    root_cel=[];
    ind_cel=[];
    l_roots_f=list();
    for (i_f=1:NB_F),
      F_wi=F_w(i_f);
      val_Fwi=horner(F_wi,x);
      val_Fw=val_Fw.*val_Fwi;
      r_wi=roots(denom(F_w(i_f)));
      root_cel=[root_cel;r_wi];
      nb_r=max(size(r_wi));
      l_roots_f(i_f)=r_wi;
      if (nb_r==1) then
        ind_cel=[ind_cel;i_f];
        pi1=LOWEST_ORDER_POL/(w-r_wi(1,1));
        pi2=[];
      elseif (nb_r==2) then
        ind_cel=[ind_cel;i_f;i_f];
        pi1=LOWEST_ORDER_POL/((w-r_wi(1,1))*(w-r_wi(2,1)));
        pi2=ZERO_W*pi1;
      end
      if (pi1~=[]) then
        val_pi1=horner(pi1,x);
        M=[M,val_pi1];
      end
      if (pi2~=[]) then
        val_pi2=horner(pi2,x);
        M=[M,val_pi2];
      end
    end
    abs_Fw=abs(val_Fw);
    abs_Fw_orig=abs_Fw;
    val_Fw_orig=val_Fw;
    max_Fw=max(abs_Fw);
    ix=find(abs_Fw>SEUIL_MOD_FW*max_Fw);
    coeffs=pinv(M)*val_Fw;
    re_coeffs=real(coeffs);
    err=M*re_coeffs-val_Fw;
    i=find(abs(err)>=0.1*abs(val_Fw));
  //------------------------------------
  // pass 1 : find multiple poles
  //------------------------------------
    if (i~=[]) then
      pause 
    // there are near multiple cells
      tol=1e-10;
      [n,m]=size(M);
      rank_M=rank(M);
      nb_r=max(size(root_cel));
      nb_multiple_cels=m-rank_M;
      sensivity=[];
      ind_i=[];
      ind_j=[];
      j=(1:nb_r).';
      err_i=ones(nb_r,1);
      for i_cel=1:nb_r,
        r_wi=root_cel(i_cel);
        j1=[(i_cel+1):nb_r];
        r_wj=root_cel(j1);
        err_i=%inf*ones(err_i);
        err_i(j1)=abs(r_wi-r_wj)./abs(r_wi);
        sensivity=[sensivity,err_i];
        ind_i=[ind_i,i_cel*ones(err_i)];
        ind_j=[ind_j,j];
      end
      [tmp,k]=gsort(-sensivity);
      i=ind_i(k);
      j=ind_j(k);
      i=i(1:nb_multiple_cels);
      j=j(1:nb_multiple_cels);
      r_multiple=root_cel(i);
      disp('there are '+string(  nb_multiple_cels)+' multiple cels');
      i=i(1:nb_multiple_cels);
      j=j(1:nb_multiple_cels);
      i_cel=ind_cel(i);j_cel=ind_cel(j);
      group_cel=list();
      for i=1:max(size(i_cel))
        ic=i_cel(i);
        jc=j_cel(i);
        i_f=-1;
        for k=1:length(group_cel),
          if (i_f==-1) then
            ck=group_cel(k);
            oki=find(ck==ic)~=[];
            okj=find(ck==jc)~=[];
            ok=oki|okj;
            if (ok) then
              i_f=k;
              if (oki==%f) then
                ck=[ck,ic];
              end
              if (okj==%f) then
                ck=[ck,jc];
              end
              group_cel(k)=ck;
            end
          end //if (i_f==-1) then
        end //for k=1:length(group_cel)
        if (i_f==-1) then
          ck=[ic,jc];
          l=length(group_cel)+1;
          group_cel(l)=ck;
        end
      end //  for i=1:max(size(i_cel))
      ck_glob=[];
      for k=1:length(group_cel),
        ck=group_cel(k);
        ck=-gsort(-ck);
        ck_glob=[ck_glob,ck];
        group_cel(k)=ck;
      end //for k=1:length(group_cel)
      for i_f=1:NB_F,
        ok=find(ck_glob==i_f)~=[];
        if (ok==%f) then
          l=length(group_cel)+1;
          group_cel(l)=i_f;
        end
      end
    else  //if (i~=[]) then
    // there are no multiple cells
      group_cel=list();
      for i_f=1:NB_F,
        group_cel(i_f)=i_f;
      end
    end
 //---------------------------------------------------------------
  // step 2
  // parfrac with multiple cels grouped
  // try to minimize the square sum of coeffs
  //---------------------------------------------------------------
    x=x(ix);
    val_ZERO_W=horner(ZERO_W,x);
    if (typeof(LOWEST_ORDER_POL)~='polynomial') then
      val_LOWEST_ORDER_POL=ones(x)*LOWEST_ORDER_POL;
    else
      val_LOWEST_ORDER_POL=horner(LOWEST_ORDER_POL,x);
    end
    NB_F=length(group_cel);
    val_Fw=ones(x);
    M=ones(x);
    ind_group_cel=[0];
    ind_f=[0];
    for (i_cel=1:NB_F),
      i_fi=group_cel(i_cel);
      val_Fwi=ones(x);
      val_Dwi=ones(x);
      d_wi=list();i_d=0;
      order_fi=0;
      for k_fi=1:length(i_fi),
        i_f=i_fi(k_fi);
        F_wi=F_w(i_f);
        i_d=i_d+1;d_wi(i_d)=denom(F_wi);
        order_fi=order_fi+my_degree(d_wi(i_d));
        for io=1:my_degree(d_wi(i_d)),
          ind_f=[ind_f;i_f];
        end
        val_Fwi=val_Fwi.*horner(F_wi,x);
        val_Dwi=val_Dwi.*horner(d_wi(i_d),x);
      end
      val_Fw=val_Fw.*val_Fwi;
      val_ni=val_LOWEST_ORDER_POL;
      for i=1:order_fi,
        M=[M,val_ni./val_Dwi];
        val_ni=val_ni.*val_ZERO_W;
        ind_group_cel=[ind_group_cel;i_cel];
      end
    end
    coeffs=pinv(M)*val_Fw;
    re_coeffs=real(coeffs);
    err=M*re_coeffs-val_Fw;
    //max(abs(err))
  //---------------------------------------------------------------
  // step 3
  // compute sensivity of frequency response to relative error on coeffs
  //---------------------------------------------------------------
    K=re_coeffs(1);
    abs_Fw=abs(val_Fw);
    [m,n]=size(M);
    sensivity=[];
    for i_n=1:n,
      coeff_i=re_coeffs(i_n);
      val_Fi=M(:,i_n)*coeff_i;
      abs_Fi=abs(val_Fi);
      i=find(abs_Fi< SEUIL_MAX *abs_Fw);
      if (i~=[]) then
        sensivity=[sensivity;max(abs_Fi(i)./abs_Fw(i))];
      else
        sensivity=[sensivity,SEUIL_MAX];
      end
    end
    sens1=sensivity
  //-------------------------------------------------------------------
  // step 4
  // find too near cells
  //-------------------------------------------------------------------
    i_group=find(sensivity>SEUIL_GROUP);
    ind_f2=ind_f(i_group);
    ind_g2=ind_group_cel(i_group);
    l_g2=length(ind_g2);
    group_too_near=list();
    for i=1:l_g2,
      i_fi=ind_f2(i);
      i_gi=ind_g2(i);
      gri=group_cel(i_gi);
      rfi=l_roots_f(i_fi);
      rfi=rfi(1);
      rf_glob=[];
      if_glob=[];
      ig_glob=[];
      tab_j=[1:(i-1),(i+1):l_g2];
      for j=tab_j,
        i_fj=ind_f2(j);
        i_gj=ind_g2(j);
        grj=group_cel(i_gj);
        rfj=l_roots_f(i_fj);
        if_glob=[if_glob;i_fj*ones(rfj)];
        ig_glob=[ig_glob;i_gj*ones(rfj)];
        rf_glob=[rf_glob;rfj];
      end
      delta_r=abs(rf_glob-rfi);
      [delta_r,iroot]=gsort(-delta_r);
      tmpg.grpi=i_gi;
      tmpg.flti=i_fi;
      tmpg.grpj=ig_glob(iroot(1));
      tmpg.fltj=if_glob(iroot(1));
      tmpg.deltar=delta_r(iroot(1));
      tmpg.ri=rfi;
      tmpg.rj=rf_glob(iroot(1));
      tmpg.is_treated=%f;
      group_too_near(i)=tmpg;
    end
  //----------------------------------------------------------
  // step 5 group too near cels
  //----------------------------------------------------------
    if (l_g2>0) then
      new_group=list();
      for ig=1:length(group_cel),
        new_group(ig)=[];
      end
      old_group_cel=group_cel;
      for i=1:l_g2,
        ti=group_too_near(i);
        gi=ti.grpi;
        gj=ti.grpj;
        if (gj~=gi) then
          g=min([gi,gj]);
          ci=old_group_cel(gi);
          cj=old_group_cel(gj);
          cn=new_group(g);
          new_group(g)=[cn,ci,cj];
          old_group_cel(gi)=[];
          old_group_cel(gj)=[];
        end
      end
      for ig=1:length(group_cel),
        if (new_group(ig)==[]) then
          new_group(ig)=old_group_cel(ig);
        end
      end
      old_group_cel=group_cel;
      group_cel=list();kg=0;
      for ig=1:length(new_group),
        if (new_group(ig)~=[]) then
          kg=kg+1;
          group_cel(kg)=new_group(ig);
        end
      end
    end //if (l_g2>0) then
  //-----------------------------------------------------------------
  // step 6 , compute once again coeffs
  //-----------------------------------------------------------------
    NB_F=length(group_cel);
    M=ones(x);
    ind_group_cel=[0];
    ind_f=[0];
    for (i_cel=1:NB_F),
      i_fi=group_cel(i_cel);
      val_Fwi=ones(x);
      val_Dwi=ones(x);
      d_wi=list();i_d=0;
      order_fi=0;
      for k_fi=1:length(i_fi),
        i_f=i_fi(k_fi);
        F_wi=F_w(i_f);
        i_d=i_d+1;d_wi(i_d)=denom(F_wi);
        order_fi=order_fi+my_degree(d_wi(i_d));
        for io=1:my_degree(d_wi(i_d)),
          ind_f=[ind_f;i_f];
        end
        val_Fwi=val_Fwi.*horner(F_wi,x);
        val_Dwi=val_Dwi.*horner(d_wi(i_d),x);
      end
      val_ni=val_LOWEST_ORDER_POL;
      for i=1:order_fi,
        M=[M,val_ni./val_Dwi];
        val_ni=val_ni.*val_ZERO_W;
        ind_group_cel=[ind_group_cel;i_cel];
      end
    end
    coeffs=pinv(M)*val_Fw;
    re_coeffs=real(coeffs);
    err=M*re_coeffs-val_Fw;
  //---------------------------------------------------------------
  // step 7
  // compute sensivity of frequency response to relative error on coeffs
  //---------------------------------------------------------------
    K=re_coeffs(1);
    [m,n]=size(M);
    sensivity=[];
    for i_n=1:n,
      coeff_i=re_coeffs(i_n);
      val_Fi=M(:,i_n)*coeff_i;
      abs_Fi=abs(val_Fi);
      i=find(abs_Fi< SEUIL_MAX *abs_Fw);
      if (i~=[]) then
        sensivity=[sensivity;max(abs_Fi(i)./abs_Fw(i))];
      else
        sensivity=[sensivity,SEUIL_MAX];
      end
    end
  //---------------------------------------------------------------
  // factorize internal cascade cels
  //---------------------------------------------------------------
    NB_F=length(group_cel);
    cels=list();
    clear tmpc
    tmpc.num_glob=re_coeffs(1);
    tmpc.den_glob=1;
    tmpc.dens=list();tmpc.dens(1)=1;
    tmpc.nums=list();tmpc.nums(1)=tmpc.num_glob;
    cels(1)=tmpc;
    i_coeff=1; // gain K first
    for (i_cel=1:NB_F),
      i_fi=group_cel(i_cel);
      val_Fwi=ones(x);
      val_Dwi=ones(x);
      d_wi=list();i_d=0;
      order_fi=0;
      di_glob=1;
      tmpc.dens=list();
      tmpc.nums=list();
      for k_fi=1:length(i_fi),
        i_f=i_fi(k_fi);
        F_wi=F_w(i_f);
        d_wi=denom(F_wi);
        tmpc.dens(k_fi)=d_wi;
        di_glob=di_glob*d_wi;
        order_fi=order_fi+my_degree(d_wi);
      end
      ni=LOWEST_ORDER_POL;
      ni_glob=0;
      for i=1:order_fi,
        i_coeff=i_coeff+1;
        coeff_i=re_coeffs(i_coeff);
        ni_glob=ni_glob+ni*coeff_i;
        ni=ni*ZERO_W;
      end
      tmpc.num_glob=ni_glob;
      tmpc.den_glob=di_glob;
      cels(i_cel+1)=tmpc;
    end
  //---------------------------------------------------------------
  // eliminate cels with zero gain
  //---------------------------------------------------------------
    tol_MAX=1e-10;
    tol_REL=1e-10;
    x=x_orig;
    val_Fw=val_Fw_orig;
    abs_Fw=abs_Fw_orig;
    i=find(abs_Fw>tol_MAX*max(abs_Fw));
    abs_Fw=abs_Fw(i);
    val_Fw=val_Fw(i);
    max_abs_Fw=max(abs_Fw);
    x=x(i);
    old_cels=cels;
    cels=list();k_cel=0;
    val_Fw_verif=zeros(val_Fw);
    for i_cel=1:length(old_cels),
      ci=old_cels(i_cel);
      ni=ci.num_glob;
      di=ci.den_glob;
      if (typeof(ni)=='polynomial') then
        val_ni=horner(ni,x);
      else
        val_ni=ni*ones(x);
      end
      if (typeof(di)=='polynomial') then
        val_di=horner(di,x);
      else
        val_di=di*ones(x);
      end
      val_Fi=val_ni./val_di;
      abs_Fi=abs(val_Fi);
      max_abs_Fi=max(abs_Fi);
      ci.max_abs_Fi=max_abs_Fi;
      max_gain_rel=max(abs_Fi./abs_Fw);
      ci.max_gain_rel=max_gain_rel;
      ci.is_good=(ci.max_gain_rel>tol_REL)&(ci.max_abs_Fi>tol_MAX*max_abs_Fw);
      old_cels(i_cel)=ci;
      if (ci.is_good) then
        k_cel=k_cel+1;cels(k_cel)=ci;
        val_Fw_verif=val_Fw_verif+val_Fi;
      end
    end
  //---------------------------------------------------------------
  // group nums-dens
  //---------------------------------------------------------------

    err_max=max(abs(val_Fw-val_Fw_verif));
    NB_F=length(cels);
    for i_cel=1:NB_F,
      ci=cels(i_cel);
      ok=length(ci.nums)==0;
      // nums are ever known
      if (ok) then
        dens=ci.dens;
        nb_dens=length(dens);
        nums=list();
        for i=1:nb_dens,
          nums(i)=1;
        end
      else
        nums=ci.nums;
      end
      // nums are constant
      if (ok) then
        ni=real(ci.num_glob);
        rn=roots(ni);
      // supp conjugate roots
        i=find(imag(rn)>=0);
        rn=rn(i);
        if (rn==[]) then
          nums(1)=ni;
          ok=%f;
        end
      end
     // only one denom
      if (ok) then
        ok= length(dens)>1;
        if (~ok) then
          nums(1)=ci.num_glob;
        end
      end  //  if (ok) then
     // compute denoms roots
      if (ok) then
        rd=[];i_den=[];
        for id=1:length(dens),
          rdi=roots(dens(id));
          rd=[rd;rdi];
          i_den=[i_den;id*ones(rdi)];
        end
      // suppress conjugate pairs
        i=find(imag(rd)>=0);
        rd=rd(i);
        i_den=i_den(i);
        abs_rd=abs(rd);
        abs_rn=abs(rn);
        nb_rn=ones(rn);
        i=find(imag(rn)~=0);
        nb_rn(i)=2*ones(nb_rn(i));
        nb_rd=ones(rd);
        i=find(imag(rd)~=0);
        nb_rd(i)=2*ones(nb_rd(i));
        delta_r=list();
        nb_r=max(size(rn));
        max_delta=[];
        for i=1:nb_r,
          abs_r=abs_rn(i);
          delta_r(i)=abs(abs_r-abs_rd);
          max_delta=max([max_delta;delta_r(i)]);
        end
        // groupe same order cels first
        max_delta=2*max_delta;
        err=[];i_rn=[];i_rd=[];
        j_rd=1:max(size(rd));
        j_rd=j_rd.';
        for i=1:nb_r,
          nb_ri=nb_rn(i);
          delta_order_i=abs(nb_ri-nb_rd)*max_delta;
          delta_r(i)=delta_r(i)+delta_order_i;
          err=[err;delta_r(i)];
          i_rn=[i_rn;i*ones(delta_r(i))];
          i_rd=[i_rd;j_rd];
        end
        ci.rd=rd;ci.i_rd=i_rd;
      //sort by increasing err
        [err,i]=gsort(-err);
        i_rn=i_rn(i);
        i_rd=i_rd(i);
      // group roots
        free_rn=nb_rn;
        free_rd=nb_rd;
        l_apparie=list();
        for i=1:length(dens),
          l_apparie(i)=[];
        end
        for i=1:length(err),
          i_rni=i_rn(i);
          i_rdi=i_rd(i);
          rni=rn(i_rni);
          rdi=rd(i_rdi);
          frn=free_rn(i_rni);
          frd=free_rd(i_rdi);
          nbrn= nb_rn(i_rni);
          nbrd= nb_rd(i_rdi);
          nbr=min([nbrn,nbrd]);
          if (frn>=nbr)&(frd>=nbr) then
            iden=i_den(i_rdi);
            l_apparie(iden)=[l_apparie(iden);rni];
            free_rn(i_rni)=free_rn(i_rni)-nbr;
            free_rd(i_rdi)=free_rd(i_rdi)-nbr;
          end
        end
        deg_glob=my_degree(ci.num_glob);
        gain_glob=coeff(ci.num_glob,deg_glob);
        for id=1:length(l_apparie),
          rni=l_apparie(id);
          i=find(imag(rni)~=0);
          rni=[rni;conj(rni(i))];
          ni=real(poly(rni,'w'));
          if (id==1) then
            ni=ni*gain_glob;
          end
          nums(id)=ni;
        end
      end  //  if (ok) then
      ci.nums=nums;
      cels(i_cel)=ci;
    end
  endfunction
function phi_unwrapped=unwrap_phase(phi)
  l=length(phi);
  if l>1 then
    [m,n]=size(phi);
    phi_is_col=m>n; 
    deltaphi=phi(2:l)-phi(1:(l-1));
    deltaphi=round(deltaphi/360);
    i=find(abs(deltaphi)~=0);
    if length(i)>0 then
      M=zeros(phi);
      M(i+1) =-360* deltaphi(i);
    // integration des pulses de phase
      sys_integ=syslin('d',%z/(%z-1));sys_integ=tf2ss(sys_integ);sys_integ.X0=0;
      if (phi_is_col) then
        M=M.';
      end 
      M=dsimul(sys_integ,M);
      if (phi_is_col) then
        M=M.';
      end 
      phi=phi+M; 
    end
  end
  phi_unwrapped=phi;
endfunction
function [module_glob,arg_glob]=my_eval(cels,x)
    MODULE_MIN=1e-100;
    if (typeof(cels)=='constant') then
      rep_glob=cels;
      i=find(abs(rep_glob)<=MODULE_MIN);
      if (i~=[]) then
        rep_glob(i)= MODULE_MIN*ones(rep_glob(i));
      end
      module_glob=20*log10(abs(rep_glob));
      arg_glob=imag(log(rep_glob))*180/%pi;
      arg_glob=unwrap_phase(arg_glob);
      return
    end
    if (typeof(cels)=='polynomial') then
      rep_glob=my_horner(cels,x);
      [module_glob,arg_glob]=my_eval(rep_glob,x);
      return
    end
    if (typeof(cels)=='rational') then
      [module_glob_n,arg_glob_n]=my_eval(cels.num,x);
      [module_glob_d,arg_glob_d]=my_eval(cels.den,x);
       module_glob=module_glob_n-module_glob_d;
       arg_glob=arg_glob_n-arg_glob_d;
      return
    end
    if (typeof(cels)=='list') then
      module_glob=zeros(x);
      arg_glob=zeros(x);
      for i=1:length(cels),
       ci=cels(i);
       [module_i,arg_i]=my_eval(ci,x);
       module_glob=module_glob+module_i;
       arg_glob=arg_glob+arg_i;
      end
      arg_glob=unwrap_phase(arg_glob);
      return
    end
    module_glob=[];
    arg_glob=[];
endfunction
  function fcts_op_re_im()
    disp('-LISTE DES FONCTIONS-');
    disp('[n0_gw,n1_gw,d0_gw,d1_gw,K]=clc_Gw_et_k_op_re_im(F_w) ');
    disp('[n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im(G_w,pw) ');
    disp('[n0z,n1z,n2z,d0z,d1z,d2_z]=clc_Fz_op_re_im(G_op,K,pw) ');
    disp('[n0z_1,n1z_1,n2z_1,d0z_1,d1z_1,d2_z_1]=clc_Fz_1_op_re_im(G_op,K,pw) ');
    disp('[n0w,n1w,n2w,d0w,d1w,d2_w]=clc_Fw_op_re_im(G_op,K,pw)');
    disp('pw=clc_pw_op_re_im(a) ');
    disp('a=clc_a_op_re_im(pw) ');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im(K,n1,d1,a)');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im(K,n1,d1,a)');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im(K,n1,d1,a) ');
    disp('s=qtf_cel_op_re_im(cel,NB_BITS)'); 
    disp('s=clc_op_re_im(F_w)');
    disp('[tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(k,n1,d1,a)');
    disp('---------------------------------------');
  endfunction 
  function [n0_gw,n1_gw,d0_gw,d1_gw,K]=clc_Gw_et_k_op_re_im(F_w)
    pw=roots(denom(F_w)) 
    rw=real(pw(1)) 
    iw=-abs(imag(pw(1))) 
    pw=rw+%i*iw; 
    d2_w=coeff(denom(F_w),2) 
    n2_w=coeff(numer(F_w),2) 
    n1_w=coeff(numer(F_w),1) 
    n0_w=coeff(numer(F_w),0) 
      n0_gw = (n2_w*rw^2+2* %i *iw*n2_w*rw+n1_w*rw-iw^2*n2_w+ %i *iw*n1_w+n0_w)/(d2_w*iw*( %i *rw^2-2*iw*rw- %i *rw- %i *iw^2+iw))/2
      d1_gw = - %i /( %i *rw-iw)
      K = (n2_w+n1_w+n0_w)/(d2_w*(rw^2-2*rw+iw^2+1))
    d0_gw=1 
    n1_gw=-n0_gw 
  endfunction 
  function [n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im(G_w,pw)
    rw=real(pw) 
    iw=imag(pw) 
    n0_gw=coeff(numer(G_w),0) 
    d1_gw=coeff(denom(G_w),1) 
      n1_gop = n0_gw*(rw+ %i *iw-1)/((d1_gw+1)*(rw+ %i *iw))
      d1_gop = -(d1_gw*rw+ %i *d1_gw*iw+1)/((d1_gw+1)*(rw+ %i *iw))
    d0_gop=1 
    n0_gop=0 
  endfunction 
  function [n0z,n1z,n2z,d0z,d1z,d2z]=clc_Fz_op_re_im(G_op,K,pw)
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0z = (4*rd1^2*rw^2*K+4*rd1*rw^2*K+4*id1^2*rw^2*K+rw^2*K+4*rd1*rw*K+2*rw*K+4*iw^2*rd1^2*K+4*iw^2*rd1*K+4*id1^2*iw^2*K+iw^2*K-4*id1*iw*K+K+8*rd1*rn1*rw^2+4*rn1*rw^2+8*id1*in1*rw^2+4*rn1*rw+8*iw^2*rd1*rn1+4*iw^2*rn1+8*id1*in1*iw^2-4*in1*iw)/(rw^2-2*rw+iw^2+1)
      n1z = 2*(2*rd1*rw^2*K+rw^2*K-2*rd1*rw*K+2*iw^2*rd1*K+iw^2*K+2*id1*iw*K-K+2*rn1*rw^2-2*rn1*rw+2*iw^2*rn1+2*in1*iw)/(rw^2-2*rw+iw^2+1)
      n2z = K
      d0z = (4*rd1^2*rw^2+4*rd1*rw^2+4*id1^2*rw^2+rw^2+4*rd1*rw+2*rw+4*iw^2*rd1^2+4*iw^2*rd1+4*id1^2*iw^2+iw^2-4*id1*iw+1)/(rw^2-2*rw+iw^2+1)
      d1z = 2*(2*rd1*rw^2+rw^2-2*rd1*rw+2*iw^2*rd1+iw^2+2*id1*iw-1)/(rw^2-2*rw+iw^2+1)
      d2z = 1
  endfunction 
  function [n0z_1,n1z_1,n2z_1,d0z_1,d1z_1,d2z_1]=clc_Fz_1_op_re_im(G_op,K,pw)
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0z_1 = K
      n1z_1 = 2*(2*rd1*rw^2*K+rw^2*K-2*rd1*rw*K+2*iw^2*rd1*K+iw^2*K+2*id1*iw*K-K+2*rn1*rw^2-2*rn1*rw+2*iw^2*rn1+2*in1*iw)/(rw^2-2*rw+iw^2+1)
      n2z_1 = (4*rd1^2*rw^2*K+4*rd1*rw^2*K+4*id1^2*rw^2*K+rw^2*K+4*rd1*rw*K+2*rw*K+4*iw^2*rd1^2*K+4*iw^2*rd1*K+4*id1^2*iw^2*K+iw^2*K-4*id1*iw*K+K+8*rd1*rn1*rw^2+4*rn1*rw^2+8*id1*in1*rw^2+4*rn1*rw+8*iw^2*rd1*rn1+4*iw^2*rn1+8*id1*in1*iw^2-4*in1*iw)/(rw^2-2*rw+iw^2+1)
      d0z_1 = 1
      d1z_1 = 2*(2*rd1*rw^2+rw^2-2*rd1*rw+2*iw^2*rd1+iw^2+2*id1*iw-1)/(rw^2-2*rw+iw^2+1)
      d2z_1 = (4*rd1^2*rw^2+4*rd1*rw^2+4*id1^2*rw^2+rw^2+4*rd1*rw+2*rw+4*iw^2*rd1^2+4*iw^2*rd1+4*id1^2*iw^2+iw^2-4*id1*iw+1)/(rw^2-2*rw+iw^2+1)
  endfunction 
  function [n0w,n1w,n2w,d0w,d1w,d2w]=clc_Fw_op_re_im(G_op,K,pw)
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0w = (rw^2+iw^2)*(rd1^2*K+2*rd1*K+id1^2*K+K+2*rd1*rn1+2*rn1+2*id1*in1)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      n1w = -2*(rd1^2*rw^2*K+rd1*rw^2*K+id1^2*rw^2*K+rd1*rw*K+rw*K+iw^2*rd1^2*K+iw^2*rd1*K+id1^2*iw^2*K-id1*iw*K+2*rd1*rn1*rw^2+rn1*rw^2+2*id1*in1*rw^2+rn1*rw+2*iw^2*rd1*rn1+iw^2*rn1+2*id1*in1*iw^2-in1*iw)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      n2w = (rd1^2*rw^2*K+id1^2*rw^2*K+2*rd1*rw*K+iw^2*rd1^2*K+id1^2*iw^2*K-2*id1*iw*K+K+2*rd1*rn1*rw^2+2*id1*in1*rw^2+2*rn1*rw+2*iw^2*rd1*rn1+2*id1*in1*iw^2-2*in1*iw)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      d0w = (rd1^2+2*rd1+id1^2+1)*(rw^2+iw^2)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      d1w = -2*(rd1^2*rw^2+rd1*rw^2+id1^2*rw^2+rd1*rw+rw+iw^2*rd1^2+iw^2*rd1+id1^2*iw^2-id1*iw)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      d2w = 1
  endfunction 
  function pw=clc_pw_op_re_im(a)
    r_a=real(a) 
    i_a=imag(a) 
      rw = (r_a^2-2*r_a+i_a^2)/(r_a^2-4*r_a+i_a^2+4)
      iw = -2*i_a/(r_a^2-4*r_a+i_a^2+4)
    pw = rw + %i * iw 
  endfunction 
  function a=clc_a_op_re_im(pw)
    rw=real(pw) 
    iw=imag(pw) 
      ra = 2*(rw^2-rw+iw^2)/(rw^2-2*rw+iw^2+1)
      ia = -2*iw/(rw^2-2*rw+iw^2+1)
    a = ra + %i * ia 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im(K,n1,d1,a)
    z=poly(0,'z') 
    k_op=K 
    ra=real(a);ia=imag(a);
    rn1=real(n1);in1=imag(n1);
    rd1=real(d1);id1=imag(d1);
    F_e_x=list();
    F_b_x=list();
    F_b_s=list();
    for i=1:2,
      F_b_x(i)=list();
    end
    k_op=K 
      d_0_z = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1+id1^2*ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2+1
      d_1_z = 2*(ra*rd1+ra-ia*id1-1)
      d_2_z = 1
      d_common = d_2_z*z^2+d_1_z*z+d_0_z
    cn=d_2_z 
    d_common=d_common/cn 
      n0_z = 2*ra^2*rd1*rn1+2*ia^2*rd1*rn1+2*ra^2*rn1-2*ra*rn1+2*ia^2*rn1+k_op*ra^2*rd1^2+ia^2*k_op*rd1^2+2*k_op*ra^2*rd1-2*k_op*ra*rd1+2*ia^2*k_op*rd1+id1^2*k_op*ra^2+k_op*ra^2+2*id1*in1*ra^2-2*k_op*ra+ia^2*id1^2*k_op+2*ia*id1*k_op+ia^2*k_op+k_op+2*ia^2*id1*in1+2*ia*in1
      n1_z = 2*(ra*rn1+k_op*ra*rd1+k_op*ra-ia*id1*k_op-k_op-ia*in1)
      n2_z = k_op
     F_e_s=((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_e_x(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(id1*ra^2+ia^2*id1+ia)
      n1_z = ia
      n2_z = 0
     F_e_x(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ra*rd1+ra-ia*id1-1)
      n1_z = ra*rd1+ra-ia*id1-2
      n2_z = 1
     F_b_x(1)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ia*rd1+id1*ra+ia
      n1_z = -(ia*rd1+id1*ra+ia)
      n2_z = 0
     F_b_x(2)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
      n1_z = 2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
      n2_z = 2*rn1
     F_b_s(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ia*rd1+id1*ra+ia)
      n1_z = ia*rd1+id1*ra+ia
      n2_z = 0
     F_b_x(1)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ra*rd1+ra-ia*id1-1)
      n1_z = ra*rd1+ra-ia*id1-2
      n2_z = 1
     F_b_x(2)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1+in1)
      n1_z = 2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1+2*in1)
      n2_z = -2*in1
     F_b_s(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_b_x(1)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(id1*ra^2+ia^2*id1+ia)
      n1_z = ia
      n2_z = 0
     F_b_x(2)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+id1*in1*ra^2+ia^2*id1*in1+ia*in1)
      n1_z = 2*(ra*rn1-ia*in1)
      n2_z = 0
     F_b_s(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = id1*ra^2+ia^2*id1+ia
      n1_z = -ia
      n2_z = 0
     F_b_x(1)(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_b_x(2)(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = 2*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-in1*ra^2*rd1-ia^2*in1*rd1-in1*ra^2+in1*ra-ia^2*in1)
      n1_z = -2*(ia*rn1+in1*ra)
      n2_z = 0
     F_b_s(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im(K,n1,d1,a)
    z_1=poly(0,'z_1') 
    k_op=K 
    ra=real(a);ia=imag(a);
    rn1=real(n1);in1=imag(n1);
    rd1=real(d1);id1=imag(d1);
    F_e_x=list();
    F_b_x=list();
    F_b_s=list();
    for i=1:2,
      F_b_x(i)=list();
    end
    k_op=K 
      d_0_z_1 = 1
      d_1_z_1 = 2*(ra*rd1+ra-ia*id1-1)
      d_2_z_1 = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1+id1^2*ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2+1
      d_common = d_2_z_1*z_1^2+d_1_z_1*z_1+d_0_z_1
    cn=d_0_z_1 
    d_common=d_common/cn 
      n0_z_1 = k_op
      n1_z_1 = 2*(ra*rn1+k_op*ra*rd1+k_op*ra-ia*id1*k_op-k_op-ia*in1)
      n2_z_1 = 2*ra^2*rd1*rn1+2*ia^2*rd1*rn1+2*ra^2*rn1-2*ra*rn1+2*ia^2*rn1+k_op*ra^2*rd1^2+ia^2*k_op*rd1^2+2*k_op*ra^2*rd1-2*k_op*ra*rd1+2*ia^2*k_op*rd1+id1^2*k_op*ra^2+k_op*ra^2+2*id1*in1*ra^2-2*k_op*ra+ia^2*id1^2*k_op+2*ia*id1*k_op+ia^2*k_op+k_op+2*ia^2*id1*in1+2*ia*in1
     F_e_s=((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_e_x(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia
      n2_z_1 = -(id1*ra^2+ia^2*id1+ia)
     F_e_x(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = ra*rd1+ra-ia*id1-2
      n2_z_1 = -(ra*rd1+ra-ia*id1-1)
     F_b_x(1)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -(ia*rd1+id1*ra+ia)
      n2_z_1 = ia*rd1+id1*ra+ia
     F_b_x(2)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 2*rn1
      n1_z_1 = 2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
      n2_z_1 = -2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
     F_b_s(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia*rd1+id1*ra+ia
      n2_z_1 = -(ia*rd1+id1*ra+ia)
     F_b_x(1)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = ra*rd1+ra-ia*id1-2
      n2_z_1 = -(ra*rd1+ra-ia*id1-1)
     F_b_x(2)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = -2*in1
      n1_z_1 = 2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1+2*in1)
      n2_z_1 = -2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1+in1)
     F_b_s(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_b_x(1)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia
      n2_z_1 = -(id1*ra^2+ia^2*id1+ia)
     F_b_x(2)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = 2*(ra*rn1-ia*in1)
      n2_z_1 = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+id1*in1*ra^2+ia^2*id1*in1+ia*in1)
     F_b_s(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -ia
      n2_z_1 = id1*ra^2+ia^2*id1+ia
     F_b_x(1)(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_b_x(2)(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -2*(ia*rn1+in1*ra)
      n2_z_1 = 2*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-in1*ra^2*rd1-ia^2*in1*rd1-in1*ra^2+in1*ra-ia^2*in1)
     F_b_s(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im(K,n1,d1,a)
    w=poly(0,'w') 
    k_op=K 
    ra=real(a);ia=imag(a);
    rn1=real(n1);in1=imag(n1);
    rd1=real(d1);id1=imag(d1);
    F_e_x=list();
    F_b_x=list();
    F_b_s=list();
    for i=1:2,
      F_b_x(i)=list();
    end
    k_op=K 
      d_0_w = (ra^2+ia^2)*(rd1^2+2*rd1+id1^2+1)
      d_1_w = -2*(ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1+id1^2*ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2)
      d_2_w = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-4*ra*rd1+2*ia^2*rd1+id1^2*ra^2+ra^2-4*ra+ia^2*id1^2+4*ia*id1+ia^2+4
      d_common = d_2_w*w^2+d_1_w*w+d_0_w
    cn=d_2_w 
    d_common=d_common/cn 
      n0_w = (ra^2+ia^2)*(2*rd1*rn1+2*rn1+k_op*rd1^2+2*k_op*rd1+id1^2*k_op+k_op+2*id1*in1)
      n1_w = -2*(2*ra^2*rd1*rn1+2*ia^2*rd1*rn1+2*ra^2*rn1-2*ra*rn1+2*ia^2*rn1+k_op*ra^2*rd1^2+ia^2*k_op*rd1^2+2*k_op*ra^2*rd1-2*k_op*ra*rd1+2*ia^2*k_op*rd1+id1^2*k_op*ra^2+k_op*ra^2+2*id1*in1*ra^2-2*k_op*ra+ia^2*id1^2*k_op+2*ia*id1*k_op+ia^2*k_op+2*ia^2*id1*in1+2*ia*in1)
      n2_w = 2*ra^2*rd1*rn1+2*ia^2*rd1*rn1+2*ra^2*rn1-4*ra*rn1+2*ia^2*rn1+k_op*ra^2*rd1^2+ia^2*k_op*rd1^2+2*k_op*ra^2*rd1-4*k_op*ra*rd1+2*ia^2*k_op*rd1+id1^2*k_op*ra^2+k_op*ra^2+2*id1*in1*ra^2-4*k_op*ra+ia^2*id1^2*k_op+4*ia*id1*k_op+ia^2*k_op+4*k_op+2*ia^2*id1*in1+4*ia*in1
     F_e_s=((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_e_x(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = -id1*(ra^2+ia^2)
      n1_w = 2*(id1*ra^2+ia^2*id1+ia)
      n2_w = -(id1*ra^2+ia^2*id1+2*ia)
     F_e_x(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ra*rd1+ra-ia*id1)
      n2_w = -2*(ra*rd1+ra-ia*id1-2)
     F_b_x(1)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = -2*(ia*rd1+id1*ra+ia)
      n2_w = 2*(ia*rd1+id1*ra+ia)
     F_b_x(2)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 4*(ra*rd1*rn1+ra*rn1-ia*id1*rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
      n2_w = -4*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1+ia*in1*rd1+id1*in1*ra+ia*in1)
     F_b_s(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ia*rd1+id1*ra+ia)
      n2_w = -2*(ia*rd1+id1*ra+ia)
     F_b_x(1)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ra*rd1+ra-ia*id1)
      n2_w = -2*(ra*rd1+ra-ia*id1-2)
     F_b_x(2)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 4*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1)
      n2_w = -4*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-in1*ra*rd1-in1*ra+ia*id1*in1+2*in1)
     F_b_s(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_b_x(1)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = -id1*(ra^2+ia^2)
      n1_w = 2*(id1*ra^2+ia^2*id1+ia)
      n2_w = -(id1*ra^2+ia^2*id1+2*ia)
     F_b_x(2)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 2*(ra^2+ia^2)*(rd1*rn1+rn1+id1*in1)
      n1_w = -4*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+id1*in1*ra^2+ia^2*id1*in1+ia*in1)
      n2_w = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-2*ra*rn1+ia^2*rn1+id1*in1*ra^2+ia^2*id1*in1+2*ia*in1)
     F_b_s(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = id1*(ra^2+ia^2)
      n1_w = -2*(id1*ra^2+ia^2*id1+ia)
      n2_w = id1*ra^2+ia^2*id1+2*ia
     F_b_x(1)(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_b_x(2)(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 2*(ra^2+ia^2)*(id1*rn1-in1*rd1-in1)
      n1_w = -4*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-in1*ra^2*rd1-ia^2*in1*rd1-in1*ra^2+in1*ra-ia^2*in1)
      n2_w = 2*(id1*ra^2*rn1+ia^2*id1*rn1+2*ia*rn1-in1*ra^2*rd1-ia^2*in1*rd1-in1*ra^2+2*in1*ra-ia^2*in1)
     F_b_s(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
  endfunction 
  function [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(k,n1,d1,a)
  // calcul transferts en z
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im(k,n1,d1,a);
    tf_z.F_e_s=F_e_s;
    tf_z.F_e_x=F_e_x;
    tf_z.F_b_s=F_b_s;
    tf_z.F_b_x=F_b_x;
    tf_z.d_common=d_common;
  // calcul transferts en w
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im(k,n1,d1,a);
    tf_w.F_e_s=F_e_s;
    tf_w.F_e_x=F_e_x;
    tf_w.F_b_s=F_b_s;
    tf_w.F_b_x=F_b_x;
    tf_w.d_common=d_common;
  // calcul transferts en z_1
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im(k,n1,d1,a);
    tf_z_1.F_e_s=F_e_s;
    tf_z_1.F_e_x=F_e_x;
    tf_z_1.F_b_s=F_b_s;
    tf_z_1.F_b_x=F_b_x;
    tf_z_1.d_common=d_common;
  endfunction
  function s=qtf_cel_op_re_im(cel,NB_BITS)
    cel.re_n1_qtf = qtf_coeff(real(cel.n1),NB_BITS);
    cel.im_n1_qtf = qtf_coeff(imag(cel.n1),NB_BITS);
    cel.re_d1_qtf = qtf_coeff(real(cel.d1),NB_BITS);
    cel.im_d1_qtf = qtf_coeff(imag(cel.d1),NB_BITS);
    cel.n1_q=cel.re_n1_qtf.coeff_quantifie + %i * cel.im_n1_qtf.coeff_quantifie;
    cel.d1_q=cel.re_d1_qtf.coeff_quantifie + %i * cel.im_d1_qtf.coeff_quantifie;
  // calcul plus petit decalage numerateur cellule i_f
    Lmin=[];
    if (cel.re_n1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.re_n1_qtf.L];
    end
    if (cel.im_n1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.im_n1_qtf.L];
    end

    Lmin=min(Lmin);
    cel.L_min_num=Lmin;
    Lmin=[];
    if (cel.re_d1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.re_d1_qtf.L];
    end
    if (cel.im_d1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.im_d1_qtf.L];
    end
    Lmin=min(Lmin);
    cel.L_min_den=Lmin;
    s=cel;
  // calcul transferts en z
    s.k_q=s.k;
    [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(s.k_q,s.n1_q,s.d1_q,s.a);
    s.tf_z_qtf=tf_z;
    s.tf_z_1_qtf=tf_z_1;
    s.tf_w_qtf=tf_w;

  endfunction
  function s=clc_op_re_im(F_w)
    s.F_w=F_w;
    w=poly(0,'w');
    z=poly(0,'z');
    z_1=poly(0,'z_1');
    w_de_z=(z-1)/(z+1);
    z_de_w=(1+w)/(1-w);
    s.type_cel='op_re_im';
    [n0_gw,n1_gw,d0_gw,d1_gw,K]=clc_Gw_et_k_op_re_im(F_w);
    s.k=K;
    s.G_w=(n0_gw+n1_gw*w)/(d0_gw+d1_gw*w); 
    s.G_w_conj=(conj(n0_gw)+conj(n1_gw)*w)/(d0_gw+conj(d1_gw)*w); 
    s.sum_gw=s.G_w+s.G_w_conj;
    s.F_retrouve_w=s.k+s.sum_gw;
    pw=roots( d0_gw + d1_gw * w );
    a=clc_a_op_re_im(pw);
    s.pw_ideal=pw;
    s.a_ideal=a;
    s.a0=real(s.a_ideal);
    s.a1=imag(s.a_ideal);
  //  l_a0=round(l_a0);    // on arrondit a l'entier le plus proche
    s.l_a0=-log2(s.a0);               
    s.l_a0=round(s.l_a0);
    s.l_a0=max([s.l_a0,0]);
    s.a0= 2^(-s.l_a0);        ;    //on en deduit a0 pour cette valeur de s.l_a0
  //  l_a1=round(l_a1);    // on arrondit a l'entier le plus proche
    s.l_a1=-log2(s.a1);               
    s.l_a1=round(s.l_a1);
    s.l_a1=max([s.l_a1,0]);
    s.a1= 2^(-s.l_a1);        ;    //on en deduit a1 pour cette valeur de s.l_a1
    s.a=s.a0+%i*s.a1; 
    s.pw=clc_pw_op_re_im(s.a);
   // determination operateur en w
    s.op_de_w=(1-w)/(1-w/s.pw)  ;
    s.w_de_op=-(op-1)*s.pw/(s.pw-op);// w =f(op)= fraction rationnelle en op
  //-------------------------------------------------------
  // normalisation du gain k en parallele, k=1 ou k=0
  //-------------------------------------------------------
    if (abs(s.k)>1e-12) then
      k_norm=s.k;
    else
      k_norm=1;
    end
    s.k_norm=k_norm;
    s.k=s.k/s.k_norm;
    s.G_w=(numer(s.G_w)/k_norm)/denom(s.G_w);
// determination de G_op = expression du filtre = G(op)
   [n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im(s.G_w,s.pw)
    s.G_op=(n0_gop+n1_gop*op)/(d0_gop+d1_gop*op);
    s.d1=d1_gop;
    s.n1=n1_gop; 
  // calcul transferts en z
    [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(s.k,s.n1,s.d1,s.a);
    s.tf_z=tf_z;
    s.tf_z_1=tf_z_1;
    s.tf_w=tf_w;
  endfunction
 function fcts_op_re_im_v2()
    disp('-LISTE DES FONCTIONS-');
    disp('[n0_gw,n1_gw,d0_gw,d1_gw]=clc_Gw_op_re_im_v2(F_w) ');
    disp('[n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im_v2(G_w,pw) ');
    disp('[n0z,n1z,n2z,d0z,d1z,d2_z]=clc_Fz_op_re_im_v2(G_op,pw) ');
    disp('[n0z_1,n1z_1,n2z_1,d0z_1,d1z_1,d2_z_1]=clc_Fz_1_op_re_im_v2(G_op,pw) ');
    disp('[n0w,n1w,n2w,d0w,d1w,d2_w]=clc_Fw_op_re_im_v2(G_op,pw)');
    disp('pw=clc_pw_op_re_im_v2(a) ');
    disp('a=clc_a_op_re_im_v2(pw) ');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im_v2(n0,n1,d1,a)');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im_v2(n0,n1,d1,a)');
    disp('[F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im_v2(n0,n1,d1,a) ');
    disp('s=qtf_cel_op_re_im_v2(cel,NB_BITS)');
    disp('s=clc_op_re_im_v2(F_w)');
    disp('[tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(n0,n1,d1,a)');
    disp('---------------------------------------');
  endfunction
  function [n0_gw,n1_gw,d0_gw,d1_gw]=clc_Gw_op_re_im_v2(F_w) 
    pw=roots(denom(F_w)) 
    rw=real(pw(1)) 
    iw=-abs(imag(pw(1))) 
    d2_w=coeff(denom(F_w),2) 
    n2_w=coeff(numer(F_w),2) 
    n1_w=coeff(numer(F_w),1) 
    n0_w=coeff(numer(F_w),0) 
      n0_gw = (n2_w*rw^4+2*%i*iw*n2_w*rw^3-2*n2_w*rw^3+n1_w*rw^3-3*%i..
        *iw*n2_w*rw^2+n2_w*rw^2+2*%i*iw*n1_w*rw^2-2*n1_w*rw^2+%i*iw*n0_w..
        *rw^2+n0_w*rw^2+2*%i*iw^3*n2_w*rw+%i*iw*n2_w*rw-iw^2*n1_w*rw-3..
        *%i*iw*n1_w*rw+n1_w*rw-2*iw^2*n0_w*rw-%i*iw*n0_w*rw-2*n0_w*rw..
        -iw^4*n2_w-%i*iw^3*n2_w+iw^2*n1_w+%i*iw*n1_w-%i*iw^3*n0_w+2*iw^2..
        *n0_w+n0_w)/(d2_w*iw*(rw^2-2*rw+iw^2+1)*(%i*rw^2-2*iw*rw-%i*rw..
        -%i*iw^2+iw))/2
      n1_gw = -(n2_w*rw^4+2*%i*iw*n2_w*rw^3-2*n2_w*rw^3+n1_w*rw^3-4*%i..
        *iw*n2_w*rw^2+n2_w*rw^2+%i*iw*n1_w*rw^2-2*n1_w*rw^2+n0_w*rw^2..
        +2*%i*iw^3*n2_w*rw+2*iw^2*n2_w*rw+3*%i*iw*n2_w*rw+iw^2*n1_w*rw..
        -%i*iw*n1_w*rw+n1_w*rw+%i*iw*n0_w*rw-2*n0_w*rw-iw^4*n2_w-2*iw^2..
        *n2_w-%i*iw*n2_w+%i*iw^3*n1_w-iw^2*n1_w-%i*iw*n0_w+n0_w)/(d2_w..
        *iw*(rw^2-2*rw+iw^2+1)*(%i*rw^2-2*iw*rw-%i*rw-%i*iw^2+iw))/2
      d1_gw = -(%i*rw-iw+(-%i))/(%i*rw^2-2*iw*rw-%i*rw-%i*iw^2+iw)
    d0_gw=1 
  endfunction 
  function [n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im_v2(G_w,pw) 
    rw=real(pw) 
    iw=imag(pw) 
    n0_gw=coeff(numer(G_w),0) 
    d1_gw=coeff(denom(G_w),1) 
      n0_gop = (n1_gw+n0_gw)/(d1_gw+1)
      n1_gop = -(n1_gw*rw+%i*iw*n1_gw+n0_gw)/((d1_gw+1)*(rw+%i*iw))
      d1_gop = -(d1_gw*rw+%i*d1_gw*iw+1)/((d1_gw+1)*(rw+%i*iw))
    d0_gop=1 
  endfunction 
  function [n0z,n1z,n2z,d0z,d1z,d2z]=clc_Fz_op_re_im_v2(G_op,pw) 
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0z = 2*(4*rd1*rn1*rw^2+2*rn1*rw^2+2*rd1*rn0*rw^2+rn0*rw^2+4*id1..
        *in1*rw^2+2*id1*in0*rw^2+2*rn1*rw+2*rd1*rn0*rw+2*rn0*rw+2*id1..
        *in0*rw+4*iw^2*rd1*rn1+2*iw^2*rn1+2*iw^2*rd1*rn0+iw^2*rn0-2*id1..
        *iw*rn0+rn0+2*in0*iw*rd1+4*id1*in1*iw^2+2*id1*in0*iw^2-2*in1*iw)..
        /(rw^2-2*rw+iw^2+1)
      n1z = 4*(rn1*rw^2+rd1*rn0*rw^2+rn0*rw^2+id1*in0*rw^2-rn1*rw-rd1..
        *rn0*rw-id1*in0*rw+iw^2*rn1+iw^2*rd1*rn0+iw^2*rn0+id1*iw*rn0-rn0..
        -in0*iw*rd1+id1*in0*iw^2+in1*iw)/(rw^2-2*rw+iw^2+1)
      n2z = 2*rn0
      d0z = (4*rd1^2*rw^2+4*rd1*rw^2+4*id1^2*rw^2+rw^2+4*rd1*rw+2*rw+4..
        *iw^2*rd1^2+4*iw^2*rd1+4*id1^2*iw^2+iw^2-4*id1*iw+1)/(rw^2-2*rw..
        +iw^2+1)
      d1z = 2*(2*rd1*rw^2+rw^2-2*rd1*rw+2*iw^2*rd1+iw^2+2*id1*iw-1)/(rw^2..
        -2*rw+iw^2+1)
      d2z = 1
  endfunction 
  function [n0z_1,n1z_1,n2z_1,d0z_1,d1z_1,d2z_1]=clc_Fz_1_op_re_im_v2(G_op,pw) 
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0z_1 = 2*rn0
      n1z_1 = 4*(rn1*rw^2+rd1*rn0*rw^2+rn0*rw^2+id1*in0*rw^2-rn1*rw-rd1..
        *rn0*rw-id1*in0*rw+iw^2*rn1+iw^2*rd1*rn0+iw^2*rn0+id1*iw*rn0-rn0..
        -in0*iw*rd1+id1*in0*iw^2+in1*iw)/(rw^2-2*rw+iw^2+1)
      n2z_1 = 2*(4*rd1*rn1*rw^2+2*rn1*rw^2+2*rd1*rn0*rw^2+rn0*rw^2+4*id1..
        *in1*rw^2+2*id1*in0*rw^2+2*rn1*rw+2*rd1*rn0*rw+2*rn0*rw+2*id1..
        *in0*rw+4*iw^2*rd1*rn1+2*iw^2*rn1+2*iw^2*rd1*rn0+iw^2*rn0-2*id1..
        *iw*rn0+rn0+2*in0*iw*rd1+4*id1*in1*iw^2+2*id1*in0*iw^2-2*in1*iw)..
        /(rw^2-2*rw+iw^2+1)
      d0z_1 = 1
      d1z_1 = 2*(2*rd1*rw^2+rw^2-2*rd1*rw+2*iw^2*rd1+iw^2+2*id1*iw-1)..
        /(rw^2-2*rw+iw^2+1)
      d2z_1 = (4*rd1^2*rw^2+4*rd1*rw^2+4*id1^2*rw^2+rw^2+4*rd1*rw+2*rw..
        +4*iw^2*rd1^2+4*iw^2*rd1+4*id1^2*iw^2+iw^2-4*id1*iw+1)/(rw^2-2..
        *rw+iw^2+1)
  endfunction 
  function [n0w,n1w,n2w,d0w,d1w,d2w]=clc_Fw_op_re_im_v2(G_op,pw) 
    rw=real(pw) 
    iw=imag(pw) 
    n1=coeff(numer(G_op),1) 
    d1=coeff(denom(G_op),1) 
    rn1=real(n1) 
    in1=imag(n1) 
    rd1=real(d1) 
    id1=imag(d1) 
      n0w = 2*(rd1*rn1+rn1+id1*in1)*(rw^2+iw^2)/(rd1^2*rw^2+id1^2*rw^2..
        +2*rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      n1w = -2*(2*rd1*rn1*rw^2+rn1*rw^2+2*id1*in1*rw^2+rn1*rw+2*iw^2*rd1..
        *rn1+iw^2*rn1+2*id1*in1*iw^2-in1*iw)/(rd1^2*rw^2+id1^2*rw^2+2..
        *rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      n2w = 2*(rd1*rn1*rw^2+id1*in1*rw^2+rn1*rw+iw^2*rd1*rn1+id1*in1*iw^2..
        -in1*iw)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2+id1^2*iw^2..
        -2*id1*iw+1)
      d0w = (rd1^2+2*rd1+id1^2+1)*(rw^2+iw^2)/(rd1^2*rw^2+id1^2*rw^2+2..
        *rd1*rw+iw^2*rd1^2+id1^2*iw^2-2*id1*iw+1)
      d1w = -2*(rd1^2*rw^2+rd1*rw^2+id1^2*rw^2+rd1*rw+rw+iw^2*rd1^2+iw^2..
        *rd1+id1^2*iw^2-id1*iw)/(rd1^2*rw^2+id1^2*rw^2+2*rd1*rw+iw^2*rd1^2..
        +id1^2*iw^2-2*id1*iw+1)
      d2w = 1
  endfunction 
  function pw=clc_pw_op_re_im_v2(a) 
    r_a=real(a) 
    i_a=imag(a) 
      rw = (r_a^2-2*r_a+i_a^2)/(r_a^2-4*r_a+i_a^2+4)
      iw = -2*i_a/(r_a^2-4*r_a+i_a^2+4)
    pw = rw + %i * iw 
  endfunction 
  function a=clc_a_op_re_im_v2(pw) 
    rw=real(pw) 
    iw=imag(pw) 
      ra = 2*(rw^2-rw+iw^2)/(rw^2-2*rw+iw^2+1)
      ia = -2*iw/(rw^2-2*rw+iw^2+1)
    a = ra + %i * ia 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im_v2(n0,n1,d1,a)
    z=poly(0,'z') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    rn0=real(n0);in0=imag(n0); 
    rn1=real(n1);in1=imag(n1); 
    rd1=real(d1);id1=imag(d1); 
    ra=real(a);ia=imag(a); 
      d_0_z = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1+id1^2..
        *ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2+1
      d_1_z = 2*(ra*rd1+ra-ia*id1-1)
      d_2_z = 1
      d_common = d_2_z*z^2+d_1_z*z+d_0_z
    cn=d_2_z 
    d_common=d_common/cn 
      n0_z = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0+rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra..
        +ia^2*id1*in1+ia*in1+ia^2*id1*in0)
      n1_z = 2*(ra*rn1+ra*rd1*rn0+2*ra*rn0-ia*id1*rn0-2*rn0+ia*in0*rd1..
        +id1*in0*ra-ia*in1)
      n2_z = 2*rn0
     F_e_s=((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_e_x(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(id1*ra^2+ia^2*id1+ia)
      n1_z = ia
      n2_z = 0
     F_e_x(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ra*rd1+ra-ia*id1-1)
      n1_z = ra*rd1+ra-ia*id1-2
      n2_z = 1
     F_b_x(1)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ia*rd1+id1*ra+ia
      n1_z = -(ia*rd1+id1*ra+ia)
      n2_z = 0
     F_b_x(2)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-rn1-ra*rd1^2*rn0-ra*rd1..
        *rn0+rd1*rn0-id1^2*ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1-ia..
        *in0*rd1+id1*in1*ra+id1*in0*ra+ia*in1-ia*id1^2*in0-id1*in0)
      n1_z = 2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1-ra*rd1^2*rn0-ra*rd1..
        *rn0+2*rd1*rn0-id1^2*ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1..
        -ia*in0*rd1+id1*in1*ra+id1*in0*ra+ia*in1-ia*id1^2*in0-2*id1..
        *in0)
      n2_z = 2*(rn1-rd1*rn0+id1*in0)
     F_b_s(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ia*rd1+id1*ra+ia)
      n1_z = ia*rd1+id1*ra+ia
      n2_z = 0
     F_b_x(1)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(ra*rd1+ra-ia*id1-1)
      n1_z = ra*rd1+ra-ia*id1-2
      n2_z = 1
     F_b_x(2)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0..
        +id1*ra*rn0-ia*id1^2*rn0-id1*rn0+in0*ra*rd1^2-in1*ra*rd1+in0*ra..
        *rd1-in0*rd1-in1*ra+id1^2*in0*ra+ia*id1*in1+in1+ia*id1*in0)
      n1_z = 2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0+id1..
        *ra*rn0-ia*id1^2*rn0-2*id1*rn0+in0*ra*rd1^2-in1*ra*rd1+in0*ra..
        *rd1-2*in0*rd1-in1*ra+id1^2*in0*ra+ia*id1*in1+2*in1+ia*id1..
        *in0)
      n2_z = 2*(id1*rn0+in0*rd1-in1)
     F_b_s(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_b_x(1)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(id1*ra^2+ia^2*id1+ia)
      n1_z = ia
      n2_z = 0
     F_b_x(2)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0+rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra..
        +ia^2*id1*in1+ia*in1+ia^2*id1*in0)
      n1_z = 2*(ra*rn1+ra*rd1*rn0+2*ra*rn0-ia*id1*rn0-2*rn0+ia*in0*rd1..
        +id1*in0*ra-ia*in1)
      n2_z = 2*rn0
     F_b_s(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = id1*ra^2+ia^2*id1+ia
      n1_z = -ia
      n2_z = 0
     F_b_x(1)(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
      n1_z = ra
      n2_z = 0
     F_b_x(2)(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = 2*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-ia*rd1*rn0+id1*ra^2*rn0..
        -id1*ra*rn0+ia^2*id1*rn0-in1*ra^2*rd1-in0*ra^2*rd1+in0*ra*rd1..
        -ia^2*in1*rd1-ia^2*in0*rd1-in1*ra^2-in0*ra^2+in1*ra+2*in0*ra-ia^2..
        *in1-ia*id1*in0-ia^2*in0-in0)
      n1_z = -2*(ia*rn1-ia*rd1*rn0-id1*ra*rn0+in0*ra*rd1+in1*ra+2*in0..
        *ra-ia*id1*in0-2*in0)
      n2_z = -2*in0
     F_b_s(4) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im_v2(n0,n1,d1,a)
    z_1=poly(0,'z_1') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    rn0=real(n0);in0=imag(n0); 
    rn1=real(n1);in1=imag(n1); 
    rd1=real(d1);id1=imag(d1); 
    ra=real(a);ia=imag(a); 
      d_0_z_1 = 1
      d_1_z_1 = 2*(ra*rd1+ra-ia*id1-1)
      d_2_z_1 = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1+id1^2..
        *ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2+1
      d_common = d_2_z_1*z_1^2+d_1_z_1*z_1+d_0_z_1
    cn=d_0_z_1 
    d_common=d_common/cn 
      n0_z_1 = 2*rn0
      n1_z_1 = 2*(ra*rn1+ra*rd1*rn0+2*ra*rn0-ia*id1*rn0-2*rn0+ia*in0*rd1..
        +id1*in0*ra-ia*in1)
      n2_z_1 = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0+rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra..
        +ia^2*id1*in1+ia*in1+ia^2*id1*in0)
     F_e_s=((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_e_x(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia
      n2_z_1 = -(id1*ra^2+ia^2*id1+ia)
     F_e_x(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = ra*rd1+ra-ia*id1-2
      n2_z_1 = -(ra*rd1+ra-ia*id1-1)
     F_b_x(1)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -(ia*rd1+id1*ra+ia)
      n2_z_1 = ia*rd1+id1*ra+ia
     F_b_x(2)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 2*(rn1-rd1*rn0+id1*in0)
      n1_z_1 = 2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1-ra*rd1^2*rn0-ra*rd1..
        *rn0+2*rd1*rn0-id1^2*ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1..
        -ia*in0*rd1+id1*in1*ra+id1*in0*ra+ia*in1-ia*id1^2*in0-2*id1..
        *in0)
      n2_z_1 = -2*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-rn1-ra*rd1^2*rn0-ra*rd1..
        *rn0+rd1*rn0-id1^2*ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1-ia..
        *in0*rd1+id1*in1*ra+id1*in0*ra+ia*in1-ia*id1^2*in0-id1*in0)
     F_b_s(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia*rd1+id1*ra+ia
      n2_z_1 = -(ia*rd1+id1*ra+ia)
     F_b_x(1)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = ra*rd1+ra-ia*id1-2
      n2_z_1 = -(ra*rd1+ra-ia*id1-1)
     F_b_x(2)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 2*(id1*rn0+in0*rd1-in1)
      n1_z_1 = 2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0..
        +id1*ra*rn0-ia*id1^2*rn0-2*id1*rn0+in0*ra*rd1^2-in1*ra*rd1+in0..
        *ra*rd1-2*in0*rd1-in1*ra+id1^2*in0*ra+ia*id1*in1+2*in1+ia*id1..
        *in0)
      n2_z_1 = -2*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0..
        +id1*ra*rn0-ia*id1^2*rn0-id1*rn0+in0*ra*rd1^2-in1*ra*rd1+in0*ra..
        *rd1-in0*rd1-in1*ra+id1^2*in0*ra+ia*id1*in1+in1+ia*id1*in0)
     F_b_s(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_b_x(1)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ia
      n2_z_1 = -(id1*ra^2+ia^2*id1+ia)
     F_b_x(2)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 2*rn0
      n1_z_1 = 2*(ra*rn1+ra*rd1*rn0+2*ra*rn0-ia*id1*rn0-2*rn0+ia*in0*rd1..
        +id1*in0*ra-ia*in1)
      n2_z_1 = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0+rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra..
        +ia^2*id1*in1+ia*in1+ia^2*id1*in0)
     F_b_s(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -ia
      n2_z_1 = id1*ra^2+ia^2*id1+ia
     F_b_x(1)(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = ra
      n2_z_1 = ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2
     F_b_x(2)(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = -2*in0
      n1_z_1 = -2*(ia*rn1-ia*rd1*rn0-id1*ra*rn0+in0*ra*rd1+in1*ra+2*in0..
        *ra-ia*id1*in0-2*in0)
      n2_z_1 = 2*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-ia*rd1*rn0+id1*ra^2..
        *rn0-id1*ra*rn0+ia^2*id1*rn0-in1*ra^2*rd1-in0*ra^2*rd1+in0*ra..
        *rd1-ia^2*in1*rd1-ia^2*in0*rd1-in1*ra^2-in0*ra^2+in1*ra+2*in0..
        *ra-ia^2*in1-ia*id1*in0-ia^2*in0-in0)
     F_b_s(4) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im_v2(n0,n1,d1,a)
    w=poly(0,'w') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    rn0=real(n0);in0=imag(n0); 
    rn1=real(n1);in1=imag(n1); 
    rd1=real(d1);id1=imag(d1); 
    ra=real(a);ia=imag(a); 
      d_0_w = (ra^2+ia^2)*(rd1^2+2*rd1+id1^2+1)
      d_1_w = -2*(ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-2*ra*rd1+2*ia^2*rd1..
        +id1^2*ra^2+ra^2-2*ra+ia^2*id1^2+2*ia*id1+ia^2)
      d_2_w = ra^2*rd1^2+ia^2*rd1^2+2*ra^2*rd1-4*ra*rd1+2*ia^2*rd1+id1^2..
        *ra^2+ra^2-4*ra+ia^2*id1^2+4*ia*id1+ia^2+4
      d_common = d_2_w*w^2+d_1_w*w+d_0_w
    cn=d_2_w 
    d_common=d_common/cn 
      n0_w = 2*(ra^2+ia^2)*(rd1*rn1+rn1+rd1*rn0+rn0+id1*in1+id1*in0)
      n1_w = -4*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra+ia^2..
        *id1*in1+ia*in1+ia^2*id1*in0)
      n2_w = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-2*ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-2*ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-4*ra*rn0+2*ia*id1..
        *rn0+ia^2*rn0+4*rn0-2*ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-2*id1..
        *in0*ra+ia^2*id1*in1+2*ia*in1+ia^2*id1*in0)
     F_e_s=((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_e_x(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = -id1*(ra^2+ia^2)
      n1_w = 2*(id1*ra^2+ia^2*id1+ia)
      n2_w = -(id1*ra^2+ia^2*id1+2*ia)
     F_e_x(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ra*rd1+ra-ia*id1)
      n2_w = -2*(ra*rd1+ra-ia*id1-2)
     F_b_x(1)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = -2*(ia*rd1+id1*ra+ia)
      n2_w = 2*(ia*rd1+id1*ra+ia)
     F_b_x(2)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 4*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-ra*rd1^2*rn0-ra*rd1*rn0-id1^2..
        *ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1-ia*in0*rd1+id1*in1..
        *ra+id1*in0*ra+ia*in1-ia*id1^2*in0)
      n2_w = -4*(ra*rd1*rn1+ra*rn1-ia*id1*rn1-2*rn1-ra*rd1^2*rn0-ra*rd1..
        *rn0+2*rd1*rn0-id1^2*ra*rn0-ia*id1*rn0-ia*in0*rd1^2+ia*in1*rd1..
        -ia*in0*rd1+id1*in1*ra+id1*in0*ra+ia*in1-ia*id1^2*in0-2*id1..
        *in0)
     F_b_s(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ia*rd1+id1*ra+ia)
      n2_w = -2*(ia*rd1+id1*ra+ia)
     F_b_x(1)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*(ra*rd1+ra-ia*id1)
      n2_w = -2*(ra*rd1+ra-ia*id1-2)
     F_b_x(2)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 4*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0+id1..
        *ra*rn0-ia*id1^2*rn0+in0*ra*rd1^2-in1*ra*rd1+in0*ra*rd1-in1*ra..
        +id1^2*in0*ra+ia*id1*in1+ia*id1*in0)
      n2_w = -4*(ia*rd1*rn1+id1*ra*rn1+ia*rn1-ia*rd1^2*rn0-ia*rd1*rn0..
        +id1*ra*rn0-ia*id1^2*rn0-2*id1*rn0+in0*ra*rd1^2-in1*ra*rd1+in0..
        *ra*rd1-2*in0*rd1-in1*ra+id1^2*in0*ra+ia*id1*in1+2*in1+ia*id1..
        *in0)
     F_b_s(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_b_x(1)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = -id1*(ra^2+ia^2)
      n1_w = 2*(id1*ra^2+ia^2*id1+ia)
      n2_w = -(id1*ra^2+ia^2*id1+2*ia)
     F_b_x(2)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 2*(ra^2+ia^2)*(rd1*rn1+rn1+rd1*rn0+rn0+id1*in1+id1*in0)
      n1_w = -4*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-2*ra*rn0+ia*id1*rn0..
        +ia^2*rn0-ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-id1*in0*ra+ia^2..
        *id1*in1+ia*in1+ia^2*id1*in0)
      n2_w = 2*(ra^2*rd1*rn1+ia^2*rd1*rn1+ra^2*rn1-2*ra*rn1+ia^2*rn1+ra^2..
        *rd1*rn0-2*ra*rd1*rn0+ia^2*rd1*rn0+ra^2*rn0-4*ra*rn0+2*ia*id1..
        *rn0+ia^2*rn0+4*rn0-2*ia*in0*rd1+id1*in1*ra^2+id1*in0*ra^2-2*id1..
        *in0*ra+ia^2*id1*in1+2*ia*in1+ia^2*id1*in0)
     F_b_s(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = id1*(ra^2+ia^2)
      n1_w = -2*(id1*ra^2+ia^2*id1+ia)
      n2_w = id1*ra^2+ia^2*id1+2*ia
     F_b_x(1)(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = (ra^2+ia^2)*(rd1+1)
      n1_w = -2*(ra^2*rd1+ia^2*rd1+ra^2-ra+ia^2)
      n2_w = ra^2*rd1+ia^2*rd1+ra^2-2*ra+ia^2
     F_b_x(2)(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 2*(ra^2+ia^2)*(id1*rn1+id1*rn0-in1*rd1-in0*rd1-in1-in0)
      n1_w = -4*(id1*ra^2*rn1+ia^2*id1*rn1+ia*rn1-ia*rd1*rn0+id1*ra^2..
        *rn0-id1*ra*rn0+ia^2*id1*rn0-in1*ra^2*rd1-in0*ra^2*rd1+in0*ra..
        *rd1-ia^2*in1*rd1-ia^2*in0*rd1-in1*ra^2-in0*ra^2+in1*ra+2*in0..
        *ra-ia^2*in1-ia*id1*in0-ia^2*in0)
      n2_w = 2*(id1*ra^2*rn1+ia^2*id1*rn1+2*ia*rn1-2*ia*rd1*rn0+id1*ra^2..
        *rn0-2*id1*ra*rn0+ia^2*id1*rn0-in1*ra^2*rd1-in0*ra^2*rd1+2*in0..
        *ra*rd1-ia^2*in1*rd1-ia^2*in0*rd1-in1*ra^2-in0*ra^2+2*in1*ra+4..
        *in0*ra-ia^2*in1-2*ia*id1*in0-ia^2*in0-4*in0)
     F_b_s(4) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
  endfunction 
function s=qtf_cel_op_re_im_v2(cel,NB_BITS)
    cel.re_n0_qtf = qtf_coeff(real(cel.n0),NB_BITS);
    cel.im_n0_qtf = qtf_coeff(imag(cel.n0),NB_BITS);
    cel.re_n1_qtf = qtf_coeff(real(cel.n1),NB_BITS);
    cel.im_n1_qtf = qtf_coeff(imag(cel.n1),NB_BITS);
    cel.re_d1_qtf = qtf_coeff(real(cel.d1),NB_BITS);
    cel.im_d1_qtf = qtf_coeff(imag(cel.d1),NB_BITS);
    cel.n0_q=cel.re_n0_qtf.coeff_quantifie + %i * cel.im_n0_qtf.coeff_quantifie;
    cel.n1_q=cel.re_n1_qtf.coeff_quantifie + %i * cel.im_n1_qtf.coeff_quantifie;
    cel.d1_q=cel.re_d1_qtf.coeff_quantifie + %i * cel.im_d1_qtf.coeff_quantifie;
  // calcul plus petit decalage numerateur cellule i_f
    Lmin=[];
    if (cel.re_n0_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.re_n0_qtf.L];
    end
    if (cel.im_n0_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.im_n0_qtf.L];
    end
    if (cel.re_n1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.re_n1_qtf.L];
    end
    if (cel.im_n1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.im_n1_qtf.L];
    end

    Lmin=min(Lmin);
    cel.L_min_num=Lmin;
    Lmin=[];
    if (cel.re_d1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.re_d1_qtf.L];
    end
    if (cel.im_d1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.im_d1_qtf.L];
    end
    Lmin=min(Lmin);
    cel.L_min_den=Lmin;
    s=cel;
  // calcul transferts en z
    s.k_q=s.k;
    [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(s.n0_q,s.n1_q,s.d1_q,s.a);
    s.tf_z_qtf=tf_z;
    s.tf_z_1_qtf=tf_z_1;
    s.tf_w_qtf=tf_w;

  endfunction
 function s=clc_op_re_im_v2(F_w)
    s.F_w=F_w;
    w=poly(0,'w');
    z=poly(0,'z');
    z_1=poly(0,'z_1');
    w_de_z=(z-1)/(z+1);
    z_de_w=(1+w)/(1-w);
    s.type_cel='op_re_im_v2';
    [n0_gw,n1_gw,d0_gw,d1_gw]=clc_Gw_op_re_im_v2(F_w);
    pw=roots( d0_gw + d1_gw * w );
    a=clc_a_op_re_im_v2(pw);
    s.k=0;
    s.G_w=(n0_gw+n1_gw*w)/(d0_gw+d1_gw*w); 
    s.G_w_conj=(conj(n0_gw)+conj(n1_gw)*w)/(d0_gw+conj(d1_gw)*w); 
    s.sum_gw=s.G_w+s.G_w_conj;
    s.F_retrouve_w=s.k+s.sum_gw;
    s.pw_ideal=pw;
    s.a_ideal=a;
    s.a0=real(s.a_ideal);
    s.a1=imag(s.a_ideal);
  //  l_a0=round(l_a0);    // on arrondit a l'entier le plus proche
    s.l_a0=-log2(s.a0);               
    s.l_a0=round(s.l_a0);
    s.l_a0=max([s.l_a0,0]);
    s.a0= 2^(-s.l_a0);        ;    //on en deduit a0 pour cette valeur de s.l_a0
  //  l_a1=round(l_a1);    // on arrondit a l'entier le plus proche
    s.l_a1=-log2(s.a1);               
    s.l_a1=round(s.l_a1);
    s.l_a1=max([s.l_a1,0]);
    s.a1= 2^(-s.l_a1);        ;    //on en deduit a1 pour cette valeur de s.l_a1
    s.a=s.a0+%i*s.a1; 
    s.pw=clc_pw_op_re_im_v2(s.a);
   // determination operateur en w
    s.op_de_w=(1-w)/(1-w/s.pw)  ;
    s.w_de_op=-(op-1)*s.pw/(s.pw-op);// w =f(op)= fraction rationnelle en op
  //-------------------------------------------------------
  // normalisation du gain k en parallele, k=1 ou k=0
  //-------------------------------------------------------
    if (abs(s.k)>1e-12) then
      k_norm=s.k;
    else
      k_norm=1;
    end
    s.k_norm=k_norm;
    s.k=s.k/s.k_norm;
    s.G_w=(numer(s.G_w)/k_norm)/denom(s.G_w);
// determination de G_op = expression du filtre = G(op)
   [n0_gop,n1_gop,d0_gop,d1_gop]=clc_Gop_op_re_im_v2(s.G_w,s.pw)
    s.G_op=(n0_gop+n1_gop*op)/(d0_gop+d1_gop*op);
    s.d1=d1_gop;
    s.n0=n0_gop;
    s.n1=n1_gop; 
  // calcul transferts en z
    [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(s.n0,s.n1,s.d1,s.a);
    s.tf_z=tf_z;
    s.tf_z_1=tf_z_1;
    s.tf_w=tf_w;
  endfunction
  function [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(n0,n1,d1,a)
  // calcul transferts en z
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_re_im_v2(n0,n1,d1,a);
    tf_z.F_e_s=F_e_s;
    tf_z.F_e_x=F_e_x;
    tf_z.F_b_s=F_b_s;
    tf_z.F_b_x=F_b_x;
    tf_z.d_common=d_common;
  // calcul transferts en w
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_re_im_v2(n0,n1,d1,a);
    tf_w.F_e_s=F_e_s;
    tf_w.F_e_x=F_e_x;
    tf_w.F_b_s=F_b_s;
    tf_w.F_b_x=F_b_x;
    tf_w.d_common=d_common;
  // calcul transferts en z_1
    [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_re_im_v2(n0,n1,d1,a);
    tf_z_1.F_e_s=F_e_s;
    tf_z_1.F_e_x=F_e_x;
    tf_z_1.F_b_s=F_b_s;
    tf_z_1.F_b_x=F_b_x;
    tf_z_1.d_common=d_common;
  endfunction
  function fcts_op_2d()
  endfunction
  function op_de_w=clc_op_de_w_op_2d_2(vop) 
    w=poly(0,'w'); 
      op_de_w = (1-w)/(w/vop+1)
  endfunction 
  function w_de_op=clc_w_de_op_op_2d_2(vop) 
    op=poly(0,'op'); 
      w_de_op = -(op-1)*vop/(vop+op)
  endfunction 
  function [n0_fop,n1_fop,n2_fop,d0_fop,d1_fop,d2_fop].. 
  =clc_Fop_op_2d_2(F_w,vop) 
    n0_fw=coeff(numer(F_w),0); 
    n1_fw=coeff(numer(F_w),1); 
    n2_fw=coeff(numer(F_w),2); 
    d0_fw=coeff(denom(F_w),0); 
    d1_fw=coeff(denom(F_w),1); 
    d2_fw=coeff(denom(F_w),2); 
      n0_fop = (n2_fw+n1_fw+n0_fw)/(d2_fw+d1_fw+d0_fw)
      n1_fop = -(2*n2_fw*vop+n1_fw*vop-n1_fw-2*n0_fw)/((d2_fw+d1_fw+d0_fw)..
        *vop)
      n2_fop = (n2_fw*vop^2-n1_fw*vop+n0_fw)/((d2_fw+d1_fw+d0_fw)..
        *vop^2)
      d0_fop = 1
      d1_fop = -(2*d2_fw*vop+d1_fw*vop-d1_fw-2*d0_fw)/((d2_fw+d1_fw+d0_fw)..
        *vop)
      d2_fop = (d2_fw*vop^2-d1_fw*vop+d0_fw)/((d2_fw+d1_fw+d0_fw)..
        *vop^2)
    if d2_fw==0 then 
      d2_fop=0;n2_fop=0; 
      if d1_fw==0 then 
        d1_fop=0;n1_fop=0; 
      end 
    end 
  endfunction 
  function vop=clc_vop_op_2d_2(a) 
      vop = -a/(a-2)
  endfunction 
  function a=clc_a_op_2d_2(vop) 
      a = 2*vop/(vop+1)
  endfunction 
  function s=mul_cel_op_2d_by_K(cel,K) 
        cel.n0=K*cel.n0;
        cel.n1=K*cel.n1;
        cel.n2=K*cel.n2;
      // calcul transferts en z
        [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(cel.n0,cel.n1,cel.n2,cel.d0,cel.d1,cel.d2,cel.a);
        cel.tf_z=tf_z;
        cel.tf_z_1=tf_z_1;
        cel.tf_w=tf_w;
        s=cel;
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_z_op_2d_2(n0,n1,n2,d0,d1,d2,a) 
    z=poly(0,'z') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    F_b_x(3)=list() 
    n0op=n0;n1op=n1;n2op=n2; 
    d0op=d0;d1op=d1;d2op=d2; 
      d_0_z = a^2*d2op+a^2*d1op-a*d1op+a^2-2*a+1
      d_1_z = a*d1op+2*a-2
      d_2_z = 1
      d_common = d_2_z*z^2+d_1_z*z+d_0_z
    cn=d_0_z 
    d_common=d_common/cn 
      n0_z = a^2*n2op+a^2*n1op-a*n1op+a^2*n0op-2*a*n0op+n0op
      n1_z = a*n1op+2*a*n0op-2*n0op
      n2_z = n0op
     F_e_s=((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = (a-1)^2
      n1_z = 2*(a-1)
      n2_z = 1
     F_e_x(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = (a-1)*a
      n1_z = a
      n2_z = 0
     F_e_x(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = a^2
      n1_z = 0
      n2_z = 0
     F_e_x(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = (a-1)^2
      n1_z = 2*(a-1)
      n2_z = 1
     F_b_x(1)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = (a-1)*a
      n1_z = a
      n2_z = 0
     F_b_x(2)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = a^2
      n1_z = 0
      n2_z = 0
     F_b_x(3)(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = a^2*n2op+a^2*n1op-a*n1op+a^2*n0op-2*a*n0op+n0op
      n1_z = a*n1op+2*a*n0op-2*n0op
      n2_z = n0op
     F_b_s(1) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = a*d2op+a*d1op-d1op
      n1_z = -(a*d2op+a*d1op-2*d1op)
      n2_z = -d1op
     F_b_x(1)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(a-1)
      n1_z = a-2
      n2_z = 1
     F_b_x(2)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -a
      n1_z = a
      n2_z = 0
     F_b_x(3)(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(a*n2op+a*n1op-n1op-a*d2op*n0op-a*d1op*n0op+d1op*n0op)
      n1_z = a*n2op+a*n1op-2*n1op-a*d2op*n0op-a*d1op*n0op+2*d1op*n0op
      n2_z = n1op-d1op*n0op
     F_b_s(2) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = (a-1)*d2op
      n1_z = -(a-2)*d2op
      n2_z = -d2op
     F_b_x(1)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = a*d2op
      n1_z = -a*d2op
      n2_z = 0
     F_b_x(2)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(a*d1op+a-1)
      n1_z = a*d1op+a-2
      n2_z = 1
     F_b_x(3)(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
      n0_z = -(a*d1op*n2op+a*n2op-n2op-a*d2op*n1op-a*d2op*n0op+d2op..
        *n0op)
      n1_z = a*d1op*n2op+a*n2op-2*n2op-a*d2op*n1op-a*d2op*n0op+2*d2op..
        *n0op
      n2_z = n2op-d2op*n0op
     F_b_s(3) =((n0_z+n1_z*z+n2_z*z^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_z_1_op_2d_2(n0,n1,n2,d0,d1,d2,a) 
    z_1=poly(0,'z_1') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    F_b_x(3)=list() 
    n0op=n0;n1op=n1;n2op=n2; 
    d0op=d0;d1op=d1;d2op=d2; 
      d_0_z_1 = 1
      d_1_z_1 = a*d1op+2*a-2
      d_2_z_1 = a^2*d2op+a^2*d1op-a*d1op+a^2-2*a+1
      d_common = d_2_z_1*z_1^2+d_1_z_1*z_1+d_0_z_1
    cn=d_0_z_1 
    d_common=d_common/cn 
      n0_z_1 = n0op
      n1_z_1 = a*n1op+2*a*n0op-2*n0op
      n2_z_1 = a^2*n2op+a^2*n1op-a*n1op+a^2*n0op-2*a*n0op+n0op
     F_e_s=((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = 2*(a-1)
      n2_z_1 = (a-1)^2
     F_e_x(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = a
      n2_z_1 = (a-1)*a
     F_e_x(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = 0
      n2_z_1 = a^2
     F_e_x(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = 2*(a-1)
      n2_z_1 = (a-1)^2
     F_b_x(1)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = a
      n2_z_1 = (a-1)*a
     F_b_x(2)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = 0
      n2_z_1 = a^2
     F_b_x(3)(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = n0op
      n1_z_1 = a*n1op+2*a*n0op-2*n0op
      n2_z_1 = a^2*n2op+a^2*n1op-a*n1op+a^2*n0op-2*a*n0op+n0op
     F_b_s(1) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = -d1op
      n1_z_1 = -(a*d2op+a*d1op-2*d1op)
      n2_z_1 = a*d2op+a*d1op-d1op
     F_b_x(1)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = a-2
      n2_z_1 = -(a-1)
     F_b_x(2)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = a
      n2_z_1 = -a
     F_b_x(3)(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = n1op-d1op*n0op
      n1_z_1 = a*n2op+a*n1op-2*n1op-a*d2op*n0op-a*d1op*n0op+2*d1op..
        *n0op
      n2_z_1 = -(a*n2op+a*n1op-n1op-a*d2op*n0op-a*d1op*n0op+d1op*n0op)
     F_b_s(2) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = -d2op
      n1_z_1 = -(a-2)*d2op
      n2_z_1 = (a-1)*d2op
     F_b_x(1)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = -a*d2op
      n2_z_1 = a*d2op
     F_b_x(2)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = a*d1op+a-2
      n2_z_1 = -(a*d1op+a-1)
     F_b_x(3)(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
      n0_z_1 = n2op-d2op*n0op
      n1_z_1 = a*d1op*n2op+a*n2op-2*n2op-a*d2op*n1op-a*d2op*n0op+2*d2op..
        *n0op
      n2_z_1 = -(a*d1op*n2op+a*n2op-n2op-a*d2op*n1op-a*d2op*n0op+d2op..
        *n0op)
     F_b_s(3) =((n0_z_1+n1_z_1*z_1+n2_z_1*z_1^2)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_w_op_2d_2(n0,n1,n2,d0,d1,d2,a) 
    w=poly(0,'w') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    F_b_x(3)=list() 
    n0op=n0;n1op=n1;n2op=n2; 
    d0op=d0;d1op=d1;d2op=d2; 
      d_0_w = a^2*(d2op+d1op+1)
      d_1_w = -2*a*(a*d2op+a*d1op-d1op+a-2)
      d_2_w = a^2*d2op+a^2*d1op-2*a*d1op+a^2-4*a+4
      d_common = d_2_w*w^2+d_1_w*w+d_0_w
    cn=d_0_w 
    d_common=d_common/cn 
      n0_w = a^2*(n2op+n1op+n0op)
      n1_w = -2*a*(a*n2op+a*n1op-n1op+a*n0op-2*n0op)
      n2_w = a^2*n2op+a^2*n1op-2*a*n1op+a^2*n0op-4*a*n0op+4*n0op
     F_e_s=((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*(a-2)*a
      n2_w = (a-2)^2
     F_e_x(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*(a-1)*a
      n2_w = (a-2)*a
     F_e_x(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*a^2
      n2_w = a^2
     F_e_x(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*(a-2)*a
      n2_w = (a-2)^2
     F_b_x(1)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*(a-1)*a
      n2_w = (a-2)*a
     F_b_x(2)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2
      n1_w = -2*a^2
      n2_w = a^2
     F_b_x(3)(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = a^2*(n2op+n1op+n0op)
      n1_w = -2*a*(a*n2op+a*n1op-n1op+a*n0op-2*n0op)
      n2_w = a^2*n2op+a^2*n1op-2*a*n1op+a^2*n0op-4*a*n0op+4*n0op
     F_b_s(1) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = -2*a*(d2op+d1op)
      n2_w = 2*(a*d2op+a*d1op-2*d1op)
     F_b_x(1)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*a
      n2_w = -2*(a-2)
     F_b_x(2)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*a
      n2_w = -2*a
     F_b_x(3)(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*a*(n2op+n1op-d2op*n0op-d1op*n0op)
      n2_w = -2*(a*n2op+a*n1op-2*n1op-a*d2op*n0op-a*d1op*n0op+2*d1op..
        *n0op)
     F_b_s(2) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = -2*a*d2op
      n2_w = 2*(a-2)*d2op
     F_b_x(1)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = -2*a*d2op
      n2_w = 2*a*d2op
     F_b_x(2)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*a*(d1op+1)
      n2_w = -2*(a*d1op+a-2)
     F_b_x(3)(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
      n0_w = 0
      n1_w = 2*a*(d1op*n2op+n2op-d2op*n1op-d2op*n0op)
      n2_w = -2*(a*d1op*n2op+a*n2op-2*n2op-a*d2op*n1op-a*d2op*n0op+2*d2op..
        *n0op)
     F_b_s(3) =((n0_w+n1_w*w+n2_w*w^2)/cn)/d_common 
  endfunction 
  function op_de_w=clc_op_de_w_op_2d_1(vop) 
    w=poly(0,'w'); 
      op_de_w = (1-w)/(w/vop+1)
  endfunction 
  function w_de_op=clc_w_de_op_op_2d_1(vop) 
    op=poly(0,'op'); 
      w_de_op = -(op-1)*vop/(vop+op)
  endfunction 
  function [n0_fop,n1_fop,d0_fop,d1_fop].. 
  =clc_Fop_op_2d_1(F_w,vop) 
    n0_fw=coeff(numer(F_w),0); 
    n1_fw=coeff(numer(F_w),1); 
    d0_fw=coeff(denom(F_w),0); 
    d1_fw=coeff(denom(F_w),1); 
      n0_fop = (n1_fw+n0_fw)/(d1_fw+d0_fw)
      n1_fop = -(n1_fw*vop-n0_fw)/((d1_fw+d0_fw)*vop)
      d0_fop = 1
      d1_fop = -(d1_fw*vop-d0_fw)/((d1_fw+d0_fw)*vop)
  endfunction 
  function vop=clc_vop_op_2d_1(a) 
      vop = -a/(a-2)
  endfunction 
  function a=clc_a_op_2d_1(vop) 
      a = 2*vop/(vop+1)
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_z_op_2d_1(n0,n1,d0,d1,a) 
    z=poly(0,'z') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    n0op=n0;n1op=n1; 
    d0op=d0;d1op=d1; 
      d_0_z = a*d1op+a-1
      d_1_z = 1
      d_common = d_1_z*z+d_0_z
    cn=d_0_z 
    d_common=d_common/cn 
      n0_z = a*n1op+a*n0op-n0op
      n1_z = n0op
     F_e_s=((n0_z+n1_z*z)/cn)/d_common 
      n0_z = a-1
      n1_z = 1
     F_e_x(1) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = a
      n1_z = 0
     F_e_x(2) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = a-1
      n1_z = 1
     F_b_x(1)(1) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = a
      n1_z = 0
     F_b_x(2)(1) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = a*n1op+a*n0op-n0op
      n1_z = n0op
     F_b_s(1) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = d1op
      n1_z = -d1op
     F_b_x(1)(2) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = -1
      n1_z = 1
     F_b_x(2)(2) =((n0_z+n1_z*z)/cn)/d_common 
      n0_z = -(n1op-d1op*n0op)
      n1_z = n1op-d1op*n0op
     F_b_s(2) =((n0_z+n1_z*z)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_z_1_op_2d_1(n0,n1,d0,d1,a) 
    z_1=poly(0,'z_1') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    n0op=n0;n1op=n1; 
    d0op=d0;d1op=d1; 
      d_0_z_1 = 1
      d_1_z_1 = a*d1op+a-1
      d_common = d_1_z_1*z_1+d_0_z_1
    cn=d_0_z_1 
    d_common=d_common/cn 
      n0_z_1 = n0op
      n1_z_1 = a*n1op+a*n0op-n0op
     F_e_s=((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = a-1
     F_e_x(1) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = a
     F_e_x(2) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = a-1
     F_b_x(1)(1) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = 0
      n1_z_1 = a
     F_b_x(2)(1) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = n0op
      n1_z_1 = a*n1op+a*n0op-n0op
     F_b_s(1) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = -d1op
      n1_z_1 = d1op
     F_b_x(1)(2) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = 1
      n1_z_1 = -1
     F_b_x(2)(2) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
      n0_z_1 = n1op-d1op*n0op
      n1_z_1 = -(n1op-d1op*n0op)
     F_b_s(2) =((n0_z_1+n1_z_1*z_1)/cn)/d_common 
  endfunction 
  function [F_e_s,F_e_x,F_b_s,F_b_x,d_common].. 
  =clc_trf_w_op_2d_1(n0,n1,d0,d1,a) 
    w=poly(0,'w') 
    F_e_x=list() 
    F_b_s=list() 
    F_b_x=list() 
    F_b_x(1)=list() 
    F_b_x(2)=list() 
    n0op=n0;n1op=n1; 
    d0op=d0;d1op=d1; 
      d_0_w = -a*(d1op+1)
      d_1_w = a*d1op+a-2
      d_common = d_1_w*w+d_0_w
    cn=d_0_w 
    d_common=d_common/cn 
      n0_w = -a*(n1op+n0op)
      n1_w = a*n1op+a*n0op-2*n0op
     F_e_s=((n0_w+n1_w*w)/cn)/d_common 
      n0_w = -a
      n1_w = a-2
     F_e_x(1) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = -a
      n1_w = a
     F_e_x(2) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = -a
      n1_w = a-2
     F_b_x(1)(1) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = -a
      n1_w = a
     F_b_x(2)(1) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = -a*(n1op+n0op)
      n1_w = a*n1op+a*n0op-2*n0op
     F_b_s(1) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = 0
      n1_w = 2*d1op
     F_b_x(1)(2) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = 0
      n1_w = -2
     F_b_x(2)(2) =((n0_w+n1_w*w)/cn)/d_common 
      n0_w = 0
      n1_w = -2*(n1op-d1op*n0op)
     F_b_s(2) =((n0_w+n1_w*w)/cn)/d_common 
  endfunction 
    function [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(n0,n1,n2,d0,d1,d2,a)
      old_simp_mode=simp_mode();
      simp_mode(%f);
  // calcul transferts en z
    if (d2==0) then  
       
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_2d_1(n0,n1,d0,d1,a);
    else
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_op_2d_2(n0,n1,n2,d0,d1,d2,a);
    end 
    tf_z.F_e_s=F_e_s;
    tf_z.F_e_x=F_e_x;
    tf_z.F_b_s=F_b_s;
    tf_z.F_b_x=F_b_x;
    tf_z.d_common=d_common;
  // calcul transferts en w
    if (d2==0) then  
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_2d_1(n0,n1,d0,d1,a);
    else
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_w_op_2d_2(n0,n1,n2,d0,d1,d2,a);
    end 
    tf_w.F_e_s=F_e_s;
    tf_w.F_e_x=F_e_x;
    tf_w.F_b_s=F_b_s;
    tf_w.F_b_x=F_b_x;
    tf_w.d_common=d_common;
  // calcul transferts en z_1
    if (d2==0) then  
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_2d_1(n0,n1,d0,d1,a);
    else
      [F_e_s,F_e_x,F_b_s,F_b_x,d_common]=clc_trf_z_1_op_2d_2(n0,n1,n2,d0,d1,d2,a);
    end 
    tf_z_1.F_e_s=F_e_s;
    tf_z_1.F_e_x=F_e_x;
    tf_z_1.F_b_s=F_b_s;
    tf_z_1.F_b_x=F_b_x;
    tf_z_1.d_common=d_common;
    simp_mode(old_simp_mode);
  endfunction
  function s=qtf_cel_op_2d(cel,NB_BITS)
    cel.n0_qtf = qtf_coeff(cel.n0,NB_BITS);
    cel.n1_qtf = qtf_coeff(cel.n1,NB_BITS);
    cel.n2_qtf = qtf_coeff(cel.n2,NB_BITS);
    cel.d1_qtf = qtf_coeff(cel.d1,NB_BITS);
    cel.d2_qtf = qtf_coeff(cel.d2,NB_BITS);
    cel.n0_q=cel.n0_qtf.coeff_quantifie;
    cel.n1_q=cel.n1_qtf.coeff_quantifie;
    cel.n2_q=cel.n2_qtf.coeff_quantifie;
    cel.d1_q=cel.d1_qtf.coeff_quantifie;
    cel.d2_q=cel.d2_qtf.coeff_quantifie;
  // calcul plus petit decalage numerateur cellule i_f
    Lmin=[];
    if (cel.n0_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.n0_qtf.L];
    end
    if (cel.n1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.n1_qtf.L];
    end
    if (cel.n2_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.n2_qtf.L];
    end

    Lmin=min(Lmin);
    cel.L_min_num=Lmin;
    Lmin=[];
    if (cel.d1_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.d1_qtf.L];
    end
    if (cel.d2_qtf.coeff_entier~=0) then
      Lmin=[Lmin,cel.d2_qtf.L];
    end
    Lmin=min(Lmin);
    cel.L_min_den=Lmin;
    s=cel;
  // calcul des transferts quantifies en z,z^-1 et w
    [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(s.n0_q,s.n1_q,s.n2_q,s.d0,s.d1_q,s.d2_q,s.a);
    s.tf_z_qtf=tf_z;
    s.tf_z_1_qtf=tf_z_1;
    s.tf_w_qtf=tf_w;

  endfunction
  function s=clc_op_2d(F_w)
    s.F_w=F_w;
    d2_w=coeff(denom(F_w),2);
    if (d2_w==0) then
      s.order=1;
    else
      s.order=2;
    end
    w=poly(0,'w');
    z=poly(0,'z');
    z_1=poly(0,'z_1');
    w_de_z=(z-1)/(z+1);
    z_de_w=(1+w)/(1-w);
    s.type_cel='op_2d';
    pw=roots( denom(F_w) );
    vop_ideal=min(abs(pw));
    a_ideal=clc_a_op_2d_2(vop_ideal);
    s.vop_ideal=vop_ideal;
    s.a_ideal=a_ideal;
    s.a=real(s.a_ideal);
 // on arrondit a l'entier le plus proche
    if (switch_op_equal_z_1==%t) then
      s.l_a=0;
    else
      s.l_a=-log2(s.a);
    end
    s.l_a=round(s.l_a);
    s.l_a=max([s.l_a,0]);
    s.a= 2^(-s.l_a);        ;    //on en deduit a pour cette valeur de s.l_a
    s.vop=clc_vop_op_2d_2(s.a);
   // determination operateur en w
    s.op_de_w=clc_op_de_w_op_2d_2(s.vop);
    s.w_de_op=clc_w_de_op_op_2d_2(s.vop);// w =f(op)= fraction rationnelle en op
  //-------------------------------------------------------
  // normalisation du gain k en parallele, k=1 ou k=0
  //-------------------------------------------------------
// determination de F_op = expression du filtre = F(op)
   if (s.order==2) then 
     [n0_fop,n1_fop,n2_fop,d0_fop,d1_fop,d2_fop]=clc_Fop_op_2d_2(s.F_w,s.vop) 
   else
     [n0_fop,n1_fop,d0_fop,d1_fop]=clc_Fop_op_2d_1(s.F_w,s.vop)
     n2_fop=0;d2_fop=0;
   end
 // normalisation par rapport au coeff num le plus grand en op 
    tmp=[n0_fop,n1_fop,n2_fop];
    [tmp1,i_max]=max(abs(tmp));
    s.k=tmp(i_max);
    // s.k=n0_fop; pour normalisation / coeff de plus bas degre en op
    if (abs(s.k)>1e-12) then
      k_norm=s.k;
    else
      k_norm=1;
    end
    s.k_norm=k_norm;
    s.k=s.k/s.k_norm;
    n0_fop=n0_fop/s.k_norm;
    n1_fop=n1_fop/s.k_norm;
    n2_fop=n2_fop/s.k_norm;
    s.F_op=(n0_fop+n1_fop*op+n2_fop*op^2)/(d0_fop+d1_fop*op+d2_fop*op^2);
    s.n0=n0_fop;
    s.n1=n1_fop;
    s.n2=n2_fop;
    s.d0=d0_fop;
    s.d1=d1_fop;
    s.d2=d2_fop;
  // calcul transferts en z
    [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(s.n0,s.n1,s.n2,s.d0,s.d1,s.d2,s.a);
    s.tf_z=tf_z;
    s.tf_z_1=tf_z_1;
    s.tf_w=tf_w;
  endfunction
  function fcts_filter()
    disp('');

  endfunction 
  function s=qtf_cel(cel)
    if cel.type_cel=='op_re_im' then
      s=qtf_cel_op_re_im(cel);
      return 
    end
    if cel.type_cel=='op_2d' then
      s=qtf_cel_op_2d(cel);
      return 
    end
    if cel.type_cel=='op_re_im_v2' then
      s=qtf_cel_op_re_im_v2(cel);
      return 
    end
    error('qtf_cel not yet implemented for this case');
  endfunction
  function s=re_quantifie_coeffs_num(cel,Lmin)
    if (cel.type_cel=='op_re_im') then
      cel.re_n1_qtf=re_quantifie_coeff(cel.re_n1_qtf,Lmin);
      cel.im_n1_qtf=im_quantifie_coeff(cel.im_n1_qtf,Lmin);
      cel.n1_q=cel.re_n1_qtf.coeff_quantifie + %i * cel.im_n1_qtf.coeff_quantifie;
      s=cel; 
      return
    end
    if (cel.type_cel=='op_2d') then
      cel.n0_qtf=re_quantifie_coeff(cel.n0_qtf,Lmin);
      cel.n1_qtf=re_quantifie_coeff(cel.n1_qtf,Lmin);
      cel.n2_qtf=re_quantifie_coeff(cel.n2_qtf,Lmin);
      cel.n0_q=cel.n0_qtf.coeff_quantifie ;
      cel.n1_q=cel.n1_qtf.coeff_quantifie ;
      cel.n2_q=cel.n2_qtf.coeff_quantifie ;
      s=cel; 
      return
    end
    if (cel.type_cel=='op_re_im_v2') then
      cel.re_n0_qtf=re_quantifie_coeff(cel.re_n0_qtf,Lmin);
      cel.im_n0_qtf=im_quantifie_coeff(cel.im_n0_qtf,Lmin);
      cel.n0_q=cel.re_n0_qtf.coeff_quantifie + %i * cel.im_n0_qtf.coeff_quantifie;
      cel.re_n1_qtf=re_quantifie_coeff(cel.re_n1_qtf,Lmin);
      cel.im_n1_qtf=im_quantifie_coeff(cel.im_n1_qtf,Lmin);
      cel.n1_q=cel.re_n1_qtf.coeff_quantifie + %i * cel.im_n1_qtf.coeff_quantifie;
      s=cel; 
      return
    end
    error('re_quantifie_coeffs_num(cel,Lmin) not yet implemented for this case');
  endfunction
  function s=re_quantifie_coeffs_den(cel,Lmin)
    if (cel.type_cel=='op_2d') then
      cel.d1_qtf=re_quantifie_coeff(cel.d1_qtf,Lmin);
      cel.d2_qtf=re_quantifie_coeff(cel.d2_qtf,Lmin);
      cel.d1_q=cel.d1_qtf.coeff_quantifie ;
      cel.d2_q=cel.d2_qtf.coeff_quantifie ;
      s=cel; 
      return
    end
    if (cel.type_cel=='op_re_im') then
      cel.re_d1_qtf=re_quantifie_coeff(cel.re_d1_qtf,Lmin);
      cel.im_d1_qtf=im_quantifie_coeff(cel.im_d1_qtf,Lmin);
      cel.d1_q=cel.re_d1_qtf.coeff_quantifie + %i * cel.im_d1_qtf.coeff_quantifie;
      s=cel; 
      return
    end
    if (cel.type_cel=='op_re_im_v2') then
      cel.re_d1_qtf=re_quantifie_coeff(cel.re_d1_qtf,Lmin);
      cel.im_d1_qtf=im_quantifie_coeff(cel.im_d1_qtf,Lmin);
      cel.d1_q=cel.re_d1_qtf.coeff_quantifie + %i * cel.im_d1_qtf.coeff_quantifie;
      s=cel; 
      return
    end
    error('re_quantifie_coeffs_den(cel,Lmin) not yet implemented for this case');
  endfunction
  function s=clc_cel(F_w)
    pw=roots(denom(F_w));
    rw=real(pw(1));iw=abs(imag(pw(1)));
  // calcul de F(op)
    if (iw >= 0 * abs(rw) ) then
      s=clc_op_2d(F_w);
      return;
    end
    error('clc_cel(F_w) not yet implemented for this case');
  endfunction
  function s=clc_transferts_cel(cel)
   if (cel.type_cel=='op_re_im') then
   // calcul des transferts non quantifies
     s=cel;
     [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(s.k,s.n1,s.d1,s.a);
     s.tf_z=tf_z;
     s.tf_z_1=tf_z_1;
     s.tf_w=tf_w;
   // calcul des transferts quantifies
     [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im(s.k_q,s.n1_q,s.d1_q,s.a);
     s.tf_z_qtf=tf_z;
     s.tf_z_1_qtf=tf_z_1;
     s.tf_w_qtf=tf_w;
     return
   end
   if (cel.type_cel=='op_2d') then
   // calcul des transferts non quantifies
     s=cel;
     [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(s.n0,s.n1,s.n2,s.d0,s.d1,s.d2,s.a)
     s.tf_z=tf_z;
     s.tf_z_1=tf_z_1;
     s.tf_w=tf_w;
   // calcul des transferts quantifies
     [tf_z,tf_z_1,tf_w]=clc_trf_op_2d(s.n0_q,s.n1_q,s.n2_q,s.d0,s.d1_q,s.d2_q,s.a)
     s.tf_z_qtf=tf_z;
     s.tf_z_1_qtf=tf_z_1;
     s.tf_w_qtf=tf_w;
     return
   end
   if (cel.type_cel=='op_re_im_v2') then
   // calcul des transferts non quantifies
     s=cel;
     [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(s.n0,s.n1,s.d1,s.a);
     s.tf_z=tf_z;
     s.tf_z_1=tf_z_1;
     s.tf_w=tf_w;
   // calcul des transferts quantifies
     [tf_z,tf_z_1,tf_w]=clc_trf_op_re_im_v2(s.n0_q,s.n1_q,s.d1_q,s.a);
     s.tf_z_qtf=tf_z;
     s.tf_z_1_qtf=tf_z_1;
     s.tf_w_qtf=tf_w;
     return
   end
   error('clc_transferts_cel not yet implemented for this case');
  endfunction
  function F_w=z_1_2_w(F_z_1)
    w=poly(0,'w');
    z_1_de_w=(1-w)/(1+w);
    F_w=my_horner(F_z_1,z_1_de_w);
    N_w=numer(F_w);
    D_w=denom(F_w);
    cdw=coeff(D_w);
    cdw=cdw(max(size(D_w)));
    F_w=(N_w/cdw)/(D_w/cdw);
  endfunction
  function tf_w=transferts_z_1_2_w(tf_z_1)
    F_e_s_w=z_1_2_w(tf_z_1.F_e_s);
    F_e_x_w=list();
    for i=1:length(tf_z_1.F_e_x),
      F_e_x_w(i)=z_1_2_w(tf_z_1.F_e_x(i)); 
    end
    F_b_s_w=list();
    for i=1:length(tf_z_1.F_b_s),
      F_b_s_w(i)=z_1_2_w(tf_z_1.F_b_s(i)); 
    end
    F_b_x_w=list();
    F_b_x=tf_z_1.F_b_x;
    for i=1:length(F_b_x),
      F_b_x_w_i=list();
      for j=1:length(F_b_x(i))
        F_b_x_w_i(j)=z_1_2_w(F_b_x(i)(j));
      end 
      F_b_x_w(i)=F_b_x_w_i;
    end
    tf_w.d_common=z_1_2_w(tf_z_1.d_common);
    tf_w.F_e_s=F_e_s_w;
    tf_w.F_e_x=F_e_x_w;
    tf_w.F_b_s=F_b_s_w;
    tf_w.F_b_x=F_b_x_w;
  endfunction
  function y=simule_Fz_1(Fz_1,e)
    [m,n]=size(e);
    if (m>n) then
      e=e.';
    end
    if typeof(Fz_1) == 'rational' then
      if (my_degree(numer(Fz_1))==0)&(my_degree(denom(Fz_1))==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=coeff(numer(Fz_1),0)/coeff(denom(Fz_1),0)*e.';
        return 
      end
      Fz=my_horner(Fz_1,1/%z); // F(z) en fonction de F(z^-1)
      Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
      y=flts(e,sys_Fz);// dn=reponse impulsionnelle de F(z)
      y=y.';
      return
    end //    if typeof(Fz_1) == 'rational' then
    if typeof(Fz_1) == 'constant' then
      y=abs(Fz_1); 
      return
    end//    if typeof(Fz_1) == 'constante' then
    if typeof(Fz_1) == 'list' then
      y=e; 
      for i_f=length(Fz_1):-1:1,
        Fz_1i=Fz_1(i_f);
        if typeof(Fz_1i) == 'constant' then
          y=y*Fz_1i; 
        end//    if typeof(Fz_1) == 'constante' then
        if typeof(Fz_1i) == 'rational' then
          if (my_degree(numer(Fz_1i))==0)&(my_degree(denom(Fz_1i))==0) then
          // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
            y=y*coeff(numer(Fz_1i),0)/coeff(denom(Fz_1i),0);
          end
          if (my_degree(numer(Fz_1i))>0)|(my_degree(denom(Fz_1i))>0) then
            Fz=my_horner(Fz_1i,1/%z); // F(z) en fonction de F(z^-1)
            Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
            y=flts(y,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end
        end //    if typeof(Fz_1i) == 'rational' then
      end //for i_f=length(Fz_1):-1:1,
      y=y.'; // norme1 de F(z) = somme (module(f(n))
      return
    end //    if typeof(Fz_1) == 'list' then
    error('type d entree non gere');
  endfunction
  function y=norme1(Fz_1,NBECH_NORME1)
    if (typeof(Fz_1) == 'rational')|(typeof(Fz_1) == 'polynomial') then
      if (my_degree(numer(Fz_1))==0)&(my_degree(denom(Fz_1))==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=abs(coeff(numer(Fz_1),0)/coeff(denom(Fz_1),0));
        return 
      end
      fn=zeros(1,NBECH_NORME1);fn(1)=1; // delta_n=sequence impulsion unite;
      Fz=my_horner(Fz_1,1/%z); // F(z) en fonction de F(z^-1)
      Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
      fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
      y=sum(abs(fn)); // norme1 de F(z) = somme (module(f(n))
      return
    end //    if typeof(Fz_1) == 'rational' then
    if typeof(Fz_1) == 'constant' then
      y=abs(Fz_1); 
      return
    end//    if typeof(Fz_1) == 'constante' then
    if typeof(Fz_1) == 'list' then
      fn=zeros(1,NBECH_NORME1);fn(1)=1; // delta_n=sequence impulsion unite;
      for i_f=length(Fz_1):-1:1,
        Fz_1i=Fz_1(i_f);
        if typeof(Fz_1i) == 'constant' then
          fn=fn*Fz_1i; 
        end//    if typeof(Fz_1) == 'constante' then
        if (typeof(Fz_1i) == 'rational')|(typeof(Fz_1i)=='polynomial') then
          if (my_degree(numer(Fz_1i))==0)&(my_degree(denom(Fz_1i))==0) then
          // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
            fn=fn*coeff(numer(Fz_1i),0)/coeff(denom(Fz_1i),0);
          end
          if (my_degree(numer(Fz_1i))>0)|(my_degree(denom(Fz_1i))>0) then
            Fz=my_horner(Fz_1i,1/%z); // F(z) en fonction de F(z^-1)
            Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
            fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end
        end //    if typeof(Fz_1i) == 'rational' then
      end //for i_f=length(Fz_1):-1:1,
      y=sum(abs(fn)); // norme1 de F(z) = somme (module(f(n))
      return
    end //    if typeof(Fz_1) == 'list' then
    error('type d entree non gere');
  endfunction
  function y=norme2(Fz_1,NBECH_NORME1)
    if (typeof(Fz_1) == 'rational')|(typeof(Fz_1) == 'polynomial') then
      if (my_degree(numer(Fz_1))==0)&(my_degree(denom(Fz_1))==0) then
      // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
        y=abs(coeff(numer(Fz_1),0)/coeff(denom(Fz_1),0));
        return 
      end
      fn=zeros(1,NBECH_NORME1);fn(1)=1; // delta_n=sequence impulsion unite;
      Fz=my_horner(Fz_1,1/%z); // F(z) en fonction de F(z^-1)
      Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
      fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
      y=sqrt(sum(abs(fn)^2)); // norme2 de F(z) = sqrt(somme (module(f(n)^2))
      return
    end //    if typeof(Fz_1) == 'rational' then
    if typeof(Fz_1) == 'constant' then
      y=abs(Fz_1); 
      return
    end//    if typeof(Fz_1) == 'constante' then
    if typeof(Fz_1) == 'list' then
      fn=zeros(1,NBECH_NORME1);fn(1)=1; // delta_n=sequence impulsion unite;
      for i_f=length(Fz_1):-1:1,
        Fz_1i=Fz_1(i_f);
        if typeof(Fz_1i) == 'constant' then
          fn=fn*Fz_1i; 
        end//    if typeof(Fz_1) == 'constante' then
        if (typeof(Fz_1i) == 'rational')|(typeof(Fz_1i) == 'polynomial') then
          if (my_degree(numer(Fz_1i))==0)&(my_degree(denom(Fz_1i))==0) then
          // F(z-1) est une constante, on renvoie son module = norme 1 d'une constante
            fn=fn*coeff(numer(Fz_1i),0)/coeff(denom(Fz_1i),0);
          end
          if (my_degree(numer(Fz_1i))>0)|(my_degree(denom(Fz_1i))>0) then
            Fz=my_horner(Fz_1i,1/%z); // F(z) en fonction de F(z^-1)
            Te=1;sys_Fz=syslin(Te,Fz);// conversion en fct de transfert discrete de periode Te=1
            fn=flts(fn,sys_Fz);// dn=reponse impulsionnelle de F(z)
          end
        end //    if typeof(Fz_1i) == 'rational' then
      end //for i_f=length(Fz_1):-1:1,
      y=sqrt(sum(abs(fn)^2)); // norme2 de F(z) = sqrt(somme (module(f(n)^2))
      return
    end //    if typeof(Fz_1) == 'list' then
    error('type d entree non gere');
  endfunction
  function S=qtf_coeff(coeff_reel,NB_BITS)
    plus_grand_entier=round(2^(NB_BITS-1));// plus grand entier codable sur NB_BITS
    abs_coeff_reel=abs(coeff_reel); // module du coefficient reel
    S.coeff_reel=coeff_reel;
    S.coeff_nul=%f;           // vrai => indique un coefficient null
    S.decal_nul=%f;           // vrai => indique un decalage nul
    S.coeff_equal_1=%f;       // vrai => indique un coefficient entier egal a 1
    S.coeff_equal_moins_1=%f; // vrai => indique un coefficient entier egal a -1
  // si le resultat est toujours egal a 0, on degage
    if (abs_coeff_reel==0 ) then
      S.coeff_entier=0;
      S.coeff_quantifie=0;
      S.L=0;
      S.erreur_rel=1;
      S.coeff_nul=%t;           // vrai => indique un coefficient null
      S.decal_nul=%t;           // vrai => indique un decalage nul

      return
    end //if (abs_coeff_reel==0 ) then
    log_2_coeff_reel=log(abs(coeff_reel))/log(2) ;//  log en base 2 du module du coeff_reel
  // ----------------------VOTRE TRAVAIL ICI : A COMPLETER --------------------
    S.L =floor(NB_BITS-1-log_2_coeff_reel) ;         // A FAIRE determiner L en fonction de log_2_coeff_reel et NB_BITS
    S.coeff_entier=round(2^(S.L)*coeff_reel);// A FAIRE determiner coeff_entier en fonction de coeff_reel et S.L
    S.coeff_quantifie=S.coeff_entier*2^(-S.L);    // A FAIRE determiner S.coeff_quantifie en fonction de S.coeff_entier et S.L
    S.erreur_rel=(coeff_reel-S.coeff_quantifie)/coeff_reel;         // A FAIRE determiner S.erreur_rel sur le coeff
  //------------ FIN DE VOTRE TRAVAIL ---------------------------
    if (S.coeff_entier==plus_grand_entier) then
      S.coeff_entier= round(0.5 * S.coeff_entier);
      S.L=S.L-1;
    end //if (S.coeff_entier==plus_grand_entier) then
  //-------------------------------------------------------------
  // tant que le coeff est divisible par 2, 
  // on le divise par 2 et on diminue de 1 le decalage
  //------------------------------------------------------------
    if (S.coeff_quantifie~=0) then // si coeff quantifie different de 0, alors
      Ci=S.coeff_entier;
      L=S.L;
      while ( %f )&( round(Ci/2)*2 == Ci ), // desactive
       Ci=round(Ci/2);L=L-1;
      end //while ( round(Ci/2)*2 == Ci ),
      S.coeff_entier=Ci;
      S.L=L;
    end //if (S.coeff_quantifie~=0) then
    S.coeff_nul=S.coeff_entier==0;           // vrai => indique un coefficient null
    S.decal_nul=S.L==0;           // vrai => indique un decalage nul
    S.coeff_equal_1=S.coeff_entier==1;       // vrai => indique un coefficient entier egal a 1
    S.coeff_equal_moins_1=S.coeff_entier==-1; // vrai => indique un coefficient entier egal a -1
  endfunction
  function new_c_qtf=re_quantifie_coeff(c_qtf,L)
    new_c_qtf=c_qtf;
    if (new_c_qtf.coeff_entier~=0) then
      DeltaL=L-c_qtf.L;
      facteur=round(2^L);
      new_c_qtf.coeff_entier=round(new_c_qtf.coeff_reel*facteur);
      new_c_qtf.coeff_quantifie=round(new_c_qtf.coeff_entier/facteur);
      new_c_qtf.L=L;
    //  new_c_qtf.L_PROG=c_qtf.L_PROG+DeltaL;
    end
  endfunction
  function new_c=minimise_decalage(cf)
      new_c=cf;
    if new_c.coeff_entier==0 then
      return;
    end
    L=new_c.L;LP=new_c.L_PROG;c=new_c.coeff_entier;
    while (LP>0)&( (2*round(c/2)) == c ),
      LP=LP-1;L=L-1;c=round(c/2); 
    end
    new_c.L_PROG=LP;new_c.L=L;new_c.coeff_entier=c;
  endfunction
  function [new_ci,new_L,DELTA_L]=minimise_decalage_commun(ci,L)
    new_ci=ci; new_L=L; DELTA_L=0,
    if max(abs(new_ci))==0 then
      return
    end  
    while (new_L>0)&( max(abs((2*round(new_ci/2)) - new_ci))==0 ),
      DELTA_L=DELTA_L-1;
      new_L=new_L-1;new_ci=round(new_ci/2); 
    end
    new_L=L;
  endfunction
  function F=quantif_filter(F_in)
    F=F_in;
    par=F.params;
ZERO_MINIMAL_W=par.ZERO_MINIMAL_W;
switch_treillis=par.switch_treillis;
sw_handle_last_noise=par.sw_handle_last_noise ;
nom_fichier_aff=par.nom_fichier_aff ;
sw_create_file=par.sw_create_file ;
SEUIL_INSTABILITE=par.SEUIL_INSTABILITE ;
sw_aff_results=par.sw_aff_results ;
switch_trace_freq=par.switch_trace_freq ;
switch_grp_f_reelle=par.switch_grp_f_reelle ;
v_min=par.v_min ;
v_max=par.v_max ;
nb_points=par.nb_points ;
switch_simu_temp=par.switch_simu_temp ;
MAX_E=par.MAX_E ;
FREQ_E_SIMU_TEMP=par.FREQ_E_SIMU_TEMP ;
NBECH_SIMU_TEMP=par.NBECH_SIMU_TEMP ;
NIVEAU_E_SIMU_TEMP=par.NIVEAU_E_SIMU_TEMP ;
switch_genere_code=par.switch_genere_code ;
SUPPRESS_REMARQUES=par.SUPPRESS_REMARQUES ;
NOM_PROGRAMME_EN_C=par.NOM_PROGRAMME_EN_C ;
NAME_FILTER=par.NAME_FILTER ;
sw_norm_num=par.sw_norm_num ;
sw_sort_cels=par.sw_sort_cels ;
sw_noise_shaping=par.sw_noise_shaping ;
switch_force_K_equal_1=par.switch_force_K_equal_1;
switch_op_equal_z_1=par.switch_op_equal_z_1 ;
switch_force_Lo=par.switch_force_Lo ;
Lo_force=par.Lo_force ;
sw_use_L_COMMON=par.sw_use_L_COMMON ;
switch_DEBUG=par.switch_DEBUG ;
sw_sam_scl_n0n1n2=par.sw_sam_scl_n0n1n2 ;
sw_sam_scl_d1d2=par.sw_sam_scl_d1d2 ;
sw_sam_scl_nd=par.sw_sam_scl_nd ;
sw_optim_dcl=par.sw_optim_dcl ;
MAX_BE=par.MAX_BE ;
MAX_BS=par.MAX_BS ;
NB_BITS=par.NB_BITS ;
NBECH_NORME1=par.NBECH_NORME1 ;
    if exists('w')~=1 then
       w=poly(0,'w');
    end
    if exists('z_de_w')~=1 then
       z_de_w=(1+w)/(1-w);
    end
    if exists('z_1')~=1 then
       z_1=poly(0,'z_1');
    end
    if exists('z')~=1 then
       z=poly(0,'z');
    end
    w_de_z_1=(1-z_1)/(1+z_1);
    w_de_z=(z-1)/(z+1);
    z_1_de_w=(1-w)/(1+w);
    z_de_w=(1+w)/(1-w);
    op=poly(0,'op');// op est un polynome...
  //----------------------------------------------------------
  // Calcul F(z^-1) pour info et simus temporelles
  //----------------------------------------------------------
    NB_F=length(F.F_w);
    if (NB_F==0) then
      error('empty filter');
    end
    if (typeof(F.F_w)~='list') then
      l=list();
      [m,n]=size(F.F_w);
      NB_F=m*n;
      i_f=0;
      for i=1:m,
        for j=1:n,
          i_f=i_f+1;
          l(i_f)=F.F_w(i,j);
        end
      end
      F.F_w=l;
    end
    F.F_z_1=list();
    for i_f=1:NB_F,
      F.F_z_1(i_f)=my_horner(F.F_w(i_f),w_de_z_1);
      d0=coeff(denom(F.F_z_1(i_f)),0);
      F.F_z_1(i_f)=(numer(F.F_z_1(i_f))/d0)/(denom(F.F_z_1(i_f))/d0);
  
    end
  //------------------------------------------------------------
  // Calcul de a0
  //------------------------------------------------------------
  // frequence a0 pour calcul de l'operateur
  
    F.a0=list();F.a1=list();
  // a0 = module du plus petit pole / zero de F  
    abs_pw=[];
    for i_f=1:NB_F,
      roots_dw=roots(denom(F.F_w(i_f)));
      zeros_Fw=abs(roots(numer(F.F_w(i_f))));
      abs_poles_Fw=abs(roots_dw);
      rw=min(real(roots_dw));
      iw=max(imag(roots_dw));
    //  abs_poles_Fw=abs(real(roots(denom(F.F_w(i_f)))));
      abs_pwi=[abs_poles_Fw];
      j=find(abs_pwi>ZERO_MINIMAL_W);abs_pwi=min(abs_pwi(j));
      if (abs_pwi==[]) then 
        F.a0(i_f)=1; // utilisation operateur z^-1 pour les gains
        F.a1(i_f)=0;
        abs_pwi=1000;
      else
        F.a0(i_f) = (2*rw^2-2*rw+2*iw^2)/(rw^2-2*rw+iw^2+1);
        F.a1(i_f) = 2*iw/(rw^2-2*rw+iw^2+1);
      end
      abs_pw=[abs_pw;abs_pwi];
    end
    if (sw_sort_cels==%t) then
      [v,i]=gsort(abs_pw);
      a0=list();
      a1=list();
      F_z_1=list();
      F_w=list();
      for j=1:length(i),
        i_f=i(j);
        a0(j)=F.a0(i_f);
        a1(j)=F.a1(i_f);
        F_z_1(j)=F.F_z_1(i_f);
        F_w(j)=F.F_w(i_f);
      end //for j=1:length(i),
      F.a0=a0;
      F.a1=a1;
      F.F_z_1=F_z_1;
      F.F_w=F_w;
    end //if (sw_sort_cels==%t) then
  //---------------------------------------------------------------------------
  // Nombre d'echantillons pour evaluation des norme 1 et 2
  //---------------------------------------------------------------------------
    F.zeros_poles_en_w=[];
    for i_f=1:NB_F,
      zeros_Fw=roots(numer(F.F_w(i_f)));
      poles_Fw=roots(denom(F.F_w(i_f)));
      F.zeros_poles_en_w=[F.zeros_poles_en_w;zeros_Fw;poles_Fw];
    end
    rw=real(F.zeros_poles_en_w);
    j=find((abs(rw)> ZERO_MINIMAL_W )&(abs(rw)<0.95));
    rw=rw(j);
    F.zero_w_le_plus_lent=-min(abs(rw));
    F.zero_z_le_plus_lent=my_horner(z_de_w,F.zero_w_le_plus_lent);
    F.tau_max_echs=-1/log(abs(F.zero_z_le_plus_lent));
    if (par.NBECH_NORME1<=0) then
      NBECH_NORME1=round(10*F.tau_max_echs);
      par.NBECH_NORME1=NBECH_NORME1;
    end
  //---------------------------------------------------------------------------
  // debut programme
  //---------------------------------------------------------------------------
    NB_BITS=par.NB_BITS; 
    MAX_ENTIER_NB_BITS=2^(NB_BITS-1)-1; 
    MAX_ENTIER_2NB_BITS=2^(2*NB_BITS-1)-1;
    MAX_AR=MAX_ENTIER_NB_BITS;
    i_fig=1; // figure pour 1er trace
    F.K=1; // gain global du filtre
    F.cel=list();
    total_order=0;
    for i_f=1:NB_F
    // calcul des cellules elementaires de F(w)
      F.cel(i_f)=clc_cel(F.F_w(i_f));
      celi=F.cel(i_f);
      F.K = F.K * celi.k_norm;
      total_order=total_order+celi.order;
    end // for i_f=1:NB_F
    F.order=total_order;
    if ((switch_force_K_equal_1==%t)&(total_order>0)) then
    // ------------------------------------------------------
    // Repartition du gain K entre les differentes cellules
    // ------------------------------------------------------
      K_elem=(abs(F.K))^(1/total_order);
      for i_f=1:NB_F,
        celi=F.cel(i_f);
        Ki=K_elem^(celi.order);
        F.K=F.K/Ki;
        F.cel(i_f)=mul_cel_op_2d_by_K(celi,Ki);
      end //for i_f=1:NB_F,
      if ((abs(F.K)<0.8)|(abs(F.K)>1.2)) then
        error('too big error when forcing K to unity :K='+string(K));
      end
      err_K=abs(abs(F.K)-1);
      if (err_K>(0.5/MAX_ENTIER_NB_BITS)) then
        celi=F.cel(1);
        F.cel(1)=mul_cel_op_2d_by_K(celi,abs(F.K));
      end
      F.K=1*sign(F.K);
    end //if (switch_force_K_equal_1==%t) then
  // ------------------------------------------------------------
  // QUANTIFICATION DES COEFFICIENTS
  //--------------------------------------------------------------
    F.K_qtf=qtf_coeff(F.K,NB_BITS);
    F.L_min_num_cel_prec=zeros(NB_F+1,1);
    F.L_min_d1d2_cellule=zeros(NB_F,1);
  // quantification des coeffs, passe 1
  // tres mauvaise idee  F.L_min_num_cel_prec(1)=F.K_qtf.L;
    F.L_min_num_cel_prec(1)=2*NB_BITS ;// bien meilleur
    for i_f=1:NB_F,
    // quantification des coeffs en op
      tmp=qtf_cel(F.cel(i_f));F.cel(i_f)=tmp;
      F.L_min_num_cel_prec(i_f+1)=F.cel(i_f).L_min_num;
    end //for i_f=1:NB_F, 
  // quantification des coeffs, passe 2=> alignement eventuel des decalages
    if (sw_sam_scl_n0n1n2==%t)|(sw_sam_scl_d1d2==%t)|(sw_sam_scl_nd==%t) then
    // pour simplifier ecriture et pas d'effet de bord...
      sw_n=sw_sam_scl_n0n1n2;
      sw_d=sw_sam_scl_d1d2;
      sw_nd=sw_sam_scl_nd;
      if sw_nd==%t then
       sw_n=%f;
       sw_d=%f;
      end
      for i_f=1:NB_F,
        if (sw_n==%t) then
        // alignement des decalages coeff numerateur cellule i
          Lmin=F.L_min_num_cel_prec(i_f+1);
          tmp=re_quantifie_coeffs_num(F.cel(i_f),Lmin);F.cel(i_f)=tmp;
        end //if (sw_n==%t)&(i_f<=) then
        if (sw_d==%t) then
          Lmin=F.cel(i_f).L_min_den;
          tmp=re_quantifie_coeffs_den(F.cel(i_f),Lmin);F.cel(i_f)=tmp;
        end //if (sw_d==%t) then
        if (sw_nd==%t) then
        // alignement simultane des decalages denominateur cellule i et numerateur cellule i-1
          Lmin=min([F.L_min_num_cel_prec(i_f);F.cel(i_f).L_min_den]);
          tmp=re_quantifie_coeffs_den(F.cel(i_f),Lmin);F.cel(i_f)=tmp;
       // alignement numerateur precedent
          if (i_f>1) then
            tmp=re_quantifie_coeffs_num(F.cel(i_f-1),Lmin);F.cel(i_f-1)=tmp;
          end // if (i_f>1) then
       // alignement numerateur cellule courante si derniere cellule
          if (i_f==NB_F) then
            Lmin=F.L_min_num_cel_prec(i_f+1);
            tmp=re_quantifie_coeffs_num(F.cel(i_f),Lmin);F.cel(i_f)=tmp;
          end // if (i_f==NB_F) then
        end //if (sw_nd==%t) then
      end //for i_f=1:NB_F,
    end //  if (sw_sam_scl_n0n1n2==%t)|(sw_sam_scl_d1d2==%t)|(sw_sam_scl_nd==%t) then 
  // calcul transferts quantifies
    F.filtre_is_instable =%f;
    for i_f=1:NB_F,
    // calcul des transferts en z , z^-1,w
      tmp=clc_transferts_cel(F.cel(i_f));
      F.cel(i_f)=tmp;
   // verification stabilite
      denom_en_w=numer(F.cel(i_f).tf_w_qtf.d_common);
      if my_degree(denom_en_w)>0 then
         roots_denom_en_w=roots(denom_en_w);
         if max(real(roots_denom_en_w))>=SEUIL_INSTABILITE then
           F.filtre_is_instable =%t;
           disp('ATTENTION :CELLULE '+string(i_f)+' INSTABLE !');
         end
      end
    end // for i_f=1:NB_F
    if (F.filtre_is_instable) then
      disp('FILTRE INSTABLE => CALCUL SCALING IMPOSSIBLE');
    end;
  //---------------------------------------------------------------------
  // trace des reponses frequentielles
  //-----------------------------------------------------------------------
  // 1.1- module reponse frequentielle du numerateur
    if (switch_trace_freq==%t) then
      if exists('switch_grp_f_reelle')~=1 then
        switch_grp_f_reelle=%f;
      end
      [n,m]=size(v_aff);
      if n<m then
        v_aff=v_aff.'; // on le transpose
      end
      if (switch_grp_f_reelle==%t) then
        x_f=Fe/%pi*atan(v_aff);
        mode_f='nn';
        mode_f2='nn';
      else
        x_f=v_aff;
        mode_f='ln';
        mode_f2='ln';
      end 
      rep_glob=ones(v_aff)*F.K_qtf.coeff_reel;    // reponse frequentielle globale
      rep_qtf_glob=ones(v_aff)*F.K_qtf.coeff_quantifie;// reponse frequentielle quantifiee globale
      for i_f=1:NB_F,
      // reponse frequentielle N/D
        rep_ND    =my_horner(F.cel(i_f).tf_w.F_e_s     ,%i*v_aff) ; 
        rep_ND_qtf=my_horner(F.cel(i_f).tf_w_qtf.F_e_s ,%i*v_aff) ; 
        // rep_ND    =my_horner(F.F_w(i_f),%i*v_aff); 
        rep_glob     =rep_glob     .* rep_ND    ;
        rep_qtf_glob =rep_qtf_glob .* rep_ND_qtf;
      end // for i_f
    // trace module et erreur filtre global
      module_glob=abs(rep_glob);
      arg_glob=imag(log(rep_glob))*180/%pi;
      module_qtf_glob=abs(rep_qtf_glob);
      arg_qtf_glob=imag(log(rep_qtf_glob))*180/%pi;
      module_delta_glob=abs(rep_glob-rep_qtf_glob); // module de l'ecart entre rep. ideale et quantifiee
      xset('window',i_fig);clf(i_fig,"reset");;i_fig=i_fig+1;
    // trace en echelle loglog sur figure 1, en haut, du num , num quantifie, et delta_num
        M=[module_glob,module_qtf_glob,module_delta_glob];      max_M=max(max(M));i=find(M<max_M*1e-30);M(i)=1e-20*max_M*ones(M(i));
        
      subplot(2,1,1);plot2d(mode_f,x_f,20*log10(M),[1,-2,-4]);
      F.err_max_db=20*log10(max(module_delta_glob./module_glob));
      xtitle(': |F(jv)| (continu), |Fq(jv)|(croix), erreur (Losanges), ERR REL MAX(db)='+string(F.err_max_db));
      subplot(2,1,2);plot2d(mode_f2,x_f,[arg_glob,arg_qtf_glob],[1,-2,-4]);
      err_max_deg=max(abs(arg_qtf_glob-arg_glob));
      xtitle('Arg(F(jv)) (continu), arg(Fq(jv))(croix), erreur (Losanges), Erreur max(degres)='+string(err_max_deg));
      xselect(); 
    end // if switch_trace_freq
  //---------------------------------------------------------------------
  // calcul du plus grand facteur d'echelle utilisable e l'entree du filtre
  // et de l'erreur max en sortie du filtre, due aux bruits
  //-----------------------------------------------------------------------
  // calcul des niveaux de signaux sur la variable ar
  // valeur maxi de la partie ar, due a l'entree
    entree=list();
    F.log2_lambda=zeros(NB_F+1,1);
    F.max_s=zeros(NB_F+1,1);F.max_s_e=zeros(NB_F+1,1);F.max_s_b=zeros(NB_F+1,1);
    F.pow_s=zeros(NB_F+1,1);F.pow_s_b=zeros(NB_F+1,1);F.pow_s_e=zeros(NB_F+1,1);
    tmp.max_value=MAX_E;
    tmp.transfert=list();tmp.transfert(1)=F.K_qtf.coeff_entier;
    entree(1)=tmp; 
    F.no_lambda=F.filtre_is_instable;
    if F.no_lambda==%f then
      for i_f=1:NB_F,
        celi=F.cel(i_f);
        celi.max_x_b=[];
        celi.max_x_e=[];
        celi.max_x=[];
        fz_1=celi.tf_z_1_qtf;
        nb_bruits=length(fz_1.F_b_s);
        nb_x=length(fz_1.F_e_x);
        F_e_s=fz_1.F_e_s;
        scale_x=list();
        lbd_celi=[] ;
        for i_x=1:nb_x,
        // max variable rx 
          F_e_xi=fz_1.F_e_x(i_x);
        // calcul max variable xi due aux entrees precedentes
          max_xi_e=0;
          for i_e=1:length(entree),
            e=entree(i_e);
            T_e=e.transfert ;
            mx_e=e.max_value;
            T_e_xi=T_e;T_e_xi(length(T_e_xi)+1)=F_e_xi; 
            max_xi_e=max_xi_e+norme1(T_e_xi,NBECH_NORME1)*mx_e;
          end // for i_e 
        // calcul max variable xi due aux bruits internes
          F_b_xi=fz_1.F_b_x(i_x);
          nb_bruits=length(F_b_xi);
          max_xi_b=0;
          for i_b=1:nb_bruits,
            if (sw_noise_shaping==%t)&(i_b==1) then
              F_bi_xi= list() ; 
              celi.k1_noise_shaping=round(coeff(denom(F_b_xi(i_b)),1)); 
              celi.k2_noise_shaping=round(coeff(denom(F_b_xi(i_b)),2)); 
            //  celi.k1_noise_shaping=-1; 
            //  celi.k2_noise_shaping=0; 
              F_bi_xi(1)= (1+ celi.k1_noise_shaping * z_1 +  celi.k2_noise_shaping * z_1^2) ; 
              F_bi_xi(2)= F_b_xi(i_b);
            else
              F_bi_xi=F_b_xi(i_b);
            end
            max_xi_b=max_xi_b+norme1(F_bi_xi,NBECH_NORME1)*MAX_BE;
          end
        // si on emploie un facteur d'echelle lambda_xi, il faut que lambda_xi.max_xi_e+max_xi_b<2^NBITS-1
          max_xi_avt=max_xi_b+max_xi_e; 
          lambda_xi=(MAX_AR-max_xi_b)/max_xi_e;
          if (lambda_xi<0) then 
            disp('IMPOSSIBLE DE TROUVER SCALING lambda_x('+string(i_x)+') POUR CELLULE '+string);
            disp('CAR BRUIT INTERNE PRODUIT MAX ReX(BRUIT) ='+string(max_x_b)+ '> 2^(NB_BITS-1)-1 = '+string(MAX_AR));
            disp('ET MAX X(BRUIT INTERNE) NE DEPEND PAS DE SCALING LAMBDA!...');
            no_lambda=%t;
            lambda_xi=1;// abandon des scalings
          end
          log2_lambda_xi=floor(log(lambda_xi)/log(2));
          lambda_xi=2^(log2_lambda_xi);
          max_xi_with_lambda_xi=max_xi_b+lambda_xi*max_xi_e;
          max_xi=max_xi_with_lambda_xi;
          scale_i.lambda=lambda_xi;
          scale_i.log2_lambda=log2_lambda_xi;
          scale_i.max_x_b=max_xi_b;
          scale_i.max_x_e_without_lbd=max_xi_e;
          scale_i.max_x_with_lbd=max_xi_b+lambda_xi*max_xi_e;
          scale_i.max_x_e=lambda_xi*max_xi_e;
          celi.max_x_e=max([celi.max_x_e,scale_i.max_x_e]);
          celi.max_x_b=max([celi.max_x_b,scale_i.max_x_b]);
          celi.max_x=max([celi.max_x,scale_i.max_x_with_lbd]);
          scale_x(i_x)=scale_i;
          lbd_celi=[lbd_celi,lambda_xi];
        end // for i_x=1:nb_x,
        celi.scale_x=scale_x;  
      // mise a jour des transfert entrees prec. ->sortie, en tenant compte de lambda_rx
        lambda=min(lbd_celi);
        log2_lambda=round(log(lambda)/log(2));
        celi.lambda=lambda;  
        celi.log2_lambda=log2_lambda;
        for i_e=1:length(entree),
          e=entree(i_e);
          T_e_s=e.transfert;T_e_s(length(T_e_s)+1)= lambda * F_e_s;
          entree(i_e).transfert=T_e_s;
        end // for i_e 
       // calcul max variable s due a l'entree 
        max_s_e=0;pow_s_e=0;
        for i_e=1:1,
          e=entree(i_e);
          T_e=e.transfert ;
          mx_e=e.max_value;
          pow_e=(e.max_value^2)/12;// on suppose densite de proba uniforme
          max_s_e=max_s_e+norme1(T_e,NBECH_NORME1) * mx_e ;
          pow_s_e=pow_s_e+norme2(T_e,NBECH_NORME1)^2 * pow_e ;
        end // for i_e 
        celi.max_s_e=max_s_e;
        celi.pow_s_e=pow_s_e;
      // ajout des bruits de quantification a la liste des entrees
        F_b_s=fz_1.F_b_s; 
        nb_bruits=length(F_b_s);
        i_l=length(entree);
        for i_b=1:nb_bruits,
          F_bi_s=F_b_s(i_b);
          i_l=i_l+1;
          tmp.transfert=list();
          if (sw_noise_shaping==%t)&(i_b==1) then
            disp(string([celi.k1_noise_shaping,celi.k2_noise_shaping])); 
            tmp.transfert(1)= (1+ celi.k1_noise_shaping * z_1 +  celi.k2_noise_shaping * z_1^2) ; 
            tmp.transfert(2)=F_bi_s;
          else
            tmp.transfert(1)=F_bi_s;
          end
          tmp.max_value=MAX_BE;
          entree(i_l)=tmp;
        end
      // calcul max variable s due aux bruits 
        max_s_b=0;pow_s_b=0;
        for i_e=2:length(entree),
          e=entree(i_e);
          T_e=e.transfert ;
          mx_e=e.max_value;
          max_s_b=max_s_b+norme1(T_e,NBECH_NORME1)*mx_e;
          pow_e=(e.max_value^2)/12;// on suppose densite de proba uniforme
          pow_s_b=pow_s_b+norme2(T_e,NBECH_NORME1)^2*pow_e;
        end // for i_e 
        F.log2_lambda(i_f)=log2_lambda;
        F.max_s_b(i_f)=max_s_b;
        F.pow_s_b(i_f)=pow_s_b;
        F.max_s_e(i_f)=celi.max_s_e;
        F.pow_s_e(i_f)=celi.pow_s_e;
        F.max_s(i_f)=F.max_s_e(i_f)+F.max_s_b(i_f);
        F.pow_s(i_f)=F.pow_s_e(i_f)+F.pow_s_b(i_f);
      // mise a jour cellule i_f
        F.cel(i_f)=celi;
      end // for i_f
    end // if F.no_lamdda==%f
  //-------------------------------------------
  // abandon si pas de scaling possible
  //-------------------------------------------
    if F.no_lambda==%t then
       disp(' SCALING INPOSSIBLE, ABANDON');
       return
    end
  // dernier facteur d'echelle => remise a l'echelle
    F.log2_lambda(NB_F+1) =-F.K_qtf.L-sum(F.log2_lambda);
    F.lambda(NB_F+1)=2^(F.log2_lambda(NB_F+1));
    F.max_s_e(NB_F+1)=F.max_s_e(NB_F)*F.lambda(NB_F+1);
    F.pow_s_e(NB_F+1)=F.pow_s_e(NB_F)*F.lambda(NB_F+1)^2;
    F.max_s_b(NB_F+1)=F.max_s_b(NB_F)*F.lambda(NB_F+1);
    F.pow_s_b(NB_F+1)=F.pow_s_b(NB_F)*F.lambda(NB_F+1)^2;
    if (sw_handle_last_noise==%t) then
      F.max_s_b(NB_F+1)=F.max_s_b(NB_F+1)+MAX_BS;
      F.pow_s_b(NB_F+1)=F.pow_s_b(NB_F+1)+MAX_BS^2/12;
    end
    F.max_s(NB_F+1)=F.max_s_e(NB_F+1)+F.max_s_b(NB_F+1);
    F.pow_s(NB_F+1)=F.pow_s_e(NB_F+1)+F.pow_s_b(NB_F+1);
  //-----------------------------------------------------------------------
  // optimisation des facteurs d'echelle, et renseignements divers
  //-----------------------------------------------------------------------
  // 1- Calcul schema sans regroupement des scaling 
    F.L_COMMON=zeros(NB_F+1,1);// facteur d'echelle commun, en sortie l'additonneur de la cellule i
    F.log2_echelle_entree=zeros(NB_F+1,1);// log2(echelle de l'entree du filtre )
    F.log2_echelle_sortie=zeros(NB_F,1);// log2(echelle de l'entree du filtre )
    sum_echelles=F.K_qtf.L;
    for i_f=1:NB_F+1,
      has_celi=i_f<NB_F+1;
      is_last_cel=i_f==NB_F+1;
      has_celi_1=i_f>1;
      is_first_cel=i_f==1;
      if (has_celi) then
        celi=F.cel(i_f);
      end
      if (has_celi_1) then
        celi_1=F.cel(i_f-1);
      end
  
      F.log2_echelle_entree(i_f)=sum_echelles+F.log2_lambda(i_f);
      sum_echelles=sum_echelles+F.log2_lambda(i_f);
      if (i_f<NB_F+1) then
        F.log2_echelle_sortie(i_f)=sum_echelles+F.log2_lambda(i_f+1);
      end
    // creation tableau des decalages a droite a appliquer, devant l'additionneur d'entree
      Li=[];
    // init premiere cellule 
      if (is_first_cel) then
      // on raisonne sur le gain Ki => decalage initial =0
        Li=0;
      end //if (i_f==1 ) then 
      if (has_celi) then
        celi.n0_qtf.L_PROG=0;celi.n1_qtf.L_PROG=0;celi.n2_qtf.L_PROG=0;
        celi.d1_qtf.L_PROG=0;celi.d2_qtf.L_PROG=0;
      end // if (i_f < NB_F+1) then
    // init deuxieme a derniere cellule
      if (has_celi_1) then 
      // on raisonne sur coeffs ni de la cellule precedente
        if (celi_1.n0_qtf.coeff_nul==%f) then
          Li=[Li;celi_1.n0_qtf.L];
        end
        if (celi_1.n1_qtf.coeff_nul==%f) then
          Li=[Li;celi_1.n1_qtf.L];
        end
        if (celi_1.n2_qtf.coeff_nul==%f) then
          Li=[Li;celi_1.n2_qtf.L];
        end
      end //if (i_f>1 ) then 
    // prise en compte de la remise a l'echelle a l'entree du filtre
      Li=Li-F.log2_lambda(i_f);
    // prise en compte decalages lies aux coeffs du denominateur
      if (has_celi) then
      // denominateur uniquement pour cellules internes
        if (celi.d1_qtf.coeff_nul==%f) then
          Li=[Li;celi.d1_qtf.L];
        end
        if (celi.d2_qtf.coeff_nul==%f) then
          Li=[Li;celi.d2_qtf.L];
        end
      end // if (i_f < NB_F+1) then
    // on verifie que le resultat avant decalage soit codable sur 2^NB_BITS bits, par prudence
      F.L_COMMON(i_f)=0;
    // premiere cellule
      if (is_first_cel) then
        F.K_qtf.L_PROG=-F.log2_lambda(i_f);
      end//if (i_f==1) then
    // deuxieme a derniere cellule
      if (has_celi_1) then
        if (is_last_cel) then
          DELTA_L=-F.log2_lambda(i_f);
        //  DELTA_L=-sum_echelles;
        else
          DELTA_L=-F.log2_lambda(i_f); //icilesgars=0 avant
        end; 
        if (celi_1.n0_qtf.coeff_nul==%f) then
          celi_1.n0_qtf.L_PROG=DELTA_L+celi_1.n0_qtf.L;
        end
        if (celi_1.n1_qtf.coeff_nul==%f) then
          celi_1.n1_qtf.L_PROG=DELTA_L+celi_1.n1_qtf.L;
        end
        if (celi_1.n2_qtf.coeff_nul==%f) then
          celi_1.n2_qtf.L_PROG=DELTA_L+celi_1.n2_qtf.L;
        end
      end// if (i_f>1)  then
  
    // premiere a avant derniere cellule
      if (has_celi) then
        if (celi.d1_qtf.coeff_nul==%f) then
          celi.d1_qtf.L_PROG=celi.d1_qtf.L;
        end
        if (celi.d2_qtf.coeff_nul==%f) then
          celi.d2_qtf.L_PROG=celi.d2_qtf.L;
        end
      end  // if (i_f< NB_F+1)  then
    // prise en compte de lambda si L_COMMON PAS UTILISE
    // decalage programme en sortie de la cellule precedente 
      if (has_celi) then
        F.cel(i_f)=celi;
      end
      if (has_celi_1) then
        F.cel(i_f-1)=celi_1;
      end
    end //for i_f=1:NB_F+1,
  //2 - regroupement eventuel des scaling apres les additionneurs
    if sw_use_L_COMMON==%t then
      F.log2_echelle_entree=zeros(NB_F+1,1);// log2(echelle de l'entree du filtre )
      F.log2_echelle_sortie=zeros(NB_F,1);// log2(echelle de l'entree du filtre )
      sum_echelles=F.K_qtf.L;
      for i_f=1:NB_F+1,
        has_celi=i_f<NB_F+1;
        has_celi_1=i_f>1;
        is_first_cel=i_f==1;
        if (has_celi) then
          celi=F.cel(i_f);
        end
        if (has_celi_1) then
          celi_1=F.cel(i_f-1);
        end
      // decalage sortie de la cellule precedente= entree cellule courante 
        if (i_f==1) then
          Le=F.K_qtf.L_PROG;
        else
          Le=[];
          if (celi_1.n0_qtf.coeff_entier~=0) then
            Le=[Le;celi_1.n0_qtf.L_PROG];
          end
          if (celi_1.n1_qtf.coeff_entier~=0) then
            Le=[Le;celi_1.n1_qtf.L_PROG];
          end
          if (celi_1.n2_qtf.coeff_entier~=0) then
            Le=[Le;celi_1.n2_qtf.L_PROG];
          end
        end // if (i_f==1) then
       // decalage denominateur cellule courante 
        Ld=[]; // pas de denominateur
        if (i_f < NB_F+1) then
          if (celi.d1_qtf.coeff_entier~=0) then
            Le=[Le;celi.d1_qtf.L_PROG];
          end
          if (celi.d2_qtf.coeff_entier~=0) then
            Le=[Le;celi.d2_qtf.L_PROG];
          end
        end // if (i_f < NB_F+1 ) then
      // plus grand decalage commun applicable
        Ladd = min(min([Le;Ld]));
        while ( 2^Ladd * F.max_s(i_f) > MAX_ENTIER_2NB_BITS ) ,
          Ladd=Ladd-1;
        end
      // rangement dans scaling commun
        F.L_COMMON(i_f) =Ladd;
      // mise a jour scaling entrees
        if (i_f==1) then
          F.K_qtf.L_PROG=F.K_qtf.L_PROG - Ladd;
        else
          if (celi_1.n0_qtf.coeff_entier~=0) then
            celi_1.n0_qtf.L_PROG =celi_1.n0_qtf.L_PROG - Ladd;
          end
          if (celi_1.n1_qtf.coeff_entier~=0) then
            celi_1.n1_qtf.L_PROG =celi_1.n1_qtf.L_PROG - Ladd;
          end
          if (celi_1.n2_qtf.coeff_entier~=0) then
            celi_1.n2_qtf.L_PROG =celi_1.n2_qtf.L_PROG - Ladd;
          end
        end // if (i_f==1) then
      // mise a jour scaling denominateur
        if (i_f < NB_F+1) then
          if (celi.d1_qtf.coeff_entier~=0) then
            celi.d1_qtf.L_PROG =celi.d1_qtf.L_PROG - Ladd;
          end
          if (celi.d2_qtf.coeff_entier~=0) then
            celi.d2_qtf.L_PROG =celi.d2_qtf.L_PROG - Ladd;
          end
        end // if (i_f < NB_F+1 ) then
        if (has_celi) then
          F.cel(i_f)=celi;
        end
        if (has_celi_1) then
          F.cel(i_f-1)=celi_1;
        end
  
      end //for i_f=1:NB_F+1,
    end // if sw_use_L_COMMON==%t
  // 3 diminution des decalages a droite pour coeffs divisible /2
    if sw_optim_dcl==%t then
      F.K_qtf=minimise_decalage(F.K_qtf);
      for i_f=1:NB_F+1,
        has_celi=i_f<NB_F+1;
        has_celi_1=i_f>1;
        is_first_cel=i_f==1;
        if (has_celi) then
          celi=F.cel(i_f);
        end
        if (has_celi_1) then
          celi_1=F.cel(i_f-1);
        end
      // optimisation des decalages LPROG de chaque coeffs
        if (has_celi) then
          celi.n0_qtf=minimise_decalage(celi.n0_qtf);
          celi.n1_qtf=minimise_decalage(celi.n1_qtf);
          celi.n2_qtf=minimise_decalage(celi.n2_qtf);
          celi.d1_qtf=minimise_decalage(celi.d1_qtf);
          celi.d2_qtf=minimise_decalage(celi.d2_qtf);
        end
      // optimisation du decalage APRES_ADD 
        L=F.L_COMMON(i_f);ci=[];
        if (has_celi_1) then
          ci=[ci;celi_1.n0_qtf.coeff_entier;celi_1.n1_qtf.coeff_entier;celi_1.n2_qtf.coeff_entier];
        else 
          ci=[ci;F.K_qtf.coeff_entier];
        end
        if (has_celi) then
          ci=[ci;celi.d1_qtf.coeff_entier;celi.d2_qtf.coeff_entier];
        end
      // minimisation decalage commun
        [ci,L,DELTA_L]=minimise_decalage_commun(ci,L);
        F.L_COMMON(i_f)=F.L_COMMON(i_f)+DELTA_L;
      // remise a l echelle des coeffs 
        i_c=0;
        if (has_celi_1) then
        // On ne touche qu'a L, SURTOUT PAS A LPROG
          i_c=i_c+1;celi_1.n0_qtf.coeff_entier=ci(i_c);celi_1.n0_qtf.L=celi_1.n0_qtf.L+DELTA_L;
          i_c=i_c+1;celi_1.n1_qtf.coeff_entier=ci(i_c);celi_1.n1_qtf.L=celi_1.n1_qtf.L+DELTA_L;
          i_c=i_c+1;celi_1.n2_qtf.coeff_entier=ci(i_c);celi_1.n2_qtf.L=celi_1.n2_qtf.L+DELTA_L;
        else 
         i_c=i_c+1;F.K_qtf.coeff_entier=ci(i_c);F.K_qtf.L=F.K_qtf.L+DELTA_L;
        end
        if (has_celi) then
          i_c=i_c+1;celi.d1_qtf.coeff_entier=ci(i_c);celi.d1_qtf.L=celi.d1_qtf.L+DELTA_L;
          i_c=i_c+1;celi.d2_qtf.coeff_entier=ci(i_c);celi.d2_qtf.L=celi.d2_qtf.L+DELTA_L;
        end
        if (has_celi) then
          F.cel(i_f)=celi;
        end
        if (has_celi_1) then
          F.cel(i_f-1)=celi_1;
        end
      end //for i_f=1:NB_F+1,
    end //if sw_optim_dcl==%t
    F.L_FINAL=F.L_COMMON(NB_F+1);
  //--------------------------------------------------------
  // AFFICHAGE RESULTATS
  //--------------------------------------------------------
    if sw_aff_results==%t then
      l_aff=list();i_aff=0;
      disp(' -----resultats analyse theorique---------------');
      for i_f=1:NB_F+1,
        has_celi=i_f<NB_F+1;
        has_celi_1=i_f>1;
        is_first_cel=i_f==1;
        if (has_celi) then
          celi=F.cel(i_f);
        end
        if (has_celi_1) then
          celi_1=F.cel(i_f-1);
        end
        disp('L_lbd('+string(i_f)+')= '+string(F.log2_lambda(i_f)));
        s=  'max_s('+string(i_f)+')= '+string(F.max_s(i_f));
        s=s+ ', max_s from e('+string(i_f)+')= '+string(F.max_s_e(i_f));
        s=s+ ', max_s from b('+string(i_f)+')= '+string(F.max_s_b(i_f));
        s=s+ ', ecart-type_s from b('+string(i_f)+')= '+string(sqrt(F.pow_s_b(i_f)));
        disp(s);
        if (has_celi) then
          s=  'max_x('+string(i_f)+')= '+string(F.cel(i_f).max_x);
          s=s+ ', max_x from e('+string(i_f)+')= '+string(F.cel(i_f).max_x_e);
          s=s+ ', max_x from b('+string(i_f)+')= '+string(F.cel(i_f).max_x_e);
          disp(s);
        end
        if (i_f==NB_F+1) then
          s1='Entree max='+string(MAX_E);
          s1=s1+ ', Sortie max= '+string(round(F.max_s(i_f)));
          s1=s1+ ', Sortie max due a l entree='+string(round(F.max_s_e(i_f)));
          s1=s1+ ', Sortie max due aux bruits='+string(F.max_s_b(i_f));
          i_aff=i_aff+1;l_aff(i_aff)=s1;
        end
      end
      s='K='+string(F.K_qtf.coeff_entier)+',L='+string(F.K_qtf.L_PROG);
      disp(s);s1='';
      s1=s1+'K='+string(F.K_qtf.coeff_entier);
      s1=s1+',LK='+string(-F.K_qtf.L_PROG);
      s1=s1+',LF = ' +string(-F.L_FINAL);
      i_aff=i_aff+1;l_aff(i_aff)=s1;
      for i_f=1:NB_F,
        has_celi=i_f<NB_F+1;
        has_celi_1=i_f>1;
        is_first_cel=i_f==1;
        if (has_celi) then
          celi=F.cel(i_f);
        end
        if (has_celi_1) then
          celi_1=F.cel(i_f-1);
        end
        s='';s1='CELLULE '+string(i_f)+':';
        c=celi.n0_qtf.coeff_entier;L=celi.n0_qtf.L_PROG;n='n0_'+string(i_f);
        s1=s1+',N0='+string(c)+',LN0='+string(-L);
        s=s+''+n+'='+string(c)+',L='+string(L)+'|';
        c=celi.n1_qtf.coeff_entier;L=celi.n1_qtf.L_PROG;n='n1_'+string(i_f);
        s1=s1+',N1='+string(c)+',LN1='+string(-L);
        s=s+''+n+'='+string(c)+',L='+string(L)+'|';
        c=celi.n2_qtf.coeff_entier;L=celi.n2_qtf.L_PROG;n='n2_'+string(i_f);
        s1=s1+',N2='+string(c)+',LN2='+string(-L);
        s=s+''+n+'='+string(c)+',L='+string(L)+'|';
  
        c=celi.d1_qtf.coeff_entier;L=celi.d1_qtf.L_PROG;n='D1'+string(i_f);
        s=s+''+n+'='+string(c)+',L='+string(L)+'|';
        s1=s1+',D1='+string(c)+',LD1='+string(-L);
        
        c=celi.d2_qtf.coeff_entier;L=celi.d2_qtf.L_PROG;n='d2_'+string(i_f);
        s=s+''+n+'='+string(c)+',L='+string(L)+'|';
        s1=s1+',D2='+string(c)+',LD2='+string(-L);
        s=s+'LC='+string(F.L_COMMON(i_f))+'|';
        s1=s1+',LC='+string(-F.L_COMMON(i_f));
   
        s1=s1+',Lop='+string(F.l_a0(i_f));
        s=s+'Lop='+string(F.l_a0(i_f))+'|';
        i_aff=i_aff+1;l_aff(i_aff)=s1;
  
        disp(s);
      end//for i_f=1:NB_F,
      L=F.L_FINAL;n='L_FINAL';
      s=n+ ' = ' +string(L);
      disp(s);
    end //  if sw_aff_results==%t then
    simu_quantif_filter();
    genere_code();
    F.params=par; 
  endfunction
  function y=my_floor(x)
    y=x; 
    if switch_qtf_vars==1 then
      y=floor(y);
    end
  endfunction
  function y=decal(x,L)
    if x==0 then
      y=x;return
    end
    if L==0 then
      y=x;return
    end
    y=my_floor(x*2^L);
  endfunction
  function y=multiply_accumulate(acc,x,coeff_entier,LRIGHT)
    y=acc + decal(x * coeff_entier , -LRIGHT );
  endfunction
  function my_disp(s)
    if (switch_DEBUG==%t) & (switch_qtf_vars==1)   then
      disp(s)
    end
  endfunction
  function simu_quantif_filter()
    if switch_simu_temp==%t then
    // tableaux pour stockage entrees sorties, pas necessaire, ne sert qu'a l'affichage
      e=zeros(NBECH_SIMU_TEMP,1);s=zeros(NBECH_SIMU_TEMP,1);
      e_ideale=0:(NBECH_SIMU_TEMP-1);e_ideale=e_ideale*Te;
      e_ideale=round(NIVEAU_E_SIMU_TEMP*cos(2*%pi*FREQ_E_SIMU_TEMP*e_ideale));
      s_ideale=simule_Fz_1(F.F_z_1,e_ideale);
    // boucle pour switch_qtf_vars de 0 (ideal ) a 1 quantifie
      for switch_qtf_vars=0:1,
      //----------------------------------------------------
      // PHASE 1 -initialisation des memoires du filtre ( de l'equation )
      //-----------------------------------------------------
        F.ACC_op2_32=zeros(NB_F,1);F.ACC_op1_32=zeros(NB_F,1);
      // inutile, sert juste a visualiser
        F.arn=zeros(NB_F,1);
        F.op_ar=zeros(NB_F,1);
        F.op2_ar=zeros(NB_F,1);
        ar=zeros(NBECH_SIMU_TEMP,NB_F);
        max_ar_qtf=zeros(NB_F,1);
      // boucle pour n allant de 1 e 1000 echantillons
        for n=1:NBECH_SIMU_TEMP, // pour n allant de 1 au nombre d'echantillons
          t=(n-1)*Te;
          en=round(NIVEAU_E_SIMU_TEMP*cos(2*%pi*FREQ_E_SIMU_TEMP*t));   //innovation en = entree a l'instant n
        // ----------------------------------------------------------
        // routine de filtrage
        //----------------------------------------------------------- 
          acc=0;
          acc= multiply_accumulate(acc,en ,F.K_qtf.coeff_entier,F.K_qtf.L_PROG);
          for i_f=1:NB_F,
          // mise a jour sorties operateurs N Bits depuis les accumulateurs 2.N bits
             op2_ar_16=decal(F.ACC_op2_32(i_f),-F.l_a0(i_f));
             op_ar_16 =decal(F.ACC_op1_32(i_f),-F.l_a0(i_f));
          //---------------------------------------------------
          // PHASE 1: Partie AR de l'equation reccurente
          //---------------------------------------------------
          //   if (i_f==1), my_disp(' AVANT AR,acc='+string(acc)); end
          //   if (i_f==2), my_disp(' AVANT AR,acc='+string(acc)+',ACC1='+string(F.ACC_op1_32(i_f))+',ACC2='+string(F.ACC_op2_32(i_f))); end
             acc= multiply_accumulate(acc,op_ar_16 ,-celi.d1_qtf.coeff_entier,celi.d1_qtf.L_PROG);
             acc= multiply_accumulate(acc,op2_ar_16,-celi.d2_qtf.coeff_entier,celi.d2_qtf.L_PROG);
          //   if (i_f<=2), my_disp(' AVANT ADD,acc='+string(acc)+',opar='+string(op_ar_16)); end
             acc= decal(acc,-F.L_COMMON(i_f));
          //   if (i_f==2), my_disp(' APRES ADD,acc='+string(acc)); end
           // inutile, juste pour visu
             F.arn(i_f)=acc;
             ar(n,i_f)=acc; 
           //------------------------------------------------------------
           // PHASE 2: mise a jour des memoires Accumulateurs 32 bits pour la fois d'apres
           //------------------------------------------------------------
             ar_16=acc;
             F.ACC_op2_32(i_f)=F.ACC_op2_32(i_f) - op2_ar_16;
             F.ACC_op2_32(i_f)=F.ACC_op2_32(i_f) + op_ar_16 ;
   
             F.ACC_op1_32(i_f)=F.ACC_op1_32(i_f) - op_ar_16;
             F.ACC_op1_32(i_f)=F.ACC_op1_32(i_f) + ar_16;
           //------------------------------------------------------------
           // PHASE 3: sortie de l'equation reccurente=> Partie MA acc=n0.arn+n1.op_arn+n2.op2_arn, 
           //------------------------------------------------------------
             acc=0; 
             acc= multiply_accumulate(acc,ar_16     ,celi.n0_qtf.coeff_entier,celi.n0_qtf.L_PROG);
           //  if (i_f==2), my_disp(' APRES MA N0,acc='+string(acc)+'ar='+string(ar_16)+'opar='+string(op_ar_16)+'op2ar='+string(op2_ar_16)); end
             acc= multiply_accumulate(acc,op_ar_16  ,celi.n1_qtf.coeff_entier,celi.n1_qtf.L_PROG);
           //  if (i_f==2), my_disp(' APRES MA N1,acc='+string(acc)+'ar='+string(ar_16)+'opar='+string(op_ar_16)+'op2ar='+string(op2_ar_16)); end
             acc= multiply_accumulate(acc,op2_ar_16 ,celi.n2_qtf.coeff_entier,celi.n2_qtf.L_PROG);
           //  if (i_f==1), my_disp(' APRES MA,acc='+string(acc)+'ar='+string(ar_16)+'opar='+string(op_ar_16)); end
           //  if (i_f==2), my_disp(' APRES MA,acc='+string(acc)+'ar='+string(ar_16)+'opar='+string(op_ar_16)+'op2ar='+string(op2_ar_16)); end
           //------------------------------------------------------------
           // inutile : sortie de l'equation reccurente
           //------------------------------------------------------------
             sn=acc;
          end // pour i_f de 1 a nb de cellules
          my_disp(' sortie avant decal ='+string(acc));
          if sw_handle_last_noise==%t then
            if switch_qtf_vars==1 then
          // mise a l'echelle de la sortie, AVEC ARRONDI !...
              sn=decal(sn,1-F.L_FINAL);
              sn=sn+1;
              sn=decal(sn,-1);
            else
              sn=decal(sn,-F.L_FINAL);
            end
          else
            sn=2^(-F.L_FINAL)*sn;
          end
          my_disp('n='+string(n)+',sn='+string(sn));
          if switch_DEBUG==%t then
          //  s_dbg=' n='+string(n);
          //  s_dbg=s_dbg+', en='+string(en);
          //  s_dbg=s_dbg+', op1c1='+string(F.ACC_op1_32(1));
          //  s_dbg=s_dbg+', acc1_c2='+string(F.ACC_op1_32(2));
          //  s_dbg=s_dbg+', acc2_c1='+string(F.ACC_op2_32(2));
          //  s_dbg=s_dbg+', sn='+string(sn);
          //  my_disp(s_dbg);
          end
  
        // rangement des entrees sorties dans un tableau pour affichage
          e(n)=en;s(n) = sn;
        end // pour n de 1 au nb d'echantillons
        if switch_qtf_vars==0 then
          s_sans_bruit=s;
        else
          s_qtf=s; 
          for i=1:NB_F,
           max_ar_qtf(i)=max(abs(ar(:,i)));
          end 
        end
      end //pour switch_qtf_vars de 0 a 1
      delta_s=s_ideale-s_qtf;
      disp(' -----resultats simulation ---------------');
      for i_f=1:NB_F,
        disp('max variable ar quantifiee='+string(max_ar_qtf(i_f)));
      end
    // trace de s
      xset('window',i_fig);// choisir figure 0
      clf(i_fig,"reset");        // effacer le contenu
      i_fig=i_fig+1;
      subplot(2,1,1);
      i_aff=1:max(size(s_ideale));i_aff=i_aff.';
      plot2d([i_aff,i_aff],[s_qtf,s_ideale],[1,1]); 
      //xtitle('SORTIE DU FILTRE');      // tracer le tableau s en fct de son indice
      pas=round(max(size(s_ideale))/25 );
      i_aff1=1:pas:(max(size(s_ideale))-pas);
      i_aff2=round(pas/2)+i_aff1;
      i_aff1=i_aff1.';
      i_aff2=i_aff2.'; 
      plot2d([i_aff1,i_aff2],[s_ideale(i_aff1),s_qtf(i_aff2)],[-2,-6]); 
      legends(['SORTIE IDEALE';'SORTIE CODEE'],[-2,-6],opt='lr');
  
      subplot(2,1,2);plot2d(delta_s); 
      legends(['ERREUR=SORTIE IDEALE - SORTIE CODEE'],1,opt='lr');
  //xtitle('ERREUR=SORTIE IDEALE - SORTIE CODEE');      // tracer le tableau s en fct de son indice
      xselect();
    end //if switch_simu_temp==%t then
  endfunction
   function new_l=declar_coeff_et_decal(l,name_c,val_c,sval_c,name_Lc,val_Lc,sval_Lc);
     new_l=l; 
     i=length(new_l);// liste des chaines de caracteres precedemment generees 
     if val_c==0 then
       i=i+1;new_l(i) ='  /* unused '+name_c+' '+sval_c+' */';
       i=i+1;new_l(i) ='  /* unused '+name_Lc+' '+sval_Lc+' */';
       return
     end
     i=i+1;new_l(i) ='  #define   '+name_c+' '+sval_c;
     if val_Lc==0 then
       i=i+1;new_l(i) ='  /* unused '+name_Lc+' '+sval_Lc+' */';
       return
     end
     if ( val_Lc <0 ) then
       sval_Lc=string(-val_Lc);name_Lc='MOINS_'+name_Lc;
       i=i+1;new_l(i) ='  #define   '+name_Lc+' '+sval_Lc;
       return
     end
     i=i+1;new_l(i) ='  #define   '+name_Lc+' '+sval_Lc;
   endfunction    
   function new_l=declar_coeff(l,name_c,val_c,sval_c);
     new_l=l; 
     i=length(new_l);// liste des chaines de caracteres precedemment generees 
     if val_c==0 then
       i=i+1;new_l(i) ='  /* unused '+name_c+' '+sval_c+' */';
       return
     end
     i=i+1;new_l(i) ='  #define   '+name_c+' '+sval_c;
   endfunction    
   function [new_l_declar,new_l_fct_init]=declar_memoires(l_declar,l_fct_init,i_f )
     i=length(l_declar);// liste des chaines de caracteres precedemment generees
     j=length(l_fct_init);// liste des chaines de caracteres precedemment generees
     is_z_1=F.l_a0(i_f)==0;
     if (is_z_1)==%t then
       type_acc=int_16
     else
       type_acc=int_32
     end
     if (name_acc_op1(i_f)~=[]) then
     // declaration dmemoires 
       i=i+1;l_declar(i)= '  '+type_acc+' '+name_acc_op1(i_f)+' ; /* declaration memoire 1 cellule '+string(i_f)+' */';
       j=j+1;l_fct_init(j)= '    '+name_acc_op1(i_f)+' = 0;' +'/* initialisation memoire 1 cellule '+string(i_f)+' */';
     end  
     if (name_acc_op2(i_f)~=[]) then
       i=i+1;l_declar(i)= '  '+type_acc +' '+name_acc_op2(i_f)+' ; /* declaration memoire 2 cellule '+string(i_f)+' */';
       j=j+1;l_fct_init(j)= '    '+name_acc_op2(i_f)+' = 0;' +'/* initialisation memoire 2 cellule '+string(i_f)+' */';
     end  
 
     new_l_declar=l_declar;
     new_l_fct_init=l_fct_init;
   endfunction    
   function    new_l=code_multiply_acc(entete,l,name_acc,name_var,name_c,val_c,sval_c,name_Lc,val_Lc,sval_Lc);
     new_l=l;i=length(new_l);
     if val_c==0 then
       return
     end
     if val_Lc>0 then
       i=i+1;new_l(i)=entete + '  '+ name_acc +' += (' + name_var +' * ' +name_c + ') >> '+name_Lc+' ; /* ' +name_c+' = '+sval_c+' , '+name_Lc+' = '+sval_Lc+' */';
     end
     if val_Lc<0 then
       sval_Lc=string(-val_Lc);name_Lc='MOINS_'+name_Lc;
       i=i+1;new_l(i)=entete + '  '+ name_acc +' += (' + name_var +' * ' +name_c + ') << '+name_Lc+' ; /* ' +name_c+' = '+sval_c+' , '+name_Lc+' = '+sval_Lc+' */';
     end
     if val_Lc==0 then
       i=i+1;new_l(i)=entete + '  '+ name_acc +' += (' + name_var +' * ' +name_c + ') ; /* ' +name_c+' = '+sval_c+' */';
     end
   endfunction
   function    new_l=code_decal(entete,l,name_acc,name_Lc,val_Lc,sval_Lc);
     new_l=l;i=length(new_l);
     if val_Lc==0 then
       return
     end
     if val_Lc <0 then
       sval_Lc=string(-val_Lc);name_Lc='MOINS_'+name_Lc;
       i=i+1;new_l(i)=entete + '  '+ name_acc +' <<= '+name_Lc+' ; /* ' +name_Lc+' = '+sval_Lc+' */';
       return
     end
     i=i+1;new_l(i)=entete + '  '+ name_acc +' >>= '+name_Lc+' ; /* ' +name_Lc+' = '+sval_Lc+' */';
   endfunction
   function    new_l=code_decal_with_round(entete,l,name_acc,name_Lc,val_Lc,sval_Lc);
     new_l=l;i=length(new_l);
     if val_Lc==0 then
       return
     end
     if val_Lc <0 then
       sval_Lc=string(-val_Lc);name_Lc='MOINS_'+name_Lc;
       i=i+1;new_l(i)=entete + '  '+ name_acc +' <<= name_Lc ; /*  decal gauche avec arrondi, de :'+name_Lc+' = '+sval_Lc+' */';
       return
     end
     val_Lc_moins_1=val_Lc-1;
     if val_Lc_moins_1>0 then
       i=i+1;new_l(i)=entete + '  '+ name_acc +' >>= ('+name_Lc+'-1) ; /*  decal droite avec arrondi, de :'+name_Lc+' = '+sval_Lc+' */';
     end
     i=i+1;new_l(i)=entete + '  '+ name_acc +' += 1 ;';

     i=i+1;new_l(i)=entete + '  '+ name_acc +' >>= 1 ;';
   endfunction
   function [new_l_code]=code_equation(l_code,i_f )
     sLo=string(F.l_a0(i_f));
     new_l_code=l_code; 
     name_ar='ar_'+nb_bits;
     entete='  '; 
    if (i_f==1) then
    // declaration des variables locales a la fonction
       i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+int_32+' '+name_acc+' ; /* il faudrait que cette variable soit un registre '+deux_nb_bits+' bits'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+int_16+' '+name_ar+' ; /* il faudrait que cette variable soit un registre '+nb_bits+' bits'+' */';
       if (max(F.ordre_cel)>=1)&( find(F.l_a0~=0)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+int_16+' '+name_op1+' ; /* il faudrait que cette variable soit un registre '+nb_bits+' bits'+' */';
       end 
       if (max(F.ordre_cel)>=2)&( find(F.l_a0~=0)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+int_16+' '+name_op2+' ; /* il faudrait que cette variable soit un registre '+nb_bits+' bits'+' */';
       end 
    // GAIN INITIAL DU FILTRE
       if val_K~=0 then   
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* ------------------------------------------------'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* GAIN INITIAL '+ name_K+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+name_acc+' = '+name_K+' * '+name_entree+' ; /* '+name_K+' = '+sval_K+' */';
       else
         disp('PROBLEME AVEC LE GAIN INITIAL !...');
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PROBLEME : GAIN INITIAL '+name_K+' =0 => SORTIE FILTRE =0 => POURQUOI CODER CE FILTRE...'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_L_FINAL,val_L_FINAL,sval_L_FINAL);
         i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+name_acc+' = 0 ;';
       end
    end //    if (i_f==1) then
     // liste des chaines de caracteres precedemment generees
     i=length(new_l_code)+1;new_l_code(i)=entete+'/*------------------------------------------------------------'+' */';
     i=length(new_l_code)+1;new_l_code(i)=entete+'/* CODE DE LA CELLULE '+string(i_f)+' DU FILTRE '+NAME_FILTER;+' */'
     i=length(new_l_code)+1;new_l_code(i)=entete+'/*------------------------------------------------------------'+' */';
     if ( F.l_a0(i_f) ~=0 ) then 
       i=length(new_l_code)+1;new_l_code(i)=entete+'/*  operateur  employe = 2^-'+sLo+' / (1 - ( 1 - 2^-'+sLo+' ) . z^-1 )'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+'/* PHASE 1 CELLULE '+string(i_f)+' :  mise a jour sorties operateurs N Bits depuis les accumulateurs 2.N bits'+' */';
       if (name_acc_op1(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_op1+' = (' +int_16+') '+'( '+name_acc_op1(i_f)+' >> '+sLo+' ) ;';
       end 
       if (name_acc_op2(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_op2+' = (' +int_16+') '+'( '+name_acc_op2(i_f)+' >> '+sLo+' ) ;';
       end 
       i=length(new_l_code)+1;new_l_code(i)=entete + '/* PHASE 2.1 CELLULE '+string(i_f)+' : Partie AR de l equation reccurente'+' */';
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_op1,name_md1(i_f),val_md1(i_f),sval_md1(i_f),name_Lmd1(i_f),val_Lmd1(i_f),sval_Lmd1(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_op2,name_md2(i_f),val_md2(i_f),sval_md2(i_f),name_Lmd2(i_f),val_Lmd2(i_f),sval_Lmd2(i_f));
       if val_LADD(i_f)~=0 then
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 2.2 CELLULE '+string(i_f)+' : DECALAGE LADD en sortie de l additionneur'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_LADD(i_f),val_LADD(i_f),sval_LADD(i_f));
       else
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 2.2 CELLULE '+string(i_f)+' : PAS DE DECALAGE LADD en sortie de l additionneur'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_LADD(i_f),val_LADD(i_f),sval_LADD(i_f));
       end
       i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 2.3 CELLULE '+string(i_f)+' : mise a jour de la variable ar_n du filtre'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_ar+' = (' +int_16+') '+'( '+name_acc +' ) ;'
       i=length(new_l_code)+1;new_l_code(i)=entete+'/* PHASE 3 CELLULE '+string(i_f)+' : mise a jour des memoires Accumulateurs 32 bits pour la fois d apres'+' */';
       if (name_acc_op2(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'/*  mise a jour accumulateur '+name_acc_op2(i_f)+'associe a '+name_op2+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op2(i_f)+' -= ' +name_op2+' ;';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op2(i_f)+' += ' +name_op1+' ;';
       end
       if (name_acc_op1(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'/*  mise a jour accumulateur '+name_acc_op1(i_f)+'associe a '+name_op1+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op1(i_f)+' -= ' +name_op1+' ;';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op1(i_f)+' += ' +name_ar+' ;';
       end
       i=length(new_l_code)+1;new_l_code(i)=entete+'/* PHASE 4 CELLULE '+string(i_f)+' : sortie de l equation reccurente=> Partie MA acc=n0.arn+n1.op_arn+n2.op2_arn, '+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+'  '+name_acc+' = 0 ;' 
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_ar,name_n0(i_f),val_n0(i_f),sval_n0(i_f),name_Ln0(i_f),val_Ln0(i_f),sval_Ln0(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_op1,name_n1(i_f),val_n1(i_f),sval_n1(i_f),name_Ln1(i_f),val_Ln1(i_f),sval_Ln1(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_op2,name_n2(i_f),val_n2(i_f),sval_n2(i_f),name_Ln2(i_f),val_Ln2(i_f),sval_Ln2(i_f));
    else //     if ( F.l_a0(i_f) ~=0 ) then 
    // cellule programmee en z^-1
       i=length(new_l_code)+1;new_l_code(i)=entete+'/*  operateur  employe = z^-1'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete + '/* PHASE 1.1 CELLULE '+string(i_f)+' : Partie AR de l equation reccurente'+' */';
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_acc_op1(i_f),name_md1(i_f),val_md1(i_f),sval_md1(i_f),name_Lmd1(i_f),val_Lmd1(i_f),sval_Lmd1(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_acc_op2(i_f),name_md2(i_f),val_md2(i_f),sval_md2(i_f),name_Lmd2(i_f),val_Lmd2(i_f),sval_Lmd2(i_f));
       if val_LADD(i_f)~=0 then
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 1.2 CELLULE '+string(i_f)+' : DECALAGE LADD en sortie de l additionneur'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_LADD(i_f),val_LADD(i_f),sval_LADD(i_f));
       else
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 1.2 CELLULE '+string(i_f)+' : PAS DE DECALAGE LADD en sortie de l additionneur'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_LADD(i_f),val_LADD(i_f),sval_LADD(i_f));
       end
       i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PHASE 1.3 CELLULE '+string(i_f)+' : mise a jour de la variable ar_n du filtre'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_ar+' = (' +int_16+') '+'( '+name_acc +' ) ;'
       i=length(new_l_code)+1;new_l_code(i)=entete+'/* PHASE 2 CELLULE '+string(i_f)+' : sortie de l equation reccurente=> Partie MA acc=n0.arn+n1.op_arn+n2.op2_arn, '+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+'  '+name_acc+' = 0 ;' 
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_ar,name_n0(i_f),val_n0(i_f),sval_n0(i_f),name_Ln0(i_f),val_Ln0(i_f),sval_Ln0(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_acc_op1(i_f),name_n1(i_f),val_n1(i_f),sval_n1(i_f),name_Ln1(i_f),val_Ln1(i_f),sval_Ln1(i_f));
       new_l_code=code_multiply_acc(entete,new_l_code,name_acc,name_acc_op2(i_f),name_n2(i_f),val_n2(i_f),sval_n2(i_f),name_Ln2(i_f),val_Ln2(i_f),sval_Ln2(i_f));
       i=length(new_l_code)+1;new_l_code(i)=entete+'/* PHASE 3 CELLULE '+string(i_f)+' : mise a jour des memoires pour la fois d apres'+' */';
       if (name_acc_op2(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'/*  mise a jour memoire '+name_acc_op2(i_f)+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op2(i_f)+' = ' +name_acc_op1(i_f)+' ;';
       end
       if (name_acc_op1(i_f)~=[]) then
         i=length(new_l_code)+1;new_l_code(i)=entete +'/*  mise a jour memoire '+name_acc_op1(i_f)+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete +'  '+name_acc_op1(i_f)+' = ' +name_ar+' ;';
       end
    end  //     if ( F.l_a0(i_f) ~=0 ) then 
    if (i_f==NB_F) then
    // DECALAGE FINAL
       if val_L_FINAL~=0 then   
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* DECALAGE FINAL DE REMISE A L ECHELLE'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         new_l_code=code_decal_with_round(entete,new_l_code,name_acc,name_L_FINAL,val_L_FINAL,sval_L_FINAL);
       else
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/* PAS DE DECALAGE FINAL DE REMISE A L ECHELLE CAR LFINAL = 0 '+' */';
         i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
         new_l_code=code_decal(entete,new_l_code,name_acc,name_L_FINAL,val_L_FINAL,sval_L_FINAL);
       end
       i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+ '/* RENVOI DU RESULTAT '+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+ '/*------------------------------------------------'+' */';
       i=length(new_l_code)+1;new_l_code(i)=entete+ '  '+'return '+name_acc+' ; /* la sortie '+name_acc+' sera de module < '+string(ceil(F.max_s(NB_F+1)))+', l erreur max sera < '+string(F.max_s_b(NB_F+1)-0.5)+' */';
    end //    if (i_f==NB_F) then
   endfunction    
  function genere_code()
    if switch_genere_code==%t then
    //-----------------------------------------------------------------------------------
    // NOMS ET VALEURS ASSOCIES A LA GENERATION DE CODE
    //-----------------------------------------------------------------------------------
      nb_bits=string(NB_BITS);
      deux_nb_bits=string(2*NB_BITS);
      int_16='int_'+nb_bits+"_"+name_struct;
      int_32='int_'+deux_nb_bits+"_"+name_struct;
      name_entree='en_'+nb_bits;
      name_op1='op1_ar_'+nb_bits;
      name_op2='op2_ar_'+nb_bits;
      name_acc='acc_'+deux_nb_bits;
      name_n0=list();
      name_n1=list();
      name_n2=list();
      name_md1=list();
      name_md2=list();
      name_Ln0=list();
      name_Ln1=list();
      name_Ln2=list();
      name_Lmd1=list();
      name_Lmd2=list();
      name_LADD=list();
      val_n0=list();
      val_n1=list();
      val_n2=list();
      val_md1=list();
      val_md2=list();
      val_Ln0=list();
      val_Ln1=list();
      val_Ln2=list();
      val_Lmd1=list();
      val_Lmd2=list();
      val_LADD=list();
      sval_n0=list();
      sval_n1=list();
      sval_n2=list();
      sval_md1=list();
      sval_md2=list();
      sval_Ln0=list();
      sval_Ln1=list();
      sval_Ln2=list();
      sval_Lmd1=list();
      sval_Lmd2=list();
      sval_LADD=list();
      name_K='K_'+NAME_FILTER;
      val_K=F.K_qtf.coeff_entier;
      sval_K=string(val_K);
      name_LK='LK_'+NAME_FILTER;
      val_LK = F.K_qtf.L_PROG;
      sval_LK=string(val_LK);
      name_L_FINAL='L_FINAL_'+NAME_FILTER;
      val_L_FINAL=F.L_FINAL;
      sval_L_FINAL=string(val_L_FINAL);
  // variables
     name_acc_op1=list();
     name_acc_op2=list();
      for i_f=1:NB_F,
        name_n0(i_f)='n0_'+NAME_FILTER+string(i_f);
        name_Ln0(i_f)='Ln0_'+NAME_FILTER+string(i_f);
        name_n1(i_f)='n1_'+NAME_FILTER+string(i_f);
        name_Ln1(i_f)='Ln1_'+NAME_FILTER+string(i_f);
        name_n2(i_f)='n2_'+NAME_FILTER+string(i_f);
        name_Ln2(i_f)='Ln2_'+NAME_FILTER+string(i_f);
        name_md1(i_f)='moins_d1_'+NAME_FILTER+string(i_f);
        name_Lmd1(i_f)='Ld1_'+NAME_FILTER+string(i_f);
        name_md2(i_f)='moins_d2_'+NAME_FILTER+string(i_f);
        name_Lmd2(i_f)='Ld2_'+NAME_FILTER+string(i_f);
        name_LADD(i_f)='LADD_'+NAME_FILTER+string(i_f);
        val_n0(i_f) = celi.n0_qtf.coeff_entier ;
        val_Ln0(i_f)= celi.n0_qtf.L_PROG ;
        val_n1(i_f) = celi.n1_qtf.coeff_entier ;
        val_Ln1(i_f)= celi.n1_qtf.L_PROG ;
        val_n2(i_f) = celi.n2_qtf.coeff_entier ;
        val_Ln2(i_f)= celi.n2_qtf.L_PROG ;
        val_md1(i_f) = -celi.d1_qtf.coeff_entier ;
        val_Lmd1(i_f)= celi.d1_qtf.L_PROG ;
        val_md2(i_f) = -celi.d2_qtf.coeff_entier ;
        val_Lmd2(i_f)= celi.d2_qtf.L_PROG ;
        val_LADD(i_f)=F.L_COMMON(i_f) ;
        sval_n0(i_f) =string(val_n0(i_f));
        sval_Ln0(i_f)=string(val_Ln0(i_f));
        sval_n1(i_f) =string(val_n1(i_f));
        sval_Ln1(i_f)=string(val_Ln1(i_f));
        sval_n2(i_f) =string(val_n2(i_f));
        sval_Ln2(i_f)=string(val_Ln2(i_f));
        sval_md1(i_f) =string(val_md1(i_f));
        sval_Lmd1(i_f)=string(val_Lmd1(i_f));
        sval_md2(i_f) =string(val_md2(i_f));
        sval_Lmd2(i_f)=string(val_Lmd2(i_f));
        sval_LADD(i_f)=string(val_LADD(i_f));
      end
      l_define=list(); // definition des constantes
      l_declar=list(); // declaration des variables
    //------------------------------------------------------------------------------
    // generation du code a chaque pas d'echantillonnage
    //------------------------------------------------------------------------------
       l_entete=list();i=length(l_entete); 
       l_entete(length(l_entete)+1)='/* ------------------------------------------------------------------------- '+' */';
       l_entete(length(l_entete)+1)='/* pour compiler le programme sous linux ,ecrire dans une console '+' */';
       l_entete(length(l_entete)+1)='/*   gcc -c ./'+NOM_PROGRAMME_EN_C+'.c'+' */';
       l_entete(length(l_entete)+1)='/*   gcc -o ./'+NOM_PROGRAMME_EN_C+'.exe '+NOM_PROGRAMME_EN_C+'.o'+' */';
       l_entete(length(l_entete)+1)='/* puis pour executer le programme sous linux ,ecrire'+' */';
       l_entete(length(l_entete)+1)='/* ./'+NOM_PROGRAMME_EN_C+'.exe'+' */';
       l_entete(length(l_entete)+1)='/* ------------------------------------------------------------------------- '+' */';
  
  
       l_entete(length(l_entete)+1)='#include <stdio.h>';
       l_entete(length(l_entete)+1)='  typedef short int ' + int_16 +'; /* A CHANGER EVENTUELLEMENT, DEFINITION ENTIER SUR +'+nb_bits+' bits'+' */';
       l_entete(length(l_entete)+1)='  typedef long  int ' + int_32 +'; /* A CHANGER EVENTUELLEMENT, DEFINITION ENTIER SUR +'+deux_nb_bits+' bits'+' */';
       l_entete(length(l_entete)+1)='/*-------------------------------------------------------------------------'+' */';
       l_entete(length(l_entete)+1)='/*   CODAGE EN ARITHMETIQUE '+nb_bits+'/'+deux_nb_bits+ ' BITS DU FILTRE NUMERIQUE SUIVANT ( expression en W )'+' */';
       l_entete(length(l_entete)+1)='/*-------------------------------------------------------------------------'+' */';
  
     // ecriture structure
      nv='w';s=' '+NAME_FILTER+'('+nv+') = K';
      for i_f=1:NB_F,
        s=s+' . '+NAME_FILTER+string(i_f)+'('+nv+')';
      end //for i_f=1:NB_F,
      l_entete(length(l_entete)+1)='/*  '+s+' */';
      l_entete(length(l_entete)+1)='/*  avec K = 1 '+' */';
    // ecriture des cellules en w
      for i_f=1:NB_F,
        l_entete(length(l_entete)+1)='/*    '+chaine_fraction(NAME_FILTER+string(i_f),F.F_w(i_f),1,'w')+' */';
      end //for i_f=1:NB_F,
      l_entete(length(l_entete)+1)='/* chaque cellule Fi est codee sous forme directe 1d,'+' */';
      l_entete(length(l_entete)+1)='/* avec un operateur propre op_i, generalement different'+' */';
      l_entete(length(l_entete)+1)='/* de l operateur retard z^-1'+' */';
    // GAIN PROGRAMME DU FILTRE
      l_entete(length(l_entete)+1)='/*----------------------------------------------------------------------'+' */';
      l_entete(length(l_entete)+1)='/*      GAIN PROGRAMME : '+ name_K + ' = ' + sval_K +' , '+ name_LK + ' = ' + sval_LK+' */';
      for i_f=1:NB_F,
        l_entete(length(l_entete)+1)='/*----------------------------------------------------------------------'+' */';
        l_entete(length(l_entete)+1)='/*  CODAGE CELLULE ' + string(i_f)+' */';
        l_entete(length(l_entete)+1)='/*      EXPRESSION IDEALE     en w : '+chaine_fraction(NAME_FILTER+string(i_f)+' ',F.F_w(i_f),1,'w'+string(i_f))+' */';
        l_entete(length(l_entete)+1)='/*  =>  EXPRESSION IDEALE     en op: '+chaine_fraction(NAME_FILTER+string(i_f)+' ',F.F_op(i_f),1,'op_'+string(i_f))+' */';
        l_entete(length(l_entete)+1)='/*  =>  EXPRESSION QUANTIFIEE en op: '+chaine_fraction(NAME_FILTER+string(i_f)+'q',F.F_op_qtf(i_f),1,'op_'+string(i_f))+' */';
        l_entete(length(l_entete)+1)='/*  =>  EXPRESSION QUANTIFIEE en w : '+chaine_fraction(NAME_FILTER+string(i_f)+'q',F.F_op_qtf_en_w(i_f),1,'w'+string(i_f))+' */';
       // l_entete(length(l_entete)+1)='/*   avec : '+' */';
       // l_entete(length(l_entete)+1)='/*     en z^-1 :'+ chaine_fraction('op_'+string(i_f),F.op_de_z_1(i_f),1,'z^-1')+' */';
       // l_entete(length(l_entete)+1)='/*     en w    :'+ chaine_fraction('op_'+string(i_f),F.op_de_w(i_f),1,'w')+' */';
      // coefficients lies a cette cellule 
  
        l_entete(length(l_entete)+1)='/*     coefficients programmes relatifs a cette cellule'+' */';
        l_entete(length(l_entete)+1)='/*       coefficient -d1     :'+name_md1(i_f)+' = '+ sval_md1(i_f)+' , '+name_Lmd1(i_f)+' = '+sval_Lmd1(i_f)+' */';
        l_entete(length(l_entete)+1)='/*       coefficient -d2     :'+name_md2(i_f)+' = '+ sval_md2(i_f)+' , '+name_Lmd2(i_f)+' = '+sval_Lmd2(i_f)+' */';
        l_entete(length(l_entete)+1)='/*       decal en sortie add :'+name_LADD(i_f)+' = '+ sval_LADD(i_f)+' */';
  
        l_entete(length(l_entete)+1)='/*       coefficient  n0     :'+name_n0(i_f)+' = '+ sval_n0(i_f)+' , '+name_Ln0(i_f)+' = '+sval_Ln0(i_f)+' */';
        l_entete(length(l_entete)+1)='/*       coefficient  n1     :'+name_n1(i_f)+' = '+ sval_n1(i_f)+' , '+name_Ln1(i_f)+' = '+sval_Ln1(i_f)+' */';
        l_entete(length(l_entete)+1)='/*       coefficient  n2     :'+name_n2(i_f)+' = '+ sval_n2(i_f)+' , '+name_Ln2(i_f)+' = '+sval_Ln2(i_f)+' */';
      end //for i_f=1:NB_F,
      l_entete(length(l_entete)+1)='/*----------------------------------------------------------------------'+' */';
      l_entete(length(l_entete)+1)='/*      DECALAGE FINAL : '+ name_L_FINAL + ' = ' + sval_L_FINAL +' */';
      l_entete(length(l_entete)+1)='/*----------------------------------------------------------------------'+' */';
  
      i=length(l_define);
      l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
      l_define(length(l_define)+1)='/*    DEFINITION GAIN K DU FILTRE ' + NAME_FILTER+' */';
      l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
      [l_define]=declar_coeff_et_decal(l_define,name_K,val_K,sval_K,name_LK,val_LK,sval_LK);
      F.moins_d1_qtf=list();F.moins_d2_qtf=list();F.ordre_cel=zeros(NB_F,1);
      for i_f=1:NB_F,
      // definition des coeffs et decalage
        name_cel=' cellule '+string(NB_F);
        i=length(l_define);
        l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
        l_define(length(l_define)+1)='/*    DEFINITION DES COEFFS ET DECALAGES DE LA CELLULE '+string(i_f) +' DU FILTRE ' + NAME_FILTER+' */';
        l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
        F.moins_d1_qtf(i_f)=celi.d1_qtf;
        F.moins_d2_qtf(i_f)=celi.d2_qtf;
        F.moins_d1_qtf(i_f).coeff_quantifie=-F.moins_d1_qtf(i_f).coeff_quantifie;
        F.moins_d1_qtf(i_f).coeff_entier=-F.moins_d1_qtf(i_f).coeff_entier;
        F.moins_d2_qtf(i_f).coeff_quantifie=-F.moins_d2_qtf(i_f).coeff_quantifie;
        F.moins_d2_qtf(i_f).coeff_entier=-F.moins_d2_qtf(i_f).coeff_entier;
        num_cel=string(i_f);
     
       [l_define]=declar_coeff_et_decal(l_define,name_n0(i_f),val_n0(i_f),sval_n0(i_f),name_Ln0(i_f),val_Ln0(i_f),sval_Ln0(i_f));
       [l_define]=declar_coeff_et_decal(l_define,name_n1(i_f),val_n1(i_f),sval_n1(i_f),name_Ln1(i_f),val_Ln1(i_f),sval_Ln1(i_f));
       [l_define]=declar_coeff(l_define,name_LADD(i_f),val_LADD(i_f),sval_LADD(i_f));
       [l_define]=declar_coeff_et_decal(l_define,name_n2(i_f),val_n2(i_f),sval_n2(i_f),name_Ln2(i_f),val_Ln2(i_f),sval_Ln2(i_f));
       [l_define]=declar_coeff_et_decal(l_define,name_md1(i_f),val_md1(i_f),sval_md1(i_f),name_Lmd1(i_f),val_Lmd1(i_f),sval_Lmd1(i_f));
       [l_define]=declar_coeff_et_decal(l_define,name_md2(i_f),val_md2(i_f),sval_md2(i_f),name_Lmd2(i_f),val_Lmd2(i_f),sval_Lmd2(i_f));
     // determination de l'ordre de la cellule
       ordre_cel=0;
       if (celi.n2_qtf.coeff_nul==%f) & (celi.d2_qtf.coeff_nul==%f) then
          ordre_cel=2;
        end
        if (ordre_cel==0)&(celi.n1_qtf.coeff_nul==%f) & (celi.d1_qtf.coeff_nul==%f) then
          ordre_cel=1;
        end
        F.ordre_cel(i_f)=ordre_cel;
        is_z_1=F.l_a0(i_f)==0;
         name_acc_op1(i_f)=[];name_acc_op2(i_f)=[]; 
        if (ordre_cel>=1) then
          name_acc_op1(i_f)='ACC_1_'+string(i_f)+'_'+NAME_FILTER;
          if is_z_1==%t then
            name_acc_op1(i_f)=name_op1+'_'+string(i_f)+'_'+NAME_FILTER;
          end
        end  
        if (ordre_cel>=2) then
          name_acc_op2(i_f)='ACC_2_'+string(i_f)+'_'+NAME_FILTER;
          if is_z_1==%t then
            name_acc_op2(i_f)=name_op2+'_'+string(i_f)+'_'+NAME_FILTER;
          end
        end  
      end //for i_f=1:NB_F,
      i=length(l_define);
      l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
      l_define(length(l_define)+1)='/*    DEFINITION DECALAGE FINAL DU FILTRE ' + NAME_FILTER+' */';
      l_define(length(l_define)+1)='/*---------------------------------------------------------------------------'+' */';
      [l_define]=declar_coeff(l_define,name_L_FINAL,val_L_FINAL,sval_L_FINAL);
      l_declar=list(); // declaration des variables
      l_fct_init=list();
    //------------------------------------------------------------------------------
    // declaration des variables et initialisation
    //------------------------------------------------------------------------------
       i=length(l_declar); 
       i=i+1;l_declar(i)='/*---------------------------------------------------------------'+' */';
       i=i+1;l_declar(i)='/*   DECLARATION DES VARIABLES DES CELLULES DU FILTRE '+NAME_FILTER+' */';
       i=i+1;l_declar(i)='/*---------------------------------------------------------------'+' */';
       i=length(l_fct_init); 
       i=i+1;l_fct_init(i)='/*---------------------------------------------------------------'+' */';
       i=i+1;l_fct_init(i)='/*   INITIALISATION DES VARIABLES DES CELLULES DU FILTRE '+NAME_FILTER+' */';
       i=i+1;l_fct_init(i)='/*---------------------------------------------------------------'+' */';
       i=i+1;l_fct_init(i)='  void init_cellules_'+NAME_FILTER+'(void) {';
  
      for i_f=1:NB_F,
        [l_declar,l_fct_init]=declar_memoires(l_declar,l_fct_init,i_f );
      end //for i_f=1:NB_F,
      i=length(l_fct_init); 
      i=i+1;l_fct_init(i)='  } /* void init_cellules_'+NAME_FILTER+'(void) '+' */';
    //------------------------------------------------------------------------------
    // generation du code a chaque pas d'echantillonnage
    //------------------------------------------------------------------------------
      l_code=list();
      i=length(l_code); 
      i=i+1;l_code(i)='/*---------------------------------------------------------------'+' */';
      i=i+1;l_code(i)='/*   CODAGE EQUATION RECURRENTE DU FILTRE '+NAME_FILTER+' */';
      i=i+1;l_code(i)='/*---------------------------------------------------------------'+' */';
      i=i+1;l_code(i)='  '+int_32+' code_equation_'+NAME_FILTER+'(int_' + nb_bits +' '+name_entree+' ) { /* '+name_entree+' doit etre de module < '+string(MAX_E+1) + ' pour fct. correct'+' */';
      for i_f=1:NB_F,
        [l_code]=code_equation(l_code,i_f );
      end //for i_f=1:NB_F,
      i=length(l_code); 
      i=i+1;l_code(i)='  } /*  '+int_32+' code_equation_'+NAME_FILTER+'(int_' + nb_bits +' '+name_entree+' )'+' */';
    //------------------------------------------------------------------------------
    // generation exemple de test
    //------------------------------------------------------------------------------
      l_main=list();
      i=length(l_main); 
      l_main(length(l_main)+1)='/*---------------------------------------------------------------'+' */';
      l_main(length(l_main)+1)='/*   EXEMPLE D UTILISATION DU FILTRE '+NAME_FILTER+' */';
      l_main(length(l_main)+1)='/*---------------------------------------------------------------'+' */';
      l_main(length(l_main)+1)='  int main () {';
      l_main(length(l_main)+1)='    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS '+' */';
      l_main(length(l_main)+1)='    '+int_16+ ' en ='+string(MAX_E)+'; /* YOU MUST HAVE en < '+string(MAX_E)+' */';
      l_main(length(l_main)+1)='    '+int_32+ ' sn ;';
      l_main(length(l_main)+1)='    init_cellules_'+NAME_FILTER+'();';
      l_main(length(l_main)+1)='    for (n=0;n<NB_ECHS;n++) {';
      l_main(length(l_main)+1)='      /* en = '+string(MAX_E)+' ;'+' */';
      l_main(length(l_main)+1)='      sn =  code_equation_'+NAME_FILTER+'( en ) ;';
      l_main(length(l_main)+1)='    /*  printf(''n=d , sn=d n'',n,sn); je narrive pas a generer les pour-cent avec scilab, modifier manuellement'+' */';
      l_main(length(l_main)+1)='    } /*for (n=0;n<NB_ECHS;n++)'+' */';
      l_main(length(l_main)+1)='  } /* void main '+' */'  ;
    //-----------------------------------------------------------------------
    // ECRITURE FICHIER
    //-----------------------------------------------------------------------
      l_entete=supp_evt_remarks(l_entete);
      f=file('open',NOM_PROGRAMME_EN_C+'.c','unknown'); //open the result file
      for i=1:length(l_entete),
         mfprintf(f,l_entete(i)); // write a line
      end
      l_define=supp_evt_remarks(l_define);
      for i=1:length(l_define),
         mfprintf(f,l_define(i)); // write a line
      end
      l_declar=supp_evt_remarks(l_declar);
      for i=1:length(l_declar),
         mfprintf(f,l_declar(i)); // write a line
      end
      l_fct_init=supp_evt_remarks(l_fct_init);
      for i=1:length(l_fct_init),
         mfprintf(f,l_fct_init(i)); // write a line
      end
      l_code=supp_evt_remarks(l_code);
      for i=1:length(l_code),
         mfprintf(f,l_code(i)); // write a line
      end
      l_main=supp_evt_remarks(l_main);
      for i=1:length(l_main),
         mfprintf(f,l_main(i)); // write a line
      end
      file('close',f); //close the result file
  
    end //if switch_genere_code==%t then
    if (sw_aff_results==%t) &(sw_create_file==%t) then
      f1=file('open',nom_fichier_aff,'unknown'); //open the result file
      for i=1:length(l_aff),
         mfprintf(f1,l_aff(i)); // write a line
      end
      file('close',f1); //close the result file
    end
  endfunction
      function s=chaine_fraction(name,G,K,nv) 
        s=name+'('+nv+') =  ';
        if (K~=1) then
          s= s+string(K)+' . ';
        end
        n=numer(G);n0=coeff(n,0);n1=coeff(n,1);n2=coeff(n,2);
        d=denom(G);d0=coeff(d,0);d1=coeff(d,1);d2=coeff(d,2);
        if (my_degree(n)>0) | (my_degree(d)>0) then
          s=s+' ( ';
          if (n0~=0) then
            s=s+string(n0);
          end
          if (n1~=0) then
            s=s+' + '+string(n1)+ ' .'+nv+' ';
          end
          if (n2~=0) then
            s=s+' + '+string(n2)+ ' .'+nv+'^2 ';
          end
          s=s +' ) / ( ';
          if (d0~=0) then
            s=s+' '+string(d0)+' ';
          end
          if (d1~=0) then
            s=s+' + '+string(d1)+' .'+nv+' ';
          end
          if (d2~=0) then
            s=s+' + '+string(d2)+' .'+nv+'^2 ';
          end
          s=s +') ';
        else 
          s=s+ string(n0/d0); 
        end
      endfunction 
      function new_l=supp_evt_remarks(l)
        if SUPPRESS_REMARQUES==%f then
          new_l=l;
          return
        end
        k=0;new_l=list();
        for i=1:length(l),
          s=l(i);
          s=stripblanks(s,%t);
          index=strindex(s,'/*');
          do_not_suppress= min(index)~= 1 ;
          if do_not_suppress==%t then
            k=k+1;new_l(k)=l(i);
          end
        end // for =1:length(l),
      endfunction
function F=make_as_F(N,D)
  if (typeof(N)=='list') then
    F=list(); 
    fd=definedfields(N);
    if (fd==[]) then
      return;
    end 
    if (min(fd)==0) then
      pause
      F(0)=N(0);// 'paralell' or 'cascade'
    end
    i_fd=find(fd>0);
    fd=fd(i_fd);
    for i=fd,
      F(i)=make_as_F(N(i),D(i));
    end
    return;
  end
  if (my_degree(N)==0)&(my_degree(D)==0) then
    F=coeff(N,0)./coeff(D,0);
    return;
  end
  old_simp_mode=simp_mode();
  simp_mode(%f);
  F=N./D;
  simp_mode(old_simp_mode);
endfunction
function [N,D]=make_as_ND(F)
  if (typeof(F)=='list') then
    N=list();
    D=list();
    fd=definedfields(F);
    if (fd==[]) then
      return;
    end 
    if (min(fd)==0) then
      pause
      N(0)=F(0);// 'paralell' or 'cascade'
      D(0)=F(0);// 'paralell' or 'cascade'
    end
    i_fd=find(fd>0);
    fd=fd(i_fd);
    for i=fd,
      [N(i),D(i)]=make_as_ND(F(i));
    end
    return;
  end
  N=numer(F);
  D=denom(F);
endfunction

function [l_N,l_D]=make_as_list(N,D,simplify)

  [lhs,rhs]=argn(0);
  if (rhs<3) then
    simplify=%f;
  end
   old_simp_mode=simp_mode();
   simp_mode(simplify);
  
  [m,n]=size(N);
  l_N=list();
  l_D=list();
  for i=1:m,
   li_N=list();
   li_D=list();
   for j=1:n,
     if (N(i,j)~=0) then
       Fij=N(i,j)/D(i,j);
       Nij=numer(Fij);
       Dij=denom(Fij);
       li_N(j)=Nij;
       li_D(j)=Dij;
     end
   end
   if (length(li_N)>0) then
     l_N(i)=li_N;
     l_D(i)=li_D;
   end
  end
endfunction
function [Fp_sorted,infos]=sort_filter(Fp,switch_sort)
  [lhs,rhs]=argn(0);
  if (typeof(Fp)~="list") then
    Fp_sorted=Fp;
    return;
  end
  if (rhs<2) then
    switch_sort="well damped first";
  end
  rd=list();
  rn=list();
  re_d=[];re_n=[];
  v_sort=[];
  li=list();
  for i=1:length(Fp),
    d=denom(Fp(i));
    n=numer(Fp(i));   
    s.deg_d=my_degree(d);
    s.z_d=roots(d);
    s.re_d=real(s.z_d);s.im_d=imag(s.z_d);
    s.w_d=abs(s.z_d);
    if (s.deg_d>0) then
      s.csi_d=abs(s.re_d)./(s.w_d);
    else
      s.csi_d=2;
    end
    if (switch_sort=="well damped first") then
      v_sort=[v_sort;min(s.csi_d)];
    end
    if (switch_sort=="bad damped first") then
      v_sort=[v_sort;-min(s.csi_d)];
    end
    li(i)=s;
  end
  [vs,is]=ggsort(v_sort);
  Fp_sorted=list();
  if (lhs>1) then
    infos=list();
  end
  for i=1:length(Fp),
    Fp_sorted(i)=Fp(is(i));
    if (lhs>1) then
      infos(i)=li(is(i));
    end
  end
endfunction
  function write_list_to_file(l_text,file_name)
      f = mopen(file_name,"wt");
      for i=1:length(l_text),
         mfprintf(f,l_text(i)+"\n"); // write a line
      end
      mclose(f); //close the result file
  endfunction
  function li=ident_list(l,s_ident);
    li=list();
    N=definedfields(l);
    for i=N,
      li(i)=s_ident+l(i);
    end
  endfunction


