%% numOfMovesInBout=zeroCrossingCounter(mostVariantBout)
% This function counts number of zero crossings of the DC removed version 
% of the input signal. 
%       Input: 
%           inputBout- a column vector 
%  
%       Output: 
%           numOfMovesInBout- a number showing number of zero crossing in
%           the input signal
% 
%%
function numOfMovesInBout=zeroCrossingCounter(inputBout)

inputBoutDCremoved=inputBout-mean(inputBout);
inputBoutDCremovedShifted=[0;inputBoutDCremoved(1:end-1)];
ZeroInds=find((inputBoutDCremovedShifted.*inputBoutDCremoved)<0);
ZeroInds(find(diff(ZeroInds)<=30))=[];
% numOfMovesInBout=length(find((inputBoutDCremovedShifted.*inputBoutDCremoved)<0));
numOfMovesInBout=length(ZeroInds);
end