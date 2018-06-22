function [signature] = txminer_signature_PP_freq(norm_pdfs)

numComps = length(norm_pdfs(1,1,:));
numTimeSamps = length(norm_pdfs(:,1,1));
numFreqSamps = length(norm_pdfs(1,:,1));
%% Calculate probabilistic prevalence
probPrev = zeros(numComps,numTimeSamps);

for t=1:numTimeSamps
    for m=1:numComps
        probPrev(m,t) = sum(norm_pdfs(t,:,m))/numFreqSamps;
    end
end

signature = probPrev;