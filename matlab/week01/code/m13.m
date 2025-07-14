clear all; clc; close all;

syms x X n z

X1 = z/(2*(z^2-(3*z)/2+1/2));
x = iztrans(X1)
X = ztrans(x, z)

n = 0:1:3;
Omg=[-pi:2*pi/100:pi];
subplot(1,1,1); stem(n,subs(x, n)); xlabel("n"); ylabel("x[n]"); grid on;
%subplot(3,1,2); plot(Omg/pi,abs(subs(X,exp(1j*Omg)))); xlabel("\Omega"); ylabel("|X(\Omega)|"); grid on;

% ==============================================

clear all; clc; close all;
syms x X n z

X2 = -(2*z^3+3*z^2-z)/(-z^3-z^2+z+1);
x = iztrans(X2)
X = ztrans(x, z)

n = 0:1:3;
subplot(1,1,1); stem(n,subs(x, n)); xlabel("n"); ylabel("x[n]"); grid on;
%subplot(3,1,2); plot(Omg/pi,abs(subs(X,exp(1j*Omg)))); xlabel("\Omega"); ylabel("|X(\Omega)|"); grid on;

% ==============================================

clear all; clc; close all;
syms x X n z

X3 = (z*(2*z^2-11*z+12))/((z-1)*(z-2)^3);
x = iztrans(X3)
X = ztrans(x, z)

n = 0:1:3;
%Omg=-pi:2*pi/100:pi;
subplot(1,1,1); stem(n,subs(x, n)); xlabel("n"); ylabel("x[n]"); grid on;
%subplot(3,1,2); plot(Omg/pi,abs(subs(X3,exp(1j*Omg)))); xlabel("\Omega"); ylabel("|X(\Omega)|"); grid on;

% ==============================================

clear all; clc; close all;

syms x X n z

X4 = (z*(4*z+3^(1/2)-1))/(4*z^2-2*z+1)
x = iztrans(X4)
X = ztrans(x, z)

n=0:1:3;
Omg=-pi:2*pi/100:pi;
subplot(3,1,1); plot(Omg/pi,abs(subs(X4,exp(1j*Omg)))); xlabel("\Omega"); ylabel("|X(\Omega)|"); grid on;
subplot(3,1,2); stem(n,subs(x, n)); xlabel("n"); ylabel("x[n]"); grid on;
subplot(3,1,3); plot(Omg/pi,abs(subs(X,exp(1j*Omg)))); xlabel("\Omega"); ylabel("|X(\Omega)|"); grid on;
