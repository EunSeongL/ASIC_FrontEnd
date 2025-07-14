clear, clc;

n0 = 0:1:10;
n = 0:1:10;
%sympref('HeavisideAtOrigin',1);
x_n = heaviside(n);
subplot(1,2,1); stem(n, x_n); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on; hold on;

syms n 
x_n = heaviside(n);
x_z = ztrans(x_n);

z_1 = iztrans(x_z);
x_n0 = subs(z_1, n0); 

x_n0_double = double(x_n0);
subplot(1,2,2); stem(n0, x_n0_double); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on;

% ==============================================

clear, clc;

n = 0:1:10;
n0 = 0:1:10;
omega = -pi:0.001*pi:pi;

x_n0 = (1/2).^n.*heaviside(n);
subplot(1,3,1); stem(n, x_n0); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on;

syms n
x_n0 = (1/2).^n.*heaviside(n);
x_z = ztrans(x_n0);
z = exp(1j*omega);
X_z = subs(x_z, z);         %x_z식에 z값 대입
subplot(1,3,2); plot(omega/pi, abs(X_z)); xlabel('\Omega/\pi'); ylabel('|X(\Omega)|'); xlim([-1 1]); ylim([0.5 2]); grid on;

z_1 = iztrans(x_z);
x_n1 = subs(z_1, n0); 

x_n0_double = double(x_n1);
subplot(1,3,3); stem(n0, x_n0_double); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on;

% ==============================================

clear, clc;

n = 0:1:10;
n0 = 0:1:10;
omega = -pi:0.001*pi:pi;

x_n0 = (1/2).^n.*n.*heaviside(n);
subplot(1,3,1); stem(n, x_n0); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on;

syms n
x_n0 = (1/2).^n.*n.*heaviside(n);
x_z = ztrans(x_n0);
z = exp(1j*omega);
X_z = subs(x_z, z);         %x_z식에 z값 대입
subplot(1,3,2); plot(omega/pi, abs(X_z)); xlabel('\Omega/\pi'); ylabel('|X(\Omega)|'); xlim([-1 1]); ylim([0 2]); grid on;

z_1 = iztrans(x_z);
x_n1 = subs(z_1, n0); 
x_n0_double = double(x_n1);
subplot(1,3,3); stem(n0, x_n0_double); xlabel('n'); ylabel('x[n]'); ylim([0 1]); grid on;

