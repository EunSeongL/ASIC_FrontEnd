clear all; clc;

for n=1:1:3
 m=power(2,n-1);
 Ts=0.1*m;
 t=[-2:Ts:2];

 
 
 x = (t>-0.5)&(t<=0.5); % 시간 신호 생성
 subplot(3,2,2*n-1); stem(t, x, 'k:');
 grid on; ylim([-0.2 1.2]); xlabel('t[sec]');
 title(['T_s=', num2str(Ts), '[sec], f_s=', num2str(1/Ts), '[Hz]']);
 f=[-5:0.001:5];
 
 
 X = x*exp(-1j*(t'/Ts)*2*pi*f*Ts)*Ts;% 푸리에 변환
 subplot(3,2,2*n); plot(f, abs(X), 'k');
 grid on; xlim([-5 5]); ylim([-0.2 1.2]);
 xlabel('f[Hz]'); title('under-sampling1');
end
