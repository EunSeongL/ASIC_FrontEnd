clear all; clc;
b = [1 1 1]; % 분자 계수
a = [1 0 0]; % 분모 계수

subplot(2, 1, 1);
pzmap(b, a);
hold on;

theta = linspace(0, 2*pi);
r = 1;
x = r*cos(theta);
y = r*sin(theta);
plot(x, y, 'k');
text(-0.1, 0.3, '(2)', 'FontSize', 12);
axis equal;
xlim([-1.2 1.2]);
ylim([-1.2 1.2]);

subplot(2, 1, 2);
N = 10; 
impz(b, a, N);
