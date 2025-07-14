clear, clc;

n = -9:1:9;
xn = (n>=-2)&(n<=2);
omega = -pi:0.001*pi:pi;

subplot(3,1,1); stem(n,xn,'b-'); grid on;
ylim([0 1]); xlabel('n'); ylabel('x[n]');

X = xn*exp(-1j*omega.*(2*n)');

subplot(3,1,2); plot(omega/pi,abs(X),'b-'); grid on;
ylim([0 5]); xlabel('omega/2pi'); ylabel('|X(omega)|');

Xomega = angle(X);
subplot(3,1,3); plot(omega/pi, Xomega, 'b'); grid on;
ylim([0 pi]); xlabel('omega/2pi'); ylabel('<Xk');

% ==============================================

clear, clc;

n = -9:1:9;
omega = -pi:0.001*pi:pi-0.001*pi;
L = 4;

Xomega = (L+1)*diric(2*omega, L+1);
subplot(3,1,1); plot(omega/pi,abs(Xomega)); ylim([0 5]);

Xangle = angle(Xomega);
subplot(3,1,2); plot(omega/pi, Xangle, 'b'); grid on;
ylim([0 pi]); xlabel('omega/2pi'); ylabel('<Xk');

xn = 1/2*pi * Xomega*exp(1j.*2*omega'*n)/(pi*1000);
subplot(3,1,3); stem(n, xn, 'b'); grid on; xlabel('n'); ylabel('<Xk');
ylim([0 1]);
