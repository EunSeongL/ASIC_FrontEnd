clear, clc;

ts = 1;
n = 0:ts:3;
k = 0:ts:3;
w0 = 2*pi/4;    

x_n = n==0;

figure(1);

subplot(3,1,1); stem(n,x_n, 'b'); grid on;
ylim([0 1]); xlabel('n'); ylabel('x[n]');

Xk = (x_n * exp(-1j*k.*n'*w0) )* 1/4;

subplot(3,1,2); stem(k,Xk, 'b'); grid on;
ylim([0 0.25]); xlabel('k'); ylabel('|Xk|');


AXk = angle(Xk);
subplot(3,1,3); stem(k,AXk, 'b'); grid on;
ylim([-1 1]); xlabel('k'); ylabel('<Xk');

# ==============================================

clear, clc;

ts = 1;
n = 0:ts:3;
k = 0:ts:3;
w0 = 2*pi/4;    

figure(2);
x_n = n==0;
Xk = (x_n * exp(-1j*k.*n'*w0) )* 1/4;

subplot(3,1,1); stem(k,Xk, 'b'); grid on;
ylim([0 0.25]); xlabel('k'); ylabel('|Xk|');


AXk = angle(Xk);
subplot(3,1,2); stem(k,AXk, 'b'); grid on;
ylim([-1 1]); xlabel('k'); ylabel('<Xk');

x_n0 = Xk * exp(1j*k*w0.*n');
subplot(3,1,3); stem(n,x_n0, 'b'); grid on;
ylim([0 1]); xlabel('n'); ylabel('x[n]');
