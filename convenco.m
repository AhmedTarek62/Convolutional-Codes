function [encoded] = convenco(seq,g1,g2,g3,N)
%Note: the function is designed to work on a constraint length K=3
%Different usage will lead to errors
%Inputs:
%N is number of bits in a block
%g1, g2, g3 are three generator polynomials
%seq is the sequence to be encoded
%Outputs:
%encoded is the output sequence
L1=length(g1);
L2=length(g2);
L3=length(g3);
K=3;
if(N<=length(seq))
    num_zeros=mod(length(seq),N);
    seq=[seq zeros(1,num_zeros)];
    for i=1:length(seq)/N
        if(L1==L2 && L2==L3) %checks if the generator polynomials correspond
            %to the same constraint length K (3 in our case)
            %finds the output of each branch & upsamples each output by K=3
            block=seq((i-1)*N+1:i*N);
            temp=myupsample(conv(block,g1),K);
            temp1=myupsample(conv(block,g2),K);
            temp2=myupsample(conv(block,g3),K);
            L=length(temp);
            temp1=[temp1(L) temp1(1:L-1)];
            %circular shift the upsampled second output by 1
            temp2=[temp2(L:-1:L-1) temp2(1:L-2)];
            %circular shift the upsampled third output by 2
            encoded((i-1)*L+1:i*L)=temp+temp1+temp2;
        end
    end
    encoded(encoded==2)=0;
end
end

