clear all; clc; close all;

n = 0:1:9;
num = [0 0.5 0];
den = [1 -1.5 0.5];
impulse_sig = (n==0);

syms z X 

H_z = 0.5*z/(z^2-1.5*z+0.5);
X = iztrans(H_z);            % 전달함수 역변환

[coef, pole, direct] = residuez(num, den); %coef = 부분분수 분자의 상수, %pole = 부분분수 분모의 극

y = filter(num, den, impulse_sig);

subplot(2,1,1); zplane(num, den); xlim([-3 3]); ylim([-1.1 1.1]); title('극점-영점 플롯');grid on; hold on;
subplot(2,1,2); stem(n,y); xlim([0 10]); ylim([0 1]);grid on; hold on;
subplot(2,1,2); stem(n,subs(X,n),'k-*');legend('x_{anal}','x_{simul}'); grid on; hold on;
figure; freqz(num, den); grid on; hold on;

% ==============================================

clear all; clc; close all;

n = 0:1:9;
num = [2 3 -1 0];
den = [1 1 -1 -1];
impulse_sig = (n==0);

syms z X 

X_z = (2*z^3+3*z^2-z)/(z^3+z^2-z-1);
X = iztrans(X_z);                   % 전달함수 역변환

y = filter(num, den, impulse_sig);

[coef, pole, direct] = residuez(num, den); %coef = 부분분수 분자의 상수, %pole = 부분분수 분모의 극

subplot(2,1,1); zplane(num, den); xlim([-3 3]); ylim([-1.1 1.1]); title('극점-영점 플롯');grid on; hold on;
subplot(2,1,2); stem(n,y); xlim([0 10]); ylim([-6 10]);grid on; hold on;
subplot(2,1,2); stem(n,subs(X,n),'k-*');legend('x_{anal}','x_{simul}'); grid on; hold on;

figure; freqz(num, den); grid on; hold on;

% ==============================================

clear all; clc; close all;

n = 0:1:9;
num = [0 2 -11 12 0];
den = [1 -7 18 -20 8];    %4차
impulse_sig = (n==0);

syms z X

X_z = (z*(2*z^2-11*z+12))/((z-1)*(z-2)^3);
X = iztrans(X_z);                   % 전달함수 역변환

[coef, pole, direct] = residuez(num, den); %coef = 부분분수 분자의 상수, %pole = 부분분수 분모의 극
y = filter(num, den, impulse_sig);

subplot(2,1,1); zplane(num, den); xlim([-2 5]); ylim([-1.1 1.1]); title('극점-영점 플롯');grid on; hold on;
subplot(2,1,2); stem(n,y); xlim([0 10]); ylim([-10000 5]);grid on; hold on;
subplot(2,1,2); stem(n,subs(X,n),'k-*');legend('x_{anal}','x_{simul}'); grid on; hold on;
figure; freqz(num, den); grid on; hold on;

% ==============================================

clear all; clc; close all;

n = 0:1:9;
num = [4 -(1-3^(1/2)) 0];
den = [4 -2 1];
impulse_sig = (n==0);

syms z X

X_z = z*(4*z-1+3^(1/2))/(4*z^2-2*z+1);
X = iztrans(X_z);            % 전달함수 역변환

[coef, pole, direct] = residuez(num, den); %coef = 부분분수 분자의 상수, %pole = 부분분수 분모의 극

y = filter(num, den, impulse_sig);

subplot(2,1,1); zplane(num, den); xlim([-3 3]); ylim([-1.1 1.1]); title('극점-영점 플롯');grid on; hold on;
subplot(2,1,2); stem(n,y); xlim([0 10]); ylim([-0.3 1]);grid on; hold on;
subplot(2,1,2); stem(n,subs(X,n),'k-*');legend('x_{anal}','x_{simul}'); grid on; hold on;
figure; freqz(num, den); grid on; hold on;

% ==============================================

clear all; clc; close all;

n = 0:1:9;
num = [1 0];
den = [1 -0.25];
yinit = 1; % 초깃값 y[-1]

x = 0.5.^n;   %입력
ini_p = filtic(num, den, yinit);

y = filter(num, den, x, ini_p);

h_com=iteration(num, den, yinit, x); % 반복 대입법의 결과 
subplot(1,1,1); stem(n, y,'k-o'); xlim([0 10]); ylim([0 1.5]);grid on; hold on;
subplot(1,1,1); stem(n, h_com, 'k-*'); legend('y_{simul}', 'y_{anal}'); hold on; grid on;

function sol=iteration(num, den, yinit, x)
    xorder=length(num); % 피드 포워드 차수-1
    yorder=length(den); % 피드백 차수-1
    yinitlen=length(yinit); % n<0인 초깃값의 개수 [== yinitlen=yorder-1;]
    xlen=length(x); % n>=0인 입력 신호의 길이
    x0 = [zeros(1,yinitlen),x];% n<0인 초깃값을 포함한 총 출력 신호, n>=0인 구간은 0패딩
    y = [yinit, zeros(1, xlen)];
     % n<0에서 피드포워드 항이 있는 구간을 0패딩한 총 입력 신호
    for k=yinitlen+1:length(y)
        y(k) = -1*y(k-1:-1:k-yorder+1)*transpose(den(2:end))+x0(k:-1:k-xorder+1)*transpose(num);  % n>=0인 구간에 0패딩한 출력을 반복 대입법으로 계산
    end
    sol=y(yinitlen+1:1:length(y));% 초기값 이후부터 출력의 끝까지만 출력(즉 n>=0일 때만)
end

% ==============================================

clear all; clc; close all;

n = 0:1:9;
num = [1 -1 0];             % x, 분자
den = [1 -1 -2];            % y, 분모
yinit = [1 1];              % 초깃값 y[-1]

ini_p = filtic(num, den, yinit);
x = n>=0;                   %입력
y = filter(num, den, x, ini_p);

subplot(1,1,1); stem(n, y,'k-o'); xlim([0 10]); ylim([0 2000]);grid on; hold on;
h_com=iteration(num, den, yinit, x); % 반복 대입법의 결과
subplot(1,1,1); stem(n, h_com, 'k-*'); legend('y_{simul}', 'y_{anal}'); hold on; grid on;

function sol=iteration(num, den, yinit, x)
    xorder=length(num); % 피드 포워드 차수-1
    yorder=length(den); % 피드백 차수-1
    yinitlen=length(yinit); % n<0인 초깃값의 개수 [== yinitlen=yorder-1;]
    xlen=length(x); % n>=0인 입력 신호의 길이
    x0 = [zeros(1,yinitlen),x];% n<0인 초깃값을 포함한 총 출력 신호, n>=0인 구간은 0패딩
    y = [yinit, zeros(1, xlen)];
     % n<0에서 피드포워드 항이 있는 구간을 0패딩한 총 입력 신호
    for k=yinitlen+1:length(y)
        y(k) = -1*y(k-1:-1:k-yorder+1)*transpose(den(2:end))+x0(k:-1:k-xorder+1)*transpose(num);  % n>=0인 구간에 0패딩한 출력을 반복 대입법으로 계산
    end
    sol=y(yinitlen+1:1:length(y));% 초기값 이후부터 출력의 끝까지만 출력(즉 n>=0일 때만)
end

% ==============================================

clear all; clc; close all;

n = 0:1:9;
x = n>=0;                           % 입력
num = [0.375 0 0];                  % x, 분자
den = [1 -0.75 0.125];              % y, 분모
yinit_n = [3 21];                       % filtic 함수 사용할 초기값 y[-1] y[-2]

yinit_p = [21 3];                       % 반복대입법에 사용할 초기값 y[-2] y[-1]

init = filtic(num, den, yinit_n);

y = filter(num, den, x, init);      % filter 함수로 시뮬레이션

h_com = iteration(num, den, yinit_p, x); % 반복 대입법의 결과 

% 결과 비교
subplot(1,1,1); stem(n, y, 'k-o'); xlim([0 10]); ylim([0 1]); grid on; hold on;
subplot(1,1,1); stem(n, h_com, 'k-*'); legend('y_{simul}', 'y_{anal}'); grid on;

function sol=iteration(num, den, yinit_p, x)
    xorder=length(num); % 피드 포워드 차수-1
    yorder=length(den); % 피드백 차수-1
    yinitlen=length(yinit_p); % n<0인 초깃값의 개수 [== yinitlen=yorder-1;]
    xlen=length(x); % n>=0인 입력 신호의 길이
    x0 = [zeros(1,yinitlen),x];% n<0인 초깃값을 포함한 총 출력 신호, n>=0인 구간은 0패딩
    y = [yinit_p, zeros(1, xlen)];
     % n<0에서 피드포워드 항이 있는 구간을 0패딩한 총 입력 신호
    for k=yinitlen+1:length(y)
        y(k) = -1*y(k-1:-1:k-yorder+1)*transpose(den(2:end))+x0(k:-1:k-xorder+1)*transpose(num);  % n>=0인 구간에 0패딩한 출력을 반복 대입법으로 계산
    end
    sol=y(yinitlen+1:1:length(y));% 초기값 이후부터 출력의 끝까지만 출력(즉 n>=0일 때만)
end
