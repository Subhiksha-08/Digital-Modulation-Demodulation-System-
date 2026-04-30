clc;
clear;
close all;

%% PARAMETERS
N = 1000;                 % Number of bits
SNR_dB = 0:2:20;          % SNR range
bits = randi([0 1], 1, N);

%% ================= ASK =================
ask_mod = bits;   % On-Off Keying

BER_ask = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)
    noisy = awgn(ask_mod, SNR_dB(i), 'measured');
    demod = noisy > 0.5;
    BER_ask(i) = sum(bits ~= demod)/N;
end

%% ================= BPSK =================
bpsk_mod = 2*bits - 1;

BER_bpsk = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)
    noisy = awgn(bpsk_mod, SNR_dB(i), 'measured');
    demod = noisy > 0;
    BER_bpsk(i) = sum(bits ~= demod)/N;
end

%% ================= QPSK =================
% Convert bits to symbols
bits_reshape = reshape(bits(1:floor(N/2)*2), 2, []).';
symbols = bi2de(bits_reshape);

qpsk_mod = pskmod(symbols, 4);

BER_qpsk = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)
    noisy = awgn(qpsk_mod, SNR_dB(i), 'measured');
    demod = pskdemod(noisy, 4);
    bits_out = de2bi(demod, 2);
    bits_out = bits_out(:).';
    
    original = bits(1:length(bits_out));
    BER_qpsk(i) = sum(original ~= bits_out)/length(bits_out);
end

%% ================= 16-QAM =================
bits_reshape = reshape(bits(1:floor(N/4)*4), 4, []).';
symbols = bi2de(bits_reshape);

qam_mod = qammod(symbols, 16);

BER_qam = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)
    noisy = awgn(qam_mod, SNR_dB(i), 'measured');
    demod = qamdemod(noisy, 16);
    bits_out = de2bi(demod, 4);
    bits_out = bits_out(:).';
    
    original = bits(1:length(bits_out));
    BER_qam(i) = sum(original ~= bits_out)/length(bits_out);
end

%% ================= PLOT =================
figure;
semilogy(SNR_dB, BER_ask, '-o', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER_bpsk, '-s', 'LineWidth', 2);
semilogy(SNR_dB, BER_qpsk, '-^', 'LineWidth', 2);
semilogy(SNR_dB, BER_qam, '-d', 'LineWidth', 2);

grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs SNR for ASK, BPSK, QPSK, 16-QAM');
legend('ASK', 'BPSK', 'QPSK', '16-QAM');
