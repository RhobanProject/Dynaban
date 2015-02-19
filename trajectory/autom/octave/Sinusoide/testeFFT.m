clear all;
close all;
clc;
N_FFT=8192;
N=30;
Te=0.1;
Fe=1/Te;
f=Fe/20;
Amp=10;
n=(0:(N-1)).';
y=Amp*sin(2*pi*n*f*Te);
figure();
plot(n,y);
% fft
% zero padding
y_pad=zeros(N_FFT,1);
y_pad(1:N)=y;
% calc fft
fft_y_pad=fft(y_pad);
% selection f<fe/2
f_hz=Fe*(0:(N_FFT-1))/N_FFT;
kf=find(f_hz<Fe/2);
f_hz=f_hz(kf);
fft_y_pad=fft_y_pad(kf);
%tracé module
figure();
coeff=1/N;
plot(f_hz,abs(fft_y_pad)*coeff*2/N);
