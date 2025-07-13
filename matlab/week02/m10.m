clear,clc;

M = 20;
n = -M:1:M;
h1_n = sinc(n/10);
w1_n = (n+M>=0)-(n-M>0);
w2_n = (n+M)/M.*(n<0 & n>=-M)+(M-n)/M.*(n>=0 & n<=M);
w3_n = 0.5 + 0.5*cos(n*pi/M).*(n>=0 & n<=M) + 0.5*cos(n*pi/M).*(n<0 & n>=-M);
w4_n = 0.54 + 0.46*cos(n*pi/M).*(n>=0 & n<=M) + 0.46*cos(n*pi/M).*(n<0 & n>=-M);
w5_n = 0.42 + 0.5*cos(n*pi/M).*(n>=0 & n<=M) + 0.08*cos(n*2*pi/M).*(n>=0 & n<=M) + 0.5*cos(n*pi/M).*(n<0 & n>=-M) + 0.08*cos(n*2*pi/M).*(n<0 & n>=-M);

H1 = h1_n .* w1_n;
H2 = h1_n .* w2_n;
H3 = h1_n .* w3_n;
H4 = h1_n .* w4_n;
H5 = h1_n .* w5_n;

N = length(n); 
omega = linspace(0, 2*pi, 30000);

L = length(omega);
f = (-L/2:L/2-1) / L + 0.5;

hanning_window = hanning(L);
hamming_window = hamming(L);
blackman_window = blackman(L);

H1_fft = fft(H1, L);
H2_fft = fft(H2, L);
H3_fft = fft(H3, L);
H4_fft = fft(H4, L);
H5_fft = fft(H5, L);

H1_dB = 20 * log10(abs(H1_fft) / 9);
H2_dB = 20 * log10(abs(H2_fft) / max(abs(H2_fft)));
H3_dB = 20 * log10(abs(H3_fft) / max(abs(H3_fft)));
H4_dB = 20 * log10(abs(H4_fft) / max(abs(H4_fft)));
H5_dB = 20 * log10(abs(H5_fft) / max(abs(H5_fft)));

plot(f, H1_dB,'k'); xlim([0 0.5]); ylim([-100, 10]);
grid on; hold on;

plot(f, H2_dB,'k:'); xlim([0 0.5]); ylim([-100, 10]);
grid on; hold on;

plot(f, H3_dB, 'k--'); xlim([0 0.5]); ylim([-100, 10]);
grid on; hold on;

plot(f, H4_dB, 'k-.'); xlim([0 0.5]); ylim([-100, 10]);
grid on; hold on; 

plot(f, H5_dB, 'k'); xlim([0 0.5]); ylim([-100, 10]);
grid on; hold on;

legend('rectangular','triangular', 'hanning', 'hamming', 'blackman');

