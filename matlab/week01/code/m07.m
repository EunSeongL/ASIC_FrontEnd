clear all; clc; clear figure;
N=5; % 출력을 얻고 싶은 길이 = 반복 횟수
n=0:1:N-1; 

impulse_sig = (n==0);% 임펄스 응답을 얻기 위한 임펄스 입력 신호

xcoef=[1 0 0]; % 차분방정식의 피드 포워드(분자) 계수
ycoef=[1 -4 4]; % 차분방정식의 피드백(분모) 계수 
yinit=[0 0]; % 초깃값 y[-2], y[-1]  


h_com=iteration(xcoef, ycoef, yinit, impulse_sig); % 반복 대입법의 결과 
plot(n, h_com, 'k'); hold on; grid on;
h_anal = (1+n).*2.^n; % 고전적 해법의 결과 
plot(n, h_anal, 'k-o'); xlabel('n'); legend('h[n]_{com}', 'h[n]_{anal}');
function sol=iteration(xcoef, ycoef, yinit, x)
    xorder=length(xcoef); % 피드 포워드 차수-1
    yorder=length(ycoef); % 피드백 차수-1
    yinitlen=length(yinit); % n<0인 초깃값의 개수 [== yinitlen=yorder-1;]
    xlen=length(x); % n>=0인 입력 신호의 길이
    x0 = [zeros(1,yinitlen),x];% n<0인 초깃값을 포함한 총 출력 신호, n>=0인 구간은 0패딩
    y = [yinit, zeros(1, xlen)];
     % n<0에서 피드포워드 항이 있는 구간을 0패딩한 총 입력 신호
    for k=yinitlen+1:length(y)
        y(k) = -1*y(k-1:-1:k-yorder+1)*transpose(ycoef(2:end))+x0(k:-1:k-xorder+1)*transpose(xcoef);  % n>=0인 구간에 0패딩한 출력을 반복 대입법으로 계산
    end
    sol=y(yinitlen+1:1:length(y));% 초기값 이후부터 출력의 끝까지만 출력(즉 n>=0일 때만)
end
