clear all; clc;

in = [1 2 3 4 5 6 7 8]; % 시간 신호
N = length(in); % 시간 신호 샘플 수
STAGE = log2(N); % 단 수
W = exp(-1j*2*pi/N); % 회전 인자

x = zeros(STAGE+1, N); % 단 별 계산 결과
x(1, :) = in; % 1단에 입력 시간

for stage = 1:STAGE
    BLOCK = 2^(stage-1);
    for Block = 1:BLOCK 
        BUTTERFLY = (N / BLOCK)/2; % 버터플라이 개수
        power = bin2dec(reverse(dec2bin(Block-1, STAGE-1)));  
        
        for Butterfly = 1:BUTTERFLY
            upper = (Block - 1) * (N / BLOCK) + Butterfly;
            lower = upper + N/(2*BLOCK);
            
            UPPER = x(stage, upper); 
            LOWER = (W^power) * x(stage, lower);
            
            x(stage+1, upper) = UPPER + LOWER;
            x(stage+1, lower) = UPPER - LOWER;
        end
    end
end

xx = zeros(1, N);
for n = 0:N-1
    xx(bin2dec(reverse(dec2bin(n, log2(N))))+1) = x(end, n+1);
end

disp(xx);
disp(fft(in));
