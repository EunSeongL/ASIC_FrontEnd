clc;
clear;
close all;

%==================전체 흐름====================
% 1. cos_in_gen()으로 FFT 입력용 코사인 신호 생성

% 2. fft_float() 함수로 전체 FFT 처리 (3단계 모듈 구조 + 재정렬)

% 3. 최종 결과 fft_out 획득 (아날로그로 말하면 주파수 스펙트럼)


fft_mode = 1;
N = 512;

% FFT 입력용 신호 생성 
[cos_float, cos_fixed] = cos_in_gen(fft_mode, N); % cos_float : 크기가 512인 복소수 "부동소수점 벡터"
                                                  % cos_fixed : cos_float을 스케일링 후 정수 양자화한 "고정소수점 벡터"

% 출력
[fft_out, module2_out] = fft_float(1, cos_float); % 1 -> fft mode, cos_float -> 입력 신호 (복소수 부동소수점 벡터)
% fft_out     -> 최종 FFT 결과 (512개 복소수 값, 버터플라이 + 재정렬 완료)
% module2_out -> 마지막 모듈(Stage 3)의 출력, 재정렬 전

fprintf("=== FFT 출력 검증 결과 ===\n");

% 1. 허수부 최대값 확인
max_imag = max(abs(imag(fft_out)));
fprintf("1. 최대 허수부 크기 : %.2e\n", max_imag);

% 2. conjugate symmetry 확인 (실수 입력 → 스펙트럼은 켤레 대칭)
symmetry_error = 0;
for k = 2:N/2
    err = abs(fft_out(k) - conj(fft_out(N - k + 2)));
    if err > 1e-4
        symmetry_error = symmetry_error + 1;
        fprintf("   ↳ 대칭 오류 at k=%d : error=%.2e\n", k, err);
    end
end
fprintf("2. 대칭성 오류 개수 : %d\n", symmetry_error);

% 3. 최대 진폭 위치 (cos 입력이므로 1Hz에만 존재해야 함)
[~, peak_idx] = max(abs(fft_out));
fprintf("3. 최대 진폭 위치 index : %d\n", peak_idx);

% 4. ifft 복원 시 원 입력과의 차이
ifft_out = ifft(fft_out);
reconstruction_error = max(abs(real(ifft_out) - real(cos_float)));
fprintf("4. ifft 복원 최대 오차 : %.2e\n", reconstruction_error);

%==================그래프 출력====================
figure;
plot(abs(fft_out));
title('FFT Magnitude Spectrum');
xlabel('Index');
ylabel('Magnitude');
grid on;

%============================plot 했던 코드==============================
% % Magnitude plot
% figure;
% plot(abs(fft_out));
% title('Magnitude of FFT Output');
% xlabel('Index');
% ylabel('|fft\_out|');
% grid on;
% 
% % Real and Imaginary parts (in subplot)
% figure;
% subplot(2,1,1);
% plot(real(fft_out));
% title('Real Part of FFT Output');
% xlabel('Index');
% ylabel('Real');
% grid on;
% 
% subplot(2,1,2);
% plot(imag(fft_out));
% title('Imaginary Part of FFT Output');
% xlabel('Index');
% ylabel('Imag');
% grid on;
% 
% % Phase plot
% figure;
% threshold = max(abs(fft_out)) * 0.1;
% idx = find(abs(fft_out) > threshold);
% plot(idx, angle(fft_out(idx)), 'o-');
% title('Phase of Significant FFT Output');
% xlabel('Index');
% ylabel('Phase (radians)');
% grid on;
