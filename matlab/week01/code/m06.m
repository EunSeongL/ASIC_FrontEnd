clear, clc;

Ts = 1;
n = 0:Ts:19;

b = [1 0];          %출력 x계수 -> x[n]
a = [1 -0.5];       %출력 y계수 -> y[n]-0.5y[n]

x = dimpulse(b,a,n);
subplot(5, 1, 1); stem(n, x, 'b-'); grid on;
ylim([0 1]); xlabel('n'); 
legend('impulse response');

imp = [1; zeros(19,1)];
h = filter(b,a,imp);
subplot(5, 1, 2); stem(n, h, 'b-'); grid on;
ylim([0 1]); xlabel('n'); 
legend('impulse response using "filter" fuction');

i = impz(b,a,n);
subplot(5, 1, 3); stem(n, i, 'b-'); grid on;
ylim([0 1]); xlabel('n');
legend('impulse response using "impz" fuction');

d = dstep(b,a,n);
subplot(5, 1, 4); stem(n, d, 'b-'); grid on;
ylim([0 2]); xlabel('n');
legend('step response');

f = filter(b,a,n>=0);
subplot(5, 1, 5); stem(n, f, 'b-'); grid on;
ylim([0 2]); xlabel('n');
legend('step response using "filter" fuction');
