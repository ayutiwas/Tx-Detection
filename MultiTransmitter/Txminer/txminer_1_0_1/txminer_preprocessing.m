function [Rayl_init]=txminer_preprocessing(data,res,fsplits,tsplits,scaling,scaling_init,K_gmm);

% This function implements hierarchical preprocessing . It takes as an input
% raw data and provides as an output the number of components RGMM should
% fit.

nfres = fsplits^(res-1); % number of frequency chunks for the highest resolution
ntres = tsplits^(res-1); % number of frequency chunks for the lowest resolution
deltaf_res = length(data(1,:))/(fsplits^(res-1));
deltat_res = length(data(:,1))/(tsplits^(res-1));

%% Get the mixtures at each chunk of the finest resolution
for fn = 1:nfres
    for tn = 1:ntres
        tl = deltat_res*(tn-1) + 1;
        tu = deltat_res*tn;
        fl = deltaf_res*(fn-1) + 1;
        fu = deltaf_res*fn;
        dataChunk = data(tl:tu,fl:fu);
        size(dataChunk);
        gmm_model = txminer_fit_gmm(dataChunk(:),0,0,0,0,0,K_gmm);
        imagesc(0, 0, dataChunk);
        txminer_plot_gmm_fit(dataChunk(:),gmm_model,0,0,0,0,0)
        models_res{tn,fn} = gmm_model;
        gmm_model.Sigma;
    end
end

initializaitonMu = txminer_helper_cluster(models_res,res,fsplits,tsplits,data);
Rayl_init = initializaitonMu;
