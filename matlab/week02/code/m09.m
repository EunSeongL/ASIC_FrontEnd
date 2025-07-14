clear,clc;

n = -30:0.001:30;
n1 = -20:0.001:20;

M=20; 
w1_n=(n+M>=0)-(n-M>0);
w2_n=(n+M)/M.*(n<0 & n>=-M)+(M-n)/M.*(n>=0 & n<=M);

plot(n, w1_n , 'k'); xlim([-30 30]); ylim([-0.1 1.1]);
grid on; hold on; 

plot(n, w2_n , 'k:'); xlim([-30 30]); ylim([-0.1 1.1]);
grid on; hold on;

L = length(n1);
hanning_window = hanning(L);
hamming_window = hamming(L);
blackman_window = blackman(L);

plot(n1,  hanning_window, 'k--'); xlim([-30 30]); ylim([-0.1 1.1]);
grid on; hold on;

plot(n1,  hamming_window, 'k-.'); xlim([-30 30]); ylim([-0.1 1.1]);
grid on; hold on; 

plot(n1,  blackman_window, 'k'); xlim([-30 30]); ylim([-0.1 1.1]);
grid on; hold on;
legend('rectangular','triangular', 'hanning', 'hamming', 'blackman');
