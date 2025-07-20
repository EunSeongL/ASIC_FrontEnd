% 입력 신호 fft_in을 받아 512-point FFT 또는 IFFT를 계산하는 함수

function [fft_out, module2_out] = fft_float(fft_mode, fft_in)

 shift = 0;
 SIM_FIX = 0; % 0: float, 1: fixed

 if (fft_mode==1) % fft 실행
   din = fft_in;
 else % ifft 실행
   din = conj(fft_in);
 end

 % 회전인자
 % 각 버터플라이 단계에서 연산되는 sub-FFT의 크기에 따라 적용
 fac8_0 = [1, 1, 1, -j]; % ceil(nn/16) 또는 ceil(nn/128) 같은 방식으로 적용됨, W0,W1,W2는 1 회전 X, W4만 90도 회전
 fac8_1 = [1, 1, 1, -j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]; % ceil(nn/64) 또는 ceil(nn/8)처럼, 64개나 8개 단위로 그룹화하여 적용
 
 % 총 3개의 모듈(Module 0~2)로 구성되어 있으며, 각 모듈은 3단계의 butterfly 연산을 수행
 % 각 단계에서 bflyXX_tmp, bflyXX를 이용해 나비 연산 수행 후 twiddle factor(fac8_0, fac8_1, twf_mX) 곱셈 적용
 % 마지막 단계에서 bit-reversal 인덱싱 (bitget() 사용)으로 출력 순서를 재정렬
 % 출력: fft_out (최종 결과), module2_out (중간 결과)

 %-----------------------------------------------------------------------------
 % Module 0
 %-----------------------------------------------------------------------------

 % =================첫 번째 버터플라이 step0_0========================
 bfly00_out0 = din(1:256) + din(257:512); % → 길이 256 (덧셈 결과)
 bfly00_out1 = din(1:256) - din(257:512); % → 길이 256 (뺄셈 결과)

 bfly00_tmp = [bfly00_out0, bfly00_out1]; % → 길이 512 (256 + 256)로 합침
 % 덧셈 index(1+257) -> bfly00_tmp(1)에 저장
 %      index(2+258) -> bfly00_tmp(2)에 저장
 %      index(256+512) -> bfly00_tmp(256)에 저장
 % 뺄셈 index(1-257) -> bfly00_tmp(257)에 저장
 %      index(2-258) -> bfly00_tmp(258)에 저장
 %      index(256-512) -> bfly00_tmp(512)에 저장

 for nn=1:512 % 회전인자 곱하기
   bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128));
    % nn이 (1 ~ 128)일 때 -> ceil(nn/128) = 1 -> fac8_0의 1번 인덱스 사용
    % nn(129 ~ 256) -> ceil(nn/128) = 2 -> fac8_0의 2번 인덱스 사용
    % nn(257 ~ 384) -> ceil(nn/128) = 3 -> fac8_0의 3번 인덱스 사용
    % nn(385 ~ 512) -> ceil(nn/128) = 4 -> fac8_0의 4번 인덱스 사용
 end
 save_step('float_step0_0.txt', bfly00);

 % ===============두 번째 버터플라이 step0_1==========================
 for kk=1:2 % k=1일 때 1~256 포인트까지, k=2일 때 257~512 포인트까지 연산 (256 x 256)
  for nn=1:128 % 128포인트씩 처리, 총 2개 블록
   bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); % 덧셈 연산
   bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn); % 뺄셈 연산
  end
 end


 for nn=1:512 % 회전인자 곱하기
   bfly01(nn) = bfly01_tmp(nn)*fac8_1(ceil(nn/64));
 end
 save_step('float_step0_1.txt', bfly01);
 % ==============세 번째 버터플라이 step0_2=========================
 for kk=1:4 %  k=1일 때 1~128 포인트까지, k=2일 때 128~256 포인트까지 연산....k=4일 때 512까지 연산
  for nn=1:64 % 64포인트씩 처리, 총 4개 블록
   bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn); % 덧셈 연산
   bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn); % 뺄셈 연산
  end
 end

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7]; % 8개의 twiddle factor 블록을 위한 bit-reversal 순서, bit-reversed 인덱스 순서대로 회전 위상을 설정해주는 거 
 for kk=1:8 % K3의 8개 인덱스
  for nn=1:64
   twf_m0((kk-1)*64+nn) = exp(-j*2*pi*(nn-1)*(K3(kk))/512); % 회전 인자(twiddle factor) 배열 생성
                                                             % bfly02_tmp의 각 항목에 곱해질 회전 인자를 미리 계산해두는 과정
  end
 end

 for nn=1:512 % 회전인자 곱하기
   bfly02(nn) = bfly02_tmp(nn)*twf_m0(nn);
 end
 save_step('float_step0_2.txt', bfly02);
 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0
 for kk=1:8 % 8블록 × 64포인트 = 총 512 포인트를 32-point 단위로 butterfly 연산
  for nn=1:32
   bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn);
   bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn);
  end
 end

 for kk=1:8 % 회전 인자 적용
  for nn=1:64 % 64-point 블록 내부에서 인덱스 nn을 기준으로 회전 인자 적용
   bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16)); % 각 64-point 블록 내부를 16포인트씩 4개 그룹으로 나눠 적용
                                                                         % fac8_0의 [1 2 3 4] 인덱스를 반복적으로 곱함
  end
 end
 save_step('float_step1_0.txt', bfly10);
 % step1_1
 for kk=1:16 % 총 512 포인트를 16블록 × 32포인트 연산 단위로 butterfly 구성
  for nn=1:16
   bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn);
   bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
  end
 end

 for kk=1:8 % 회전인자 적용
  for nn=1:64
   bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn)*fac8_1(ceil(nn/8)); % 각 64-point 블록을 8포인트 단위로 나눠서 fac8_1의 8개 인자를 반복적으로 곱함
  end
 end
 
 save_step('float_step1_1.txt', bfly11);

 % step1_2
 for kk=1:32 % 512 포인트를 32블록 × 16포인트로 8-point 단위로 butterfly 연산
  for nn=1:8
   bfly12_tmp((kk-1)*16+nn) = bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn);
   bfly12_tmp((kk-1)*16+8+nn) = bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn);
  end
 end
 
 % Data rearrangement
 K2 = [0, 4, 2, 6, 1, 5, 3, 7]; % 총 8개 블록에 대해 bit-reversed index 기반의 회전 인자 생성

 for kk=1:8
  for nn=1:8
   twf_m1((kk-1)*8+nn) = exp(-j*2*pi*(nn-1)*(K2(kk))/64); % twf_m1은 총 64개의 twiddle factor 배열
  end
 end

 for kk=1:8 % 회전인자 적용
  for nn=1:64
   bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn)*twf_m1(nn);
  end
 end

 save_step('float_step1_2.txt', bfly12);
 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0 ->  4-point butterfly   64블록 × 8포인트   fac8_0(ceil(nn/2))
 for kk=1:64
  for nn=1:4
   bfly20_tmp((kk-1)*8+nn) = bfly12((kk-1)*8+nn) + bfly12((kk-1)*8+4+nn);
   bfly20_tmp((kk-1)*8+4+nn) = bfly12((kk-1)*8+nn) - bfly12((kk-1)*8+4+nn);
  end
 end

 for kk=1:64
  for nn=1:8
   bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn)*fac8_0(ceil(nn/2)); % 각 8포인트 블록 내에서 2포인트 단위로 묶어 fac8_0(1~4) 회전 인자를 곱함
  end
 end
 save_step('float_step2_0.txt', bfly20);
 % step2_1 -> 2-point butterfly   128블록 × 4포인트   fac8_1(nn)
 for kk=1:128
  for nn=1:2
   bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn);
   bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
  end
 end

 % 회전인자 적용
 % bfly21_tmp는 512포인트인데, bfly21은 64블록 × 8포인트처럼 보이도록 쓰여 있음
 % 하지만 실제로는 nn = 1~8 → fac8_1(1~8)을 각 블록마다 반복해서 적용한다고 해석됨
 for kk=1:64
  for nn=1:8
   bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1(nn);
    % 각 블록마다 8포인트를 대상으로 fac8_1의 8개 항목을 주기적으로 곱함
    % (fac8_1을 전체적으로 순환하며 적용)
  end
 end
 save_step('float_step2_1.txt', bfly21);
 % step2_2 -> 2-point butterfly   256블록 × 2포인트   없음 (마지막 단계)
 for kk=1:256
   bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2);
   bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
 end

 bfly22 = bfly22_tmp;
 save_step('float_step2_2.txt', bfly22);

 %-----------------------------------------------------------------------------
 % Index 
 %-----------------------------------------------------------------------------
 % FFT는 Cooley–Tukey 알고리즘 구조상 내부 연산은 정상적인 순서로 계산되지만,
 % 최종 출력은 bit-reversed index 순서로 존재하므로 이를 다시 자연스러운 index 순서로 정렬
 fp=fopen('reorder_index.txt','w');
 for jj=1:512
    % kk: jj-1을 bit-reversal한 인덱스
   %kk = bitget(jj-1,9)*(2^0) + bitget(jj-1,8)*(2^1) + bitget(jj-1,7)*(2^2) + bitget(jj-1,6)*(2^3) + bitget(jj-1,5)*(2^4) + bitget(jj-1,4)*(2^5) + bitget(jj-1,3)*(2^6) + bitget(jj-1,2)*(2^7) + bitget(jj-1,1)*(2^8);
   kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
   dout(kk+1) = bfly22(jj); % bfly22(jj)는 FFT 마지막 단계의 출력 (bit-reversed 순서) dout(kk+1)에 다시 정상 순서로 재정렬
   fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n',jj, kk,(kk+1),real(dout(kk+1)),imag(dout(kk+1)));
 end
 fclose(fp);

 if (fft_mode==1) % fft
   fft_out = dout; % 그대로 반환
   module2_out = bfly22;
 else % ifft
   fft_out = conj(dout)/512;  % exp(+j2πkn/N) 대신 exp(-j2πkn/N)을 사용해야해서 입력에 conj() 적용
   module2_out = conj(bfly22)/512; % conjugate 연산 후 크기를 맞추기 위해 512로 나눠서 정규화

 end

end

function save_step(filename, data)
    fp = fopen(filename, 'w');
    for i=1:length(data)
        fprintf(fp, 'idx=%d, val=%f+j%f\n', i, real(data(i)), imag(data(i)));
    end
    fclose(fp);
end