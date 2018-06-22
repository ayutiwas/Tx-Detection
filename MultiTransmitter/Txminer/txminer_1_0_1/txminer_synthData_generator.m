function [data,powers] = txminer_synthData_generator(numTx,deltaP,txType,ntr,nfsamps,ntsamps)

% This function generates synthetic data. It takes as an input:
% numTx - a number of transmitters to be generated
% deltaP - difference in the transmitters' powers
% txType - transmitters' types (e.g. broadcast, TDMA, FDMA, freqHop)
% ntr - noise to transmission ratio
% nfsamps - number of frequency samples per transmitter
% ntsamps - number of time samples per transmitter

baseP = -80;
data_mW = [];
powers = [];
for tx=1:numTx
    % Calculate the power of the current transmitter
    P = baseP + (tx-1)*deltaP;
    powers = [powers P];
    % Generate the measured signal from this transmitter by drawing from a
    % Rayleigh distribution with parameter b=P/sqrt(pi/2)
    P_mW = 10^(P/10);
    raylparam = P_mW/sqrt(pi/2);
    raylpop_mW = raylrnd(raylparam,ntsamps,nfsamps);
    data_mW = [data_mW raylpop_mW];
end
min(data_mW(:))
max(data_mW(:))
size(data_mW)
xx = [min(data_mW(:))*1.0e10:1:max(data_mW(:))*1.0e10];
size(xx)
% hist(xx,data_mW(:,:))
pdf_num = histc(data_mW(:),xx);
pdf_prob = pdf_num/length(data_mW(:));
bar(xx,pdf_prob);

[txrows txcols] = size(data_mW);
numTxSamps = txrows * txcols;
numNoiseSamps = ntr * numTxSamps;
noiserows = txrows; % we are looking to create a single matrix
noisecols = ceil(numNoiseSamps/noiserows);

% Generate the noise population of data
Pn = -105;
sigmaNoisedBm = 1;
Pn_mW = 10^(Pn/10);
sigmaNoise = abs(10^(Pn/10) - 10^((Pn+sigmaNoisedBm)/10))
% gaussianpop_mW = normrnd(Pn_mW, sigmaNoise, noiserows, noisecols);
gaussianpop_mW = normrnd(Pn_mW, sigmaNoise, noiserows, noisecols);

% Convert all the values to dBm before returning
data_dB = 10*log10(data_mW);
gaussianpop_dB = 10*log10(gaussianpop_mW);
% gaussianpop_dB = 10*log10(gaussianpop_mW)
% % 
% data_mW
% gaussianpop_mW
data = [gaussianpop_dB data_dB];
powers = [powers Pn];
