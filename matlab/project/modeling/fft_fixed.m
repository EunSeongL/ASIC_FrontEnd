function [fft_out, module2_out] = fft_fixed(fft_mode, fft_in)

    FMT = fimath('RoundingMethod', 'Floor', 'OverflowAction', 'Saturate');
    FIX2_7 = @(x) fi(x, 1, 9, 7, 'fimath', FMT);
    
    FIX4_6 = @(x) fi(x, 1, 10, 6, 'fimath', FMT);  % <4.6>
    
    FIX7_6 = @(x) fi(x, 1, 13, 6, 'fimath', FMT);  % <7.6>
    FIX10_6 = @(x) fi(x, 1, 16, 6, 'fimath', FMT);  % <10.6>
    FIX5_6 = @(x) fi(x, 1, 11, 6, 'fimath', FMT);  % <5.6>

    FIX9_6 = @(x) fi(x, 1, 15, 6, 'fimath', FMT);  % <9.6>
    FIX12_6 = @(x) fi(x, 1, 18, 6, 'fimath', FMT);  % <12.6>
    FIX6_6 = @(x) fi(x, 1, 12, 6, 'fimath', FMT);  % <6.6>

    FIX8_6 = @(x) fi(x, 1, 14, 6, 'fimath', FMT);  % <8.6>
    FIX13_6 = @(x) fi(x, 1, 20, 6, 'fimath', FMT);  % <13.6>
    FIX9_4 = @(x) fi(x, 1, 13, 4, 'fimath', FMT);  % <9.4>

    % Fixed-point FFT implementation matching the structure of fft_float
    SIM_FIX = 1;
    N = 512;

    
    if fft_mode == 1
        din = fft_in;
    else
        din = conj(fft_in);
    end

    fac8_0 = [1, 1, 1, -1j];
    fac8_0 = arrayfun(FIX2_7, fac8_0);
    fac8_1 = [1, 1, 1, -1j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j];
    fac8_1 = arrayfun(FIX2_7, fac8_1);
   
    %% ---------------------- Module 0 ----------------------
    bfly00_out0 = din(1:256) + din(257:512); % <4.6>
    bfly00_out1 = din(1:256) - din(257:512); % <4.6>
    bfly00_tmp = [bfly00_out0, bfly00_out1];
    

    for nn = 1:N
        bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128));
        bfly00(nn) = arrayfun(FIX4_6, bfly00(nn));
    end

    

    save_step('fixed_step0_0.txt', bfly00);

    %% step0_1
    for kk=1:2 % k=1일 때 1~256 포인트까지, k=2일 때 257~512 포인트까지 연산 (256 x 256)
        for nn=1:128 % 128포인트씩 처리, 총 2개 블록
            bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); % 덧셈 연
            bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn); % 뺄셈 연산
        end
    end

    for nn=1:512 % 회전인자 곱하기
        bfly01(nn) = bfly01_tmp(nn)*fac8_1(ceil(nn/64));
        bfly01(nn) = arrayfun(FIX7_6, bfly01(nn));
    end

    save_step('fixed_step0_1.txt', bfly01);

    %% step0_2
    for kk=1:4 %  k=1일 때 1~128 포인트까지, k=2일 때 128~256 포인트까지 연산....k=4일 때 512까지 연산
        for nn=1:64 % 64포인트씩 처리, 총 4개 블록
            bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn); % 덧셈 연산
            bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn); % 뺄셈 연산
        end
    end

    K3 = [0 4 2 6 1 5 3 7];
    for kk = 1:8
        for nn = 1:64
            twf_m0((kk-1)*64+nn) = exp(-1j*2*pi*(nn-1)*(K3(kk))/512);
            twf_m0((kk-1)*64+nn) = arrayfun(FIX2_7, twf_m0((kk-1)*64+nn));
        end
    end

    for nn=1:512 % 회전인자 곱하기
        bfly02(nn) = bfly02_tmp(nn)*twf_m0(nn);
        bfly02(nn) = arrayfun(FIX10_6, bfly02(nn));
        bfly02(nn) = arrayfun(FIX5_6, bfly02(nn));
    end

    save_step('fixed_step0_2.txt', bfly02);

    %% ---------------------- Module 1 ----------------------
    for kk=1:8 % 8블록 × 64포인트 = 총 512 포인트를 32-point 단위로 butterfly 연산
        for nn=1:32
            bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn);
            bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn); % <6.6>
        end
    end

    for kk = 1:8
        for nn = 1:64
            bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16));
            bfly10((kk-1)*64+nn) = arrayfun(FIX6_6, bfly10((kk-1)*64+nn));
        end
    end
    
    save_step('fixed_step1_0.txt', bfly10);

    %% step1_1
    for kk=1:16 % 총 512 포인트를 16블록 × 32포인트 연산 단위로 butterfly 구성
        for nn=1:16
            bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn);
            bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
        end
    end

    for kk=1:8 % 회전인자 적용
        for nn=1:64
            bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn)*fac8_1(ceil(nn/8)); % 각 64-point 블록을 8포인트 단위로 나눠서 fac8_1의 8개 인자를 반복적으로 곱함
            bfly11(nn) = arrayfun(FIX9_6, bfly11(nn));
        end
    end

    save_step('fixed_step1_1.txt', bfly11);

    %% step1_2
    for kk=1:32 % 512 포인트를 32블록 × 16포인트로 8-point 단위로 butterfly 연산
        for nn=1:8
            bfly12_tmp((kk-1)*16+nn) = bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn);
            bfly12_tmp((kk-1)*16+8+nn) = bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn);
        end
    end

    K2 = [0 4 2 6 1 5 3 7];
    for kk = 1:8
        for nn = 1:8
            twf_m1((kk-1)*8+nn) = exp(-1j*2*pi*(nn-1)*(K2(kk))/64);
            twf_m1((kk-1)*8+nn) = arrayfun(FIX2_7, twf_m1((kk-1)*8+nn));
        end
    end

    for kk=1:8 % 회전인자 적용
        for nn=1:64
            bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn)*twf_m1(nn);
            bfly12(nn) = arrayfun(FIX12_6, bfly12(nn));
            bfly12(nn) = arrayfun(FIX6_6, bfly12(nn));
        end
    end

    save_step('fixed_step1_2.txt', bfly12);

    %% ---------------------- Module 2 ----------------------
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
            bfly20((kk-1)*8+nn) = arrayfun(FIX9_6, bfly20((kk-1)*8+nn));
        end
    end

    save_step('fixed_step2_0.txt', bfly20);

    %% step2_1 -> 2-point butterfly   128블록 × 4포인트   fac8_1(nn)
    for kk=1:128
        for nn=1:2
            bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn);
            bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
        end
    end

    for kk=1:64
        for nn=1:8
            bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1(nn);
            bfly21((kk-1)*8+nn) = arrayfun(FIX13_6, bfly21((kk-1)*8+nn));
            % 각 블록마다 8포인트를 대상으로 fac8_1의 8개 항목을 주기적으로 곱함
            % (fac8_1을 전체적으로 순환하며 적용)
        end
    end

    save_step('fixed_step2_1.txt', bfly21);

    %% step2_2 -> 2-point butterfly   256블록 × 2포인트   없음 (마지막 단계)
    for kk=1:256
        bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2);
        bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
    end

    bfly22 = bfly22_tmp;
    bfly22 = arrayfun(FIX9_4, bfly22);
    save_step('fixed_step2_2.txt', bfly22);

    %% ---------------- Bit-reversal ------------------
    dout = zeros(1, 512);
    fp = fopen('reorder_index_fixed.txt', 'w');
    for jj = 1:512
        kk = bitrev(jj-1, 9);
        dout(kk+1) = bfly22(jj);
        fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n', jj, kk, kk+1, real(dout(kk+1)), imag(dout(kk+1)));
    end
    fclose(fp);

    if fft_mode == 1
        fft_out = dout;
        module2_out = bfly22;
    else
        fft_out = conj(dout)/512;
        module2_out = conj(bfly22)/512;
    end

end

function b = bitrev(a, n)
    b = 0;
    for i = 0:n-1
        b = b + bitget(a, i+1) * 2^(n-1-i);
    end
end

function save_step(filename, data)
    fp = fopen(filename, 'w');
    for i=1:length(data)
        fprintf(fp, 'idx=%d, val=%f+j%f\n', i, real(data(i)), imag(data(i)));
    end
    fclose(fp);
end
