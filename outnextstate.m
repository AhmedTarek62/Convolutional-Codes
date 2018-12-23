function [out,next_state] = outnextstate(input,state,g1,g2,g3)
%Inputs:
%Input to the current state
%state is the current state 
%g1,g2,g3 are generator polynomials
%Outputs:
%output if the given input is fed to the encoded at the current state
%next_state which is the next state due to receiving the input
state=[str2num(state(1)) str2num(state(2))];
register=[input state];
out=[sum(g1.*register) sum(g2.*register) sum(g3.*register)];
out(out==2)=0;
out(out==3)=1;
out=[num2str(out(1)) num2str(out(2)) num2str(out(3))];
next_state=[num2str(input) num2str(state(1))];
end

