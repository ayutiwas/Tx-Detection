function [model] = txminer_helper_model_struct(BIC,RayleighWt,noiseWt,RayleighMu,noiseMu,noiseSigmaSq)

% This is a helper funciton to create a structure for the RGMM model

% Find out the number of components (num of Rayleighs plus one for noise)
numComps = length(RayleighMu)+1;

% Construct mu
rgmm_mu_mW = [RayleighMu'; noiseMu];
rgmm_mu = 10*log10(rgmm_mu_mW);

% Construct BIC
rgmm_bic=BIC;

% Construct NComponents
rgmm_nComps=numComps;

% Construct PComponents
rgmm_PComponents = [RayleighWt noiseWt];

% Construct Sigma. 
rgmm_Sigma = zeros(1,1,numComps);
for i=1:numComps
    if(i < numComps) % Rayleigh components don't have sigma
        rgmm_Sigma(1,1,i) = -99;
    end
    if(i == numComps)
        rgmm_Sigma(1,1,i) = noiseSigmaSq;
    end
end

model=struct('mu',rgmm_mu,'BIC',rgmm_bic,'NComponents',rgmm_nComps,'PComponents',rgmm_PComponents,'Sigma',rgmm_Sigma);



