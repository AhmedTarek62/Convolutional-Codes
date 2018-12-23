function [decoded,trellis] = viterbideco(encoded,g1,g2,g3,L)
%Note: the function is designed to work on a constraint length K=3
%Different usage will lead to errors
%Inputs:
%L is number of bits in a block
%g1, g2, g3 are three generator polynomials
%encoded is the sequence to be decoded
%Outputs:
%decoded is the output sequence
block_length=3*(L+2);
for h=1:length(encoded)/block_length
    %divide the sequence into blocks of size L
    unit=encoded((h-1)*block_length+1:h*block_length);
    trellis=cell(4,(L+2)*5);
    %set the states in the trellis in their appropriate position
    for i=1:5:(L+2)*5     
        for j=1:4
            if(j==1)
                trellis{j,i}='00';
            elseif(j==2)
                trellis{j,i}='01';
            elseif(j==3)
                trellis{j,i}='10';
            else
                trellis{j,i}='11';
            end
        end
    end 
    s=-2;
    %Trellis Generation
    for i=1:3:block_length
        s=s+2;
        if(i==1)
            j=1;
        else
            j=i+s;
        end
        block=[num2str(unit(i)>=1/2) num2str(unit(i+1)>=1/2) num2str(unit(i+2)>=1/2)];
        if(j==1)
            %initial run with only one state to consider
            [output0,nextstate0]=outnextstate(0,'00',g1,g2,g3);
            [output1,nextstate1]=outnextstate(1,'00',g1,g2,g3);
            trellis{1,j+1}=[nextstate0;nextstate1];
            trellis{1,j+2}=[output0;output1];
            trellis{1,j+3}=[sum(block~=output0) sum(block~=output1)];
            trellis{1,j+4}=['0';'1'];
            trellis{2,j+3}=[inf inf];
            trellis{3,j+3}=[inf inf];
            trellis{4,j+3}=[inf inf];
        else
            %checks if the node has been visited by checking the
            %next states of the previous run then computing all the
            %relevant parameters {next states,path metrics}
            for m=1:4
                counter=0;
                d=inf;
                for k=1:4
                    if(~cellfun(@isempty,trellis(k,j-4)))
                        if(strcmp(trellis{m,j},trellis{k,j-4}(1,:))==1)
                            [output0,nextstate0]=outnextstate(0,trellis{m,j},g1,g2,g3);
                            [output1,nextstate1]=outnextstate(1,trellis{m,j},g1,g2,g3);
                            trellis{m,j+1}=[nextstate0;nextstate1];
                            trellis{m,j+2}=[output0;output1];
                            if(trellis{k,j-2}(1)<d)
                                d=trellis{k,j-2}(1);
                                trellis{m,j+3}=[sum(block~=output0)+trellis{k,j-2}(1)...
                                sum(block~=output1)+trellis{k,j-2}(1)];
                                trellis{m,j+4}(1,:)=strcat(trellis{k,j-1}(1,:),'0');
                                trellis{m,j+4}(2,:)=strcat(trellis{k,j-1}(1,:),'1');
                            end
                            counter=counter+1;
                        elseif (strcmp(trellis{m,j},trellis{k,j-4}(2,:))==1)
                            [output0,nextstate0]=outnextstate(0,trellis{m,j},g1,g2,g3);
                            [output1,nextstate1]=outnextstate(1,trellis{m,j},g1,g2,g3);
                            trellis{m,j+1}=[nextstate0;nextstate1];
                            trellis{m,j+2}=[output0;output1];
                            if(trellis{k,j-2}(2)<d)
                                d=trellis{k,j-2}(2);
                                trellis{m,j+3}=[sum(block~=output0)+trellis{k,j-2}(2)...
                                sum(block~=output1)+trellis{k,j-2}(2)];
                                trellis{m,j+4}(1,:)=strcat(trellis{k,j-1}(2,:),'0');
                                trellis{m,j+4}(2,:)=strcat(trellis{k,j-1}(2,:),'1');
                            end
                            counter=counter+1;
                        end
                    end
                    if(counter==2)
                        break;
                    end
                    if(k==4&&counter==0)
                            trellis{m,j+3}=[inf inf];
                    end
                end
            end
        end
    end
    %Decision phase
    %finds the minimum hamming distance & set the decided sequence to be
    %the path which resulted in the minimum hamming distance
     distances=horzcat(trellis{1,5*(L+2)-1},trellis{2,5*(L+2)-1},...
    trellis{3,5*(L+2)-1},trellis{4,5*(L+2)-1});
     [~,I]=min(distances);
     if(mod(I,2)==0)
         p=2;
     else
         p=1;
     end
     decoded_unit=trellis{ceil(I/2),5*(L+2)}(p,:);
     decoded_unit=decoded_unit(1:length(decoded_unit)-2);
     decoded_str((h-1)*L+1:h*L)=decoded_unit;
end
%converts the decoded sequence of strings to a numeric array
decoded=zeros(1,length(decoded_str));
for i=1:length(decoded)
    decoded(i)=str2num(decoded_str(i));
end
end

