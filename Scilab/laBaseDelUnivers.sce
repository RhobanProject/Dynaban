clear;
PWM1 = -200;
PWM2 = -400;
I1inc = 2140;
I2inc = 2250;
I1mA = 98;
I2mA = 184;
G = (I2inc - I1inc)/(PWM2 - PWM1);
FuHz = 100;
Wu = 2*%pi*FuHz;
PhiMax = 30*%pi/180;
// 2*atan(a) - PI/2 = PhiMax
a = tan((PhiMax + %pi/2)/2)
W0 = Wu/a;
W1 = Wu * a;
p = %s
GAIN = 1;
INTEG = 1/p;
INTEG = syslin("c",numer(INTEG), denom(INTEG));
figure(1); clf("reset"); bode(INTEG);
AVP = (p + W0) / (p + W1);
AVP = syslin("c",numer(AVP), denom(AVP));
figure(2); clf("reset"); bode(AVP);

REG = INTEG * AVP;
figure(3); clf("reset"); bode(REG);

gainRegFu = abs(repfreq(REG, FuHz));
GAIN = 1/(gainRegFu*G);
REG = GAIN*INTEG*AVP;
ftbo = REG*G;
figure(4); clf("reset"); bode(ftbo);

// Partie 2 calcul du régulateur en z

