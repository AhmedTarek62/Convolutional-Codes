function [decoded] = HuffDecode_New(encoded,dict)
%encoded is the encoded data
%dict is the Huffman dictionary
[r,~]=size(dict);
L=length(encoded);
encoded=string(encoded);
%looks up the encoded symbol in the huffman dictionary
k=1;
for i=1:L
    flag=0;
    for j=1:r
        if(strcmp(encoded(i),dict(j).codeword))
            decoded(k)=dict(j).symbol;
            k=k+1;
            flag=1;
            break;
        end
    end
    if flag==0
        if(i~=L)
            encoded(i+1)=strcat(encoded(i),encoded(i+1));
        else
            decoded(k)=string('*');
        end
    end
end
end

