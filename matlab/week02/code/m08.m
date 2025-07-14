clear, clc;

order = 48;

figure(1);
filter_coef=fir1(order, 0.35, 'low', hamming(order+1), 'scale');
freqz(filter_coef,1)

figure(2);
filter_coef=fir1(order, 0.65, 'high', hamming(order+1), 'scale');
freqz(filter_coef,1)

figure(3);
filter_coef=fir1(order, [0.35 0.65], 'bandpass', hamming(order+1), 'scale');
freqz(filter_coef,1)

figure(4);
filter_coef=fir1(order, [0.35 0.65], 'stop', hamming(order+1), 'scale');
freqz(filter_coef,1)

figure(5);
filter_coef=fir1(order, [0.2 0.4 0.6 0.8], 'bandpass', hamming(order+1), 'scale');
freqz(filter_coef,1)

figure(6);
filter_coef=fir1(order, [0.2 0.4 0.6 0.8], 'stop', hamming(order+1), 'scale');
freqz(filter_coef,1)
