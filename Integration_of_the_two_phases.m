%% Integration of the two phases
%%Read from file
fileid = fopen('Test_text_file.txt','r'); %finds the file ID
data=fscanf(fileid,'%c'); %reads the file writing each char into an array
fclose(fileid);
%The only allowed characters are lower case English characters a-z,
%the symbols ( ) . , / - and space
% define an array of the allowed chars
chars=['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',...
'u','v','w','x','y','z','(',')','.',',','/','-',' '];
stringchars = [string('a'),string('b'),string('c'),string('d'),string('e'),string('f')...
,string('g'),string('h'),string('i'),string('j'),string('k'),string('l'),string('m'),...
string('n'),string('o'),string('p'),string('q'),string('r'),string('s'),string('t'),...
string('u'),string('v'),string('w'),string('x'),string('y'),string('z'),string('('),...
string(')'),string('.'),string(','),string('/'),string('-'),string(' ')];
%% Probability of Symbols & Huffman Coding
prob=CalculateCharProb(data,chars);%vector of probability symbols
%the first 26 entries are the probabilites of the 26 lowercase english letters
%the rest of the entries are the probabilities of ( ) . , / - and space in
%the same order
dict=HuffDict(stringchars,prob,1);
encoded_huff_str=HuffEncode(data,dict);
k=1;
%converts the huffman encoded array of strings to a numeric array 
for i=1:length(encoded_huff_str)
    temp=char(encoded_huff_str(i));
    for j=1:length(temp)
        encoded_huff(k)=str2num(temp(j));
        k=k+1;
    end
end
%% Convolutional Coding
L=15;%Block Length
%generator polynomials
g1=[1 1 1];
g2=[1 1 0];
g3=[1 0 1];
%encoding
encoded=convenco(encoded_huff,g1,g2,g3,L);
%% Noise Addition
received_0db_conv=awgn(encoded,0,'measured');
received_5db_conv=awgn(encoded,5,'measured');
received_10db_conv=awgn(encoded,10,'measured');
received_0db_nocoding=awgn(encoded_huff,0,'measured');
received_5db_nocoding=awgn(encoded_huff,5,'measured');
received_10db_nocoding=awgn(encoded_huff,10,'measured');
%% Viterbi Decoding
decoded_0db_conv=viterbideco(received_0db_conv,g1,g2,g3,L);
decoded_5db_conv=viterbideco(received_5db_conv,g1,g2,g3,L);
decoded_10db_conv=viterbideco(received_10db_conv,g1,g2,g3,L);
%% Huffman Decoding 
%note I implement HuffDecode_new as the behaviour of the function
%implemented phase 1 of the project is not suitable for integration of the
%two phases
recovered_0db_conv=HuffDecode_New(decoded_0db_conv,dict);
recovered_5db_conv=HuffDecode_New(decoded_5db_conv,dict);
recovered_10db_conv=HuffDecode_New(decoded_10db_conv,dict);
recovered_0db_nocoding=HuffDecode_New(double(received_0db_nocoding>=1/2),dict);
recovered_5db_nocoding=HuffDecode_New(double(received_5db_nocoding>=1/2),dict);
recovered_10db_nocoding=HuffDecode_New(double(received_10db_nocoding>=1/2),dict);
text=strings(1,length(data));
%Ensures that the received text has the same size as the transmitted text
%as size discrepancy can occur due to decoding errors
for i=1:length(data)
    text(i)=data(i);
    if(i<=length(recovered_0db_conv))
        recovered_0db_conv(i)=char(recovered_0db_conv(i));
    else
        recovered_0db_conv(i)='*';
    end
    if(i<=length(recovered_5db_conv))
        recovered_5db_conv(i)=char(recovered_5db_conv(i));
    else
        recovered_5db_conv(i)='*';
    end
    if(i<=length(recovered_10db_conv))
        recovered_10db_conv(i)=char(recovered_10db_conv(i));
    else
        recovered_10db_conv(i)='*';
    end
    if(i<=length(recovered_0db_nocoding))
        recovered_0db_nocoding(i)=char(recovered_0db_nocoding(i));
    else
        recovered_0db_nocoding(i)='*';
    end
   if(i<=length(recovered_5db_nocoding))
        recovered_5db_nocoding(i)=char(recovered_5db_nocoding(i));
   else
        recovered_5db_nocoding(i)='*';
   end
   if(i<=length(recovered_10db_nocoding))
        recovered_10db_nocoding(i)=char(recovered_10db_nocoding(i));
   else
        recovered_10db_nocoding(i)='*';
   end 
end
%compute the errors
error_0db_conv=mean(text~=recovered_0db_conv(1:length(text)));
error_5db_conv=mean(text~=recovered_5db_conv(1:length(text)));
error_10db_conv=mean(text~=recovered_10db_conv(1:length(text)));
error_0db_nocoding=mean(text~=recovered_0db_nocoding(1:length(text)));
error_5db_nocoding=mean(text~=recovered_5db_nocoding(1:length(text)));
error_10db_nocoding=mean(text~=recovered_10db_nocoding(1:length(text)));
Names={'Error at 0dB with coding','Error at 5dB with coding','Error at 10dB with coding',...
'Error at 0dB without coding','Error at 5dB without coding','Error at 10dB without coding'};
Error=[error_0db_conv; error_5db_conv; error_10db_conv; error_0db_nocoding;...
error_5db_nocoding; error_10db_nocoding];
T = table(Error,'RowNames',Names);
disp(T);