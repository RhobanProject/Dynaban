function [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_modulated_form(lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z)
  switch_form="df2t";
  b0x=real(b0x);
  b1x=real(b1x);
  b2x=real(b2x);
  a1x=real(a1x);
  a2x=real(a2x);
  if (b2x~=0)|(a2x~=0) then
     order=2;
  elseif (b1x~=0)|(a1x~=0)
    order=1;
  else
    order=0;
  end
  if (order<=1) then
  // modulated form useful only for order 2
     [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_direct_form(switch_form,lambda,..
        b0x,b1x,b2x,a1x,a2x,..
        b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
        b0x_de_z,a0x_de_z);
     return;  
  end
  x=poly(0,'x');
  z=poly(0,'z');
  oms=simp_mode();
  simp_mode(%f);
  x_de_z=b0x_de_z/(z+a0x_de_z);
  F_de_x=(b0x+b1x*x+b2x*x^2)/(1+a1x*x+a2x*x^2);
  F_de_z=hornerij(F_de_x,x_de_z,"hd");
  [A,rho,theta,phi,D]=params_modulated_form(F_de_z);
  z_de_x=horner11_inv(x_de_z)
  Fz=get_Fz(A,rho,theta,phi,D);
  A=real(A);rho=real(rho);
  F_interne_x=hornerij(A*z/(z-rho),z_de_x,"ld");
  b0x=coeff(numer(F_interne_x),0);
  b1x=coeff(numer(F_interne_x),1);
  a1x=coeff(denom(F_interne_x),1);
  b2x=0;a2x=0;
  [Nz,Dz,Nw,Dw,Nz_1,Dz_1]=clc_direct_form(switch_form,lambda,..
     b0x,b1x,b2x,a1x,a2x,..
     b0Fqz,b1Fqz,a0Fqz,a1Fqz,..
     b0x_de_z,a0x_de_z);
  Nz(1)(1)=numer(Fz);
  Dz(1)(1)=denom(Fz);
  l=max(definedfields(Nz(1)));
  Nz(1)(l+1)=1/lambda;
  Dz(1)(l+1)=1;
  Fz=make_as_F(Nz,Dz);
  w=poly(0,'w');
  z_de_w=(1+w)/(1-w);
  Fw=hornerij(Fz,z_de_w,'hd');
  [Nw,Dw]=make_as_ND(Fw);
  z_1=poly(0,'z_1');
  z_de_z_1=1/z_1;
  Fz_1=hornerij(Fz,z_de_z_1,'ld');
  [Nz_1,Dz_1]=make_as_ND(Fz_1);
  simp_mode(oms);
endfunction
function Fz=get_Fz(A,rho,theta,phi,D)
  z=poly(0,'z');
  Dz_plus=(z-rho*exp(%i*theta));
  Dz_moins=(z-rho*exp(-%i*theta));
  Dz=Dz_plus*Dz_moins;
// NzF = Numerateur de Tr en Z de A.rho^n.cos(n.theta+phi)
  NzF=(A*exp(%i*phi)*z*Dz_moins+A*exp(-%i*phi)*z*Dz_plus)/2;
  Nz=D*Dz+NzF;
  osm=simp_mode();
  simp_mode(%f);
  Fz=real(Nz)/real(Dz);
  simp_mode(osm);
endfunction
function   [A,rho,theta,phi,D]=params_modulated_form(Fz);
  Nz=numer(Fz);
  Dz=denom(Fz);
  a2=coeff(Dz,2);
  b0=coeff(Nz,0)/a2;
  b1=coeff(Nz,1)/a2;
  b2=coeff(Nz,2)/a2;
  a0=coeff(Dz,0)/a2;
  a1=coeff(Dz,1)/a2;
  a2=1;
  pz=roots(Dz);
  pz=pz(1);
  rho=abs(pz(1));
  theta=imag(log(pz(1)));
  D=b0/a0;
  b2=b2*a0-a2*b0;
  b1=b1*a0-a1*b0;
  b0=0;
  y=rho*cos(theta)*b2+b1;
  x=rho*sin(theta)*b2;
  if (abs(y)>=1e15*abs(x)) then
    phi=-sign(y*x)*%pi/2;
    A=-b1/(rho*cos(theta-phi));
    return
  end
  phi=-atan(y/x);
  A=b2/cos(phi);
endfunction


