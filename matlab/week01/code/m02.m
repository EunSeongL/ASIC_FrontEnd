clear, clc;

Ts=0.05;
t=[-2:Ts:2];

x = (t>=-0.5)&(t<=0.5); % 시간 신호 생성
subplot(3,1,1); stem(t, x, 'k:');
grid on; ylim([0 1]); xlabel('t[sec]');
title(['T_s=', num2str(Ts), '[sec], f_s=', num2str(1/Ts), '[Hz]']);

X = 10*sinc(10*t)*Ts;
subplot(3,1,2); plot(t, X, 'k');
grid on; xlim([-2 2]); ylim([-0.1 0.5]);

X1 = conv(x,X, 'same');
subplot(3,1,3); plot(t, X1, 'k');
grid on; xlim([-2 2]); ylim([-0.1 1.2]);
