function [prob] = CalculateCharProb(text,chars)
prob=zeros(1,length(chars));
for i=1:length(chars)
    prob(i)=mean(text==chars(i));
end
%calculates the probability of each character
end


