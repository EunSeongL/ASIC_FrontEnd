clear all; clc; clear figure;
L = 10;      % 출력을 얻고 싶은 길이 = 반복 횟수
f0 = 1;      %기본 주파수 값  
Ts = 1/50;   %시간 샘플링
fs = 1/Ts;      %주파수 샘플링
t = 0:Ts:L-Ts;    % 0 부터 L-Ts 까지 시간 범위 설정
x = cos(2*pi*f0*t);     % 입력 신호 1x500
n = length(x);              % 신호 길이 500개
f = (-n/2:n/2-1)*(fs/n);    % 주파수 축 설정 -25 ~ 24.9
% circshift = 순환시프트함수, %floor = 내림 함수

X = MyyDft(x);
f_shift = circshift(f, [0, floor(n/2)]); %주파수 축 이동 시킴

%f_shift = abs(fftshift(X));
subplot(2, 1, 1); plot(t, x, 'b'); legend('f_{0}=1'); xlabel('t'); ylabel('x(t)=cos(2\pif_{0}t)'); grid on; hold on;

subplot(2, 1, 2); plot(f_shift, n*abs(X), 'b'); legend('f_{0}=1'); xlabel('f');
%subplot(2, 1, 2); plot(f, n*f_shift, 'b'); legend('f_{0}=1'); xlabel('f');
ylabel('|X(f)| = |0.5[\delta(f+f_{0})+\delta(f-f_{0})]|'); grid on; hold on;

function X = MyyDft(x)              %입력신호의 개수만큼 반복시키는 함수
    n = length(x);
    X = zeros(1, n);       %0패딩 입력신호 길이 만큼
    for k = 1:n
        X(k) = sum(x .* transpose(exp(-1j*2*pi*(k-1)*transpose(circshift(floor(0:n-1), -1))/n)));
    end
    X = X/n;    %표본의 개수 만큼 나눔
end

% ==============================================
