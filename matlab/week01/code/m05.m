clear all;
clc;

Ts = 1;
n = 0:Ts:20;

x = n>=0; % Generate a time signal
subplot(3, 1, 1); stem(n, x, 'k-'); grid on;
ylim([0 1]); xlabel('n');

x1 = (0.5).^n.*x; 
subplot(3, 1, 2); stem(n, x1, 'k-'); grid on;
ylim([0 1]); xlabel('n');

x2 = conv(x,x1);
x3 = x2(:,1:21);
subplot(3, 1, 3); stem(n, x3, 'k-'); grid on;
ylim([0 2]); xlabel('n');
