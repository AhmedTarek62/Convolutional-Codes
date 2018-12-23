function [dict,averagelen,variance,fulldict,tree] = HuffDict(symbols,prob,var)
%symbols is an array of strings of the source alphabet
%prob is a probability vector of the source alphabet
%var is the desired code variance, var =1: max variance, 
%var=0: min variance
L=length(symbols);
prob=100*prob;
%sorts prob and symbols descendingly according to prob
[prob,index]= sort(prob,'descend');
symbols=symbols(index);
%Fills the first row of the tree structure with the symbols and their
%frequencies
for i=1:L
    symbols(i)=string(symbols(i));
    tree(i,1)=struct('symbol',symbols(i),'frequency',prob(i),'codeword',[]);
end
%defines the rest of the needed tree levels to execute the algorithm
for i=2:L-1
    for j=1:L
        tree(j,i)=struct('symbol',[],'frequency',[],'codeword',[]);
    end
end
%fills on the rest of the tree by summing the lowest two probabilities
%and placing the new node in the appropriate position in the next column
%if var=0, the new nodes are placed as high as possible
%if var=1, the new nodes are placed as low as possible
k=L-1;
while(k>=1)
   if k>1
       if var==0
           %sums the lowest nodes, sorts the new prob and symbol arrays
            prob(k)=prob(k)+prob(k+1)+1e-6;
            prob=prob(1:k);
            [prob,ind]=sort(prob,'descend');
            symbols(k)=strcat(symbols(k),symbols(k+1));
            symbols=symbols(1:k);
            symbols=symbols(ind);
       elseif var==1
           prob(k)=prob(k)+prob(k+1);
            prob=prob(1:k);
            [prob,ind]=sort(prob,'descend');
            symbols(k)=strcat(symbols(k),symbols(k+1));
            symbols=symbols(1:k);
            symbols=symbols(ind);
       end
    %assigns the new symbol and frequency values to the tree
    for i=1:k
        tree(i,L-k+1).symbol=symbols(i);
        tree(i,L-k+1).frequency=prob(i);
    end
   end
   %assigns binary code the merged nodes 
    tree(k,L-k).codeword=string('0');
    tree(k+1,L-k).codeword=string('1');
    k=k-1;
end

%traces the tree back in order to construct the codewords of each symbol
for k=1:L
    for i=2:L-1
        for j=L-i+1:-1:1
            if contains(tree(j,i).symbol,tree(k,1).symbol) && ~isempty(tree(j,i).codeword)
                tree(k,1).codeword=strcat(tree(j,i).codeword,tree(k,1).codeword);
                break;
            end
        end
    end
end
fulldict=tree(:,1);
dict=rmfield(fulldict,'frequency');
[r,~]=size(fulldict);
averagelen=0;
variance=0;
%computes the averagelength and variance of the resulting code
for i=1:r
    averagelen=averagelen+1/100*fulldict(i).frequency*strlength(fulldict(i).codeword);
end
for i=1:r
    variance=variance+1/100*fulldict(i).frequency*(averagelen-strlength(fulldict(i).codeword))^2;
end
end

