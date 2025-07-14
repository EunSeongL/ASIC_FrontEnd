clear all; clc;

b = [1 1 1]; 
a = [1 0 0]; 
n = 0:1:99;

omega = -pi:0.02*pi:pi-(0.02*pi);

subplot(4, 4, 1);
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

subplot(4, 4, 2);
N = 10; 
impz(b, a, N);

subplot(4, 4, 3);
[h, w] = freqz(b, a, omega);
plot(w/(2*pi), abs(h));
hold on;

s = angle(h);
subplot(4, 4, 4);
plot(w/(2*pi), s);
ylim([-2.1 2.1]);
hold on;

x1 = cos(2*pi*n);
subplot(4, 4, 5); stem(n, x1);
hold on;

x2 = cos(pi/2*n);
subplot(4, 4, 9); stem(n, x2);
hold on;

x3 = cos(pi*n);
subplot(4, 4, 13); stem(n, x3);
hold on;

n1 = length(x1);
n2 = length(x2);
n3 = length(x3);

X1 = fft(x1);
X2 = fft(x2);
X3 = fft(x3);

X1 = abs(fftshift(X1));
X2 = abs(fftshift(X2));
X3 = abs(fftshift(X3));

f1 = linspace(-0.5, 0.5, n1);
f2 = linspace(-0.5, 0.5, n2);
f3 = linspace(-0.5, 0.5, n3);

subplot(4,4,6); plot(f1, X1/n1);
hold on;
subplot(4,4,10); plot(f2, X2/n2);
hold on;
subplot(4,4,14); plot(f3, X3/n3);
hold on;

y1 = filter(b, a, x1);
y2 = filter(b, a, x2);
y3 = filter(b, a, x3);

subplot(4, 4, 7); stem(n, y1);
hold on;
subplot(4, 4, 11); stem(n, y2);
hold on;
subplot(4, 4, 15); stem(n, y3);
hold on;

Y1 = abs(h).*(X1/n1);
subplot(4,4,8); plot(f1, Y1);
hold on;

Y2 = abs(h).*(X2/n2);
subplot(4,4,12); plot(f2, Y2);
hold on;

Y3 = abs(h).*(X3/n3);
subplot(4,4,16); plot(f3, Y3);
hold on;
