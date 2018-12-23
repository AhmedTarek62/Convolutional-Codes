function [upsampled] = myupsample(seq,n)
upsampled=zeros(1,length(seq)*n);
j=1;
for i=1:3:3*length(seq)
    upsampled(i)=seq(j);
    j=j+1;
end

