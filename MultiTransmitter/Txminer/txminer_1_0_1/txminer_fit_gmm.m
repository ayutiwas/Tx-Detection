function [model] = txminer_fit_gmm(X,fStart,fEnd,freqrange,minhold,maxhold,k)
% OUT: AIC, BIC, Iters, NComponents, mu, Sigma, span, PComponents,dataAboveThresh,totalData
% IN: 

ITERATIONS = 20;

K = k;

BIC = zeros(1,K);
AIC = zeros(1,K);
obj = cell(1,K);

% Fit Gaussians
for k = 1:K   
    BICi = zeros(1,ITERATIONS);
    AICi = zeros(1,ITERATIONS);
    %NlogLi = zeros(1,ITERATIONS);
    obji = cell(1,ITERATIONS);
    for i=1:ITERATIONS        
        obji{i} = gmdistribution.fit(X,k,'Regularize', 1e-5);%,'Options',options);
        BICi(i)= obji{i}.BIC;                
        AICi(i)= obji{i}.AIC; 
    end   
    [minBICi,idxb] = min(BICi);  
    [minAICi,idxa] = min(AICi);
    
    obj{k} = obji{idxb};
    BIC(k) = minBICi;    
    AIC(k) = minAICi;
end

% Pick the best fit based on min BIC.
[minScore,numComponents] = min(BIC);
model = obj{numComponents};

model.disp