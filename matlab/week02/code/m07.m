clear all; clc; clear figure; close all;

N = 10;
b = [1 0 0 0 0 0 0 0 0 0 0 -1];
a = [1 -1 0 0 0 0 0 0 0 0 0 0];

n = 0:1:99;
omega = -pi:0.02*pi:pi-(0.02*pi);

subplot(2, 4, 1);
pzmap(b, a);
hold on;

theta = linspace(0, 2*pi);
r = 1;
x = r*cos(theta);
y = r*sin(theta);
plot(x, y, 'k');

axis equal;
xlim([-1.2 1.2]);
ylim([-1.2 1.2]);

subplot(2, 4, 2); 
impz(b, a, N);

subplot(2, 4, 3);
[h, w] = freqz(b, a, omega);
plot(w/(2*pi), abs(h));
ylim([0 11]); grid on;
hold on;

s = angle(h);
subplot(2, 4, 4);
plot(w/(2*pi), s);
ylim([-2.8 2.8]); grid on;
hold on;

xn = cos(0.01*pi*n) + cos(0.05*pi*n - pi/3) + cos(0.3*pi*n + pi/4);
subplot(2,4,5); stem(n,xn);hold on; grid on;

n1 = length(xn);
Xn = fft(xn);
Xn = abs(fftshift(Xn));
fn = linspace(-0.5, 0.5, n1);
subplot(2,4,6); plot(fn, Xn/n1); hold on; grid on;

y = filter(b, a, xn./N);
subplot(2, 4, 7); stem(n, y);
hold on;

Y = (abs(h).*(Xn/n1))./N;
subplot(2,4,8); plot(fn, Y);
hold on;

% ==============================================

clear all; clc; clear figure; close all;

n = 0:1:99;
omega = -pi:0.02*pi:pi-(0.02*pi);
fs = 600;

b = [10.5000 -49.3049 107.2669 -136.5998 107.2669 -49.3049 10.5000];
a = [1 -4.2261 8.2749 -9.4839 6.7026 -2.7728 0.5314];
H = tf(b, a, 1/fs);
subplot(2,4,1); 
pzmap(b, a); 
hold on;

theta = linspace(0, 2*pi);
r = 1;
x = r*cos(theta);
y = r*sin(theta);
plot(x, y, 'k');

axis equal;
xlim([-1.2 1.2]);
ylim([-1.2 1.2]);

subplot(2, 4, 2); 
impz(b./10.5, a, 10);

subplot(2, 4, 3);
[h, w] = freqz(b./10.5, a, omega);
plot(w/(2*pi), abs(h));
hold on; grid on;

s = angle(h);
subplot(2, 4, 4);
plot(w/(2*pi), s);
ylim([-2.1 2.1]); grid on;
hold on;

xn = 1+0.6*cos(0.1*pi*n) + 0.2*cos(0.2*pi*n) + 0.1*cos(0.3*pi*n);
subplot(2,4,5); stem(n,xn);hold on; grid on;

n1 = length(xn);
Xn = fft(xn);
Xn = abs(fftshift(Xn));
fn = linspace(-0.5, 0.5, n1);
subplot(2,4,6); plot(fn, Xn/n1); hold on; grid on;

y = filter(b./10.5, a, xn./10);
subplot(2, 4, 7); stem(n, y); grid on;
hold on;

Y = abs(h).*(Xn/n1);
subplot(2,4,8); plot(fn, Y./10); grid on;
hold on;
