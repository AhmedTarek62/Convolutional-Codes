%% Binary Sequence Generation
N=1e3;%number of bits
L=10;%block size
seq=binaryseq(N,1,0);
%% Convolutional encoding
%generator polynomials
g1=[1 1 1];
g2=[1 1 0];
g3=[1 0 1];
%encoding
encoded=convenco(seq,g1,g2,g3,L);
%% Bit Error Rate
SNR_db=-1:1:12;
ber_conv=zeros(1,length(SNR_db));
ber=zeros(1,length(SNR_db));
for i=1:length(SNR_db)
    received_conv=awgn(encoded,SNR_db(i),'measured');
    received=awgn(seq,SNR_db(i),'measured');
    decoded_conv=viterbideco(received_conv,g1,g2,g3,L);
    detected_nocoding=received>=1/2;
    ber(i)=mean(detected_nocoding~=seq);
    ber_conv(i)=mean(decoded_conv~=seq);
end
hold on
grid on
plot(SNR_db,smooth(ber),'-ored');
plot(SNR_db,smooth(ber_conv),'--*blue');
title('Comparison between the Bit Error Rates in case of using Convolutional Codes and in case of no coding')
ylabel('Bit Error rate');
xlabel('Signal-to-Noise ratio');
legend('No Coding','Convolutional Coding');
set(gca, 'YScale', 'log');
