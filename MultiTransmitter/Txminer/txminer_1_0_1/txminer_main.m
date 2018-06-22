function [signature_freq,signature_time,model,transmitters,data] = txminer_main(runSpec, data, textdata)                                                                                                                                                              

[m,~] = size(data);
filecontent.data = data;
filecontent.textdata = textdata(1:m,:);
tWin = runSpec.timeWindow; % in seconds
tOffset = runSpec.startTime; %0; % in seconds
fStart = runSpec.startFreq; %518; % in MHz
fEnd = runSpec.endFreq; %524; % in MHz
dataType = runSpec.dataType; % synthetic or real or compressed
noise = runSpec.noise; % how do we pick the noise floor
scaling = runSpec.scaling;
scaling_init = runSpec.scaling_init;
res = runSpec.res;
tsplits = runSpec.tsplits;
fsplits = runSpec.fsplits;
K = 4; % Try up to K components for initialization


%% Get data
if(strcmp(dataType,'real')==1)
    [data, freqrange, timerange, freqStep, timeStep] = txminer_data_extractor_indexing(filecontent,tWin,tOffset,fStart,fEnd);
end

%% Convert the data snippet from dBm to mW
% It is important to note that the Rayleigh/Gaussian nature of 
% radio signals is applicable to absolute power (in mW) and does 
% not hold for logarithmic power ratios measured in dBm. Since our
% data was stored in dBm, we had to take this imtermediate step 
% to convert dBm to mW and make sure that the undelying mixture model 
% corresponds to the nature of the spectrum measurements.
data_mW = zeros(size(data,1),size(data,2));
for i=1:size(data,1)
    for j=1:size(data,2)
        data_mW(i,j) = scaling*10^(data(i,j)/10);
    end
end


%% Get min-hold, max-hold and frequency matrix (the frequency matrix is a 
% list of all frequency bins in the user-defined frequency range. Need this 
% for visualization purposes.)
minhold = zeros(1,length(data(1,:)));
maxhold = zeros(1,length(data(1,:)));
avghold = zeros(1,length(data(1,:)));
for i=1:length(data(1,:))
    minhold(i)=min(data(:,i));
    maxhold(i)=max(data(:,i));
    avghold(i)=mean(data(:,i));
end

%% Fit
% Get domain knowlegde about noise floor
[noiseMU, noiseSIGMA, noisePC] = txminer_get_noise_floor(noise,data(:));
noiseTHR = noiseMU;

% BEGIN mixture initialization
% using hierarchical clustering to initialize RGMM
all_init = txminer_preprocessing(data,res,fsplits,tsplits,scaling,scaling_init,K);
[tx_idx] = find(all_init > noiseTHR);
Rayl_init = all_init(tx_idx)';

% Set the initialization
init_noiseMu = 10^(noiseMU/10);
init_noiseSigmaSq = 8.1879e-12; % empirical from measurements
init_RayleighMu = zeros(1,length(Rayl_init));
for i=1:length(Rayl_init)
    init_RayleighMu(i) = 10^(Rayl_init(i)/10);
end
weights = 1/(length(init_RayleighMu)+1); % Initializing all comps with the same weight.
init_RayleighWt = weights * ones(1,length(init_RayleighMu));
init_noiseWt = weights;
% END mixture initialization

% Fit RGMM
[probMat, RayleighMu_unscaled, noiseMu_unscaled, noiseSigmaSq, RayleighWt, noiseWt, BIC] = MixModel(data_mW, scaling_init*init_RayleighMu,...
    scaling_init*init_noiseMu, init_noiseSigmaSq, init_RayleighWt, init_noiseWt);

% BEGIN Visual comparison between the guessed and inferred parameters.
RayleighMu = RayleighMu_unscaled/scaling_init;
noiseMu = noiseMu_unscaled/scaling_init;
probMat;
size(probMat);
%disp('Guessed parameters for Raylegh distros and Gaussian');
init_RayleighMu;
10*log10(init_RayleighMu);
init_noiseMu;
10*log10(init_noiseMu);
init_noiseSigmaSq;
%disp('EM-inferred parameters for Rayleigh and Gaussian')
RayleighMu;
10*log10(RayleighMu);
noiseMu;
10*log10(noiseMu);
noiseSigmaSq;

%disp('Guessed mixing weights for Rayleigh and Gaussian');
init_RayleighWt;
init_noiseWt;
%disp('EM-inferred mixing weights for Rayleigh and Gaussian');
RayleighWt;
noiseWt;
BIC;
% END Visual comparison between the guessed and inferred parameters.

% Create a model structure for further evaluation.
[model] = txminer_helper_model_struct(BIC,RayleighWt,noiseWt,RayleighMu,noiseMu,noiseSigmaSq);


%% Smooth association probabilities

% Get association probabilities
norm_pdfs = probMat;

% Smooth association probabilities (we use belief propagation) 
[norm_pdfs_signature] = txminer_apply_bp(data,norm_pdfs);

% Extract the transmitter signatures in frequency and time
[signature_freq] = txminer_signature_PP_time(norm_pdfs_signature); % Prevalence in Frequency Bins
[signature_time] = txminer_signature_PP_freq(norm_pdfs_signature); % Prevalence in Time Bins

%% Plot signatures
txminer_plot_percent_rgmm_freq(signature_freq,freqrange, RayleighMu, RayleighWt, noiseMu, noiseSigmaSq, noiseWt, 'frequency');
txminer_plot_percent_rgmm_time(signature_time,timerange, RayleighMu, RayleighWt, noiseMu, noiseSigmaSq, noiseWt, 'time');

%% EVALUATION (aka summarization of transmitter characteristics based on the extracted signatures)

[comp_occupies_freq] = txminer_transmitters1(signature_freq,freqrange,model);
[comp_occupies_time] = txminer_transmitters1(signature_time,timerange,model);

[transmitters] = txminer_tx_characteristics(comp_occupies_freq,comp_occupies_time,freqrange,signature_freq,timerange,signature_time,model,noiseTHR);
end
