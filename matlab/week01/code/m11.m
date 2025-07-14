clear, clc;

n = -5:1:5;
x_n = (n>=-1) & (n<=1);
subplot(4, 1, 1);
ylim([0 1]); stem(n, x_n); grid on; xlabel('n'); ylabel('x[n]');

x_n1 = upsample(x_n, 2);
x_n2 = x_n1(:,6:16);
subplot(4, 1, 2);
ylim([0 1]); stem(n, x_n2); grid on; xlabel('n'); ylabel('x[n/2]');

omega = -pi:0.01*pi:pi;
pF = 0:0.01*pi:pi;
X = x_n*exp(-1j*omega.*(2*n)');
XF = X(:,101:201);
subplot(4,1,3); plot(pF/pi,abs(XF),'b-'); grid on;
ylim([0 3]); xlabel('F'); ylabel('|X(F)|');

X1 = x_n2*exp(-1j*omega.*(2*n)');
X2F = X1(:,101:201);
subplot(4,1,4); plot(pF/pi,abs(X2F),'b-'); grid on;
ylim([0 3]); xlabel('F'); ylabel('|X(2F)|');

% ==============================================

clear, clc;

n = 0:1:9;
n0 = 0:1:9;

b = [1 0];          %출력 x계수 -> x[n]
a = [1 -0.8];       %출력 y계수 -> y[n]-0.5y[n]

a1 = [1 0.8];

x = dimpulse(b,a,n);
subplot(5, 2, 1); stem(n, x, 'b-'); grid on;
ylim([0 1]); xlim([0 10]); xlabel('n'); ylabel('h_1[n]');

x1 = dimpulse(b,a1,n);
subplot(5, 2, 2); stem(n, x1, 'b-'); grid on;
ylim([-1 1]); xlim([0 10]); xlabel('n'); ylabel('h_2[n]'); 

[h,w] = freqz(b,a,512);
subplot(5, 2, 3); plot(w, h, 'b-'); grid on;
ylim([0 5]); xlim([0 pi]); xlabel('\Omega'); ylabel('|H_1(\Omega)|');

[h0,w0] = freqz(b,a1,512);
subplot(5, 2, 4); plot(w0, h0, 'b-'); grid on;
ylim([0 5]); xlim([0 pi]); xlabel('\Omega'); ylabel('|H_2(\Omega)|');

s = angle(h);
subplot(5, 2, 5); plot(w, s, 'b-'); grid on;
ylim([-1 0]); xlim([0 pi]); xlabel('\Omega'); ylabel('\angleH_1(\Omega)');

s1 = angle(h0);
subplot(5, 2, 6); plot(w0, s1, 'b-'); grid on;
ylim([0 1]); xlim([0 pi]); xlabel('\Omega'); ylabel('\angleH_2(\Omega)');

x = n>=0;
x_n = (0.8).^n.*x;
[H,n] = impz(x_n,a);
subplot(5, 2, 7); stem(n(1:10), H(1:10), 'b-'); grid on;
ylim([0 2.1]); xlim([0 10]); xlabel('n'); ylabel('y_1[n]');

[H,n] = impz(x_n,a1);
subplot(5, 2, 8); stem(n(1:10), H(1:10), 'b-'); grid on;
xlim([0 10]); ylim([0 1]); xlabel('n'); ylabel('y_2[n]');

x_y = (-0.8).^n0.*x;
x_n1 = x_y(:,1:10);
[H0,n0] = impz(x_n1,a);
subplot(5, 2, 9); stem(n0(1:10), H0(1:10), 'b-'); grid on;
xlim([0 10]); ylim([0 1]); xlabel('n'); ylabel('y_1[n]');

[H0,n0] = impz(x_n1,a1);
subplot(5, 2, 10); stem(n0(1:10), H0(1:10), 'b-'); grid on;
xlim([0 10]); ylim([-2.1 2.1]); xlabel('n'); ylabel('y_2[n]');
