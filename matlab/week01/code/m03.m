clear all;
clc;

Ts = 1;
n = -10:Ts:10;

x = cos(pi*n/8); % Generate a time signal
subplot(4, 1, 1); stem(n, x, 'k-'); grid on;
ylim([-1 1]); xlabel('n');

n0 = -10:0.1:10;

x0 = upsample(x,10);
x1 = x0(:,1:201);
subplot(4, 1, 2); stem(n0, x1, 'k'); grid on;
ylim([-1 1]); xlabel('n');

x2 = (n0>=0) - (n0-1>=0);  %((n0>=0) & (n0<1))
subplot(4, 1, 3); plot(n0, x2, 'k'); grid on;
ylim([0 1]); xlabel('t');

x3 = conv(x1,x2, 'same');
subplot(4, 1, 4); plot(n0, x3, 'k'); grid on;
ylim([-1 1]); xlabel('t');
