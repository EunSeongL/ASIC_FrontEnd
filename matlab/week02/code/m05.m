clear all; clc;

b = [1 1 1]; 
a = [1 0 0]; 
omega = -pi:0.01*pi:pi;
subplot(2, 2, 1);
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

subplot(2, 2, 2);
N = 10; 
impz(b, a, N);

subplot(2, 2, 3);
[h, w] = freqz(b, a, omega);
plot(w/(2*pi), abs(h));
hold on;

s = angle(h);
subplot(2, 2, 4);
plot(w/(2*pi), s);
ylim([-2.1 2.1]);
hold on;
