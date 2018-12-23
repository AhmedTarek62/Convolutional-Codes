function [encoded] = HuffEncode(text,dict)
%%text is the data to encode
%%dict is the huffman dictionary
encoded=strings(1,length(text));
%%encodes each character into its appropriate codeword through looking up
%%the character in the huffman dictionary
for i=1:length(text)
    for j=1:length(dict)
        if strcmp(text(i),dict(j).symbol)
            encoded(i)=dict(j).codeword;
        end
    end
end
end

