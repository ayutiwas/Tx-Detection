function [signature] = txminer_signature_PP_time(norm_pdfs)

numComps = length(norm_pdfs(1,1,:));
numTimeSamps = length(norm_pdfs(:,1,1));
numFreqSamps = length(norm_pdfs(1,:,1));
%% Calculate probabilistic prevalence
probPrev = zeros(numComps,numFreqSamps);

for f=1:numFreqSamps
    for m=1:numComps
        probPrev(m,f) = sum(norm_pdfs(:,f,m))/numTimeSamps;
    end
end

signature = probPrev;