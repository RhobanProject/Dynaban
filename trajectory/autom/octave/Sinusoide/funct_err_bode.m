function err=funct_err_bode(x)
  K=x(1);
  tau=x(2);
  retard=x(3);
  %retard=0;  
  global result_bode;
  w=2*pi*result_bode.freq_hz;
  m=length(w);
  gain_mes_db=20*log10(result_bode.ampTf);
  arg_mes_dg=result_bode.argTf;
  gain_th=K*sqrt( (1+(tau*w).^2).^-1);
  gain_th_db=20*log10(gain_th);
  arg_th=- 180/pi* ( atan(tau*w) +retard *w );
  arg_th=- 180/pi* ( atan(tau*w) +retard *w );
  err_arg=norm(arg_th-arg_mes_dg)^2;
  err_gain_db=norm(gain_th_db-gain_mes_db)^2 ;
  err=err_gain_db+err_arg; 
end

