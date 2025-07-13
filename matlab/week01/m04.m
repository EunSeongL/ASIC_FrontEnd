clear all;
clc;

Ts = 1;
n = -10:Ts:10;

x = cos(pi*n/8);
subplot(4,1,1); stem(n,x,'b-'); grid on;
ylim([-1 1]); xlabel('n'); ylabel('cos(pi*n/8)'); 
legend('original discrete sequence');

n0 = -10:0.1:10;

x0 = upsample(x, 10);
x1 = x0(:,1:201);
subplot(4,1,2); stem(n0,x1,'b'); grid on;
ylim([-1 1]); xlabel('n'); ylabel('cos(pi*n/8)');
legend('unsampled sequence');

x2 = (n0+1>=0).*(n0+1) - (n0>=0).*(2*n0) + (n0-1>=0).*(n0-1);
subplot(4,1,3); plot(n0,x2, 'b'); grid on;
ylim([0 1]); xlabel('t'); ylabel('tri(t)');
legend('impulse response of 1st-order holder');

x3 = conv(x1,x2, 'same');
subplot(4,1,4); plot(n0, x3, 'b'); grid on;
ylim([-1 1]); xlabel('t'); ylabel('cos(pi*t)/8');
legend('1st-order holder output');
