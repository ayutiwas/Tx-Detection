clear all
close all
warning('off','all');
%tic % begin timer
%+++++++++++++++++++++++++++++++++++++++==========
% INPUT parameters
RUNS = 1;
% TV settings
fStep = 8;
sFreq = 536;
eFreq = 536;
numBins = length(sFreq:fStep:eFreq);
%filecontent = struct;
runSpec = struct;
runSpec.('dataType') = 'real'; % controlled or real
runSpec.('freqRange') = 'sample_run'; % a string specifying the frequency range; or in other words the input file.
[filecontent,rangeST] = txminer_load_filecontent(runSpec.freqRange);
runSpec.('noise') = 'quantile-all-bands'; % uhf or empirical or wimax or bluetooth or wifi
 % resolution for the hierarchical initialization
runSpec.('fsplits') = 2; % number of frequency splits per resolution
runSpec.('tsplits') = 2; % number of time splits per resolution
runSpec.('startTime') = 44886; % in seconds
runSpec.('timeWindow') = 100; % in seconds
runSpec.('scaling') = 100; % this is a factor that scales the original data. Necessary for RGMM.
runSpec.('scaling_init') = 100; % this is a factor that scales the initialization values for RGMM.
% end INPUT parameters

% OUTPUT: Result arrays
models = cell(RUNS,numBins);
transmitters = cell(RUNS,numBins);
% end results arrays


% Set some more run-dependent input parameters
runSpec.('startFreq') = sFreq; % in MHz
runSpec.('endFreq') = eFreq +fStep; % in MHz
%pobj = parpool('LocalProfile1',24);
result = struct;
fft_n = [1024 2048];
time_win = [5000 10000 50000];
snr = [0 10 20 30 40];
%filecontent = importdata('Redmond99_130401_122821_512-700.tsv','\t');
for time_window_no = 1 : 3
    for n_fft_no = 1 : 2
        for multi_scale = 1 : 3
            runSpec.('res') = multi_scale;
            for snr_no = 1:5
                time_ = cell(1,100);
                data_ = cell(1,100);
                type_ = cell(1,100);
                b_time = tic;
                fprintf('Window:%d \t FFT Size:%d \t Multiscale:%d \t SNR:%4.2f dB \n',time_win(time_window_no),fft_n(n_fft_no),multi_scale,snr(snr_no));
                parfor file_no = 1:100
                    tic;

                    data = read_complex_binary(strcat('../../DataGenerate/data_2tx_',int2str(snr(snr_no)),'dB_',int2str(file_no),'.dat'));
                    [~,~,~,ps] = spectrogram(data,hamming(time_win(time_window_no)),0,fft_n(n_fft_no),10e6,'centered');
                    ps = 10*log10(ps');
                    [m,n] =size(ps);
                    act_data = ones(m,n+2);
                    act_data(:,1) =500;
                    act_data(:,2) =700;
                    act_data(:,3:end) = ps;
%                     filecontent.data = act_data;
%                     filecontent.textdata = filecontent.textdata(1:m,:);

                    [signature_freq,signature_time,model,TXers,data] = txminer_main(runSpec,act_data,filecontent.textdata);
                    time_(file_no) = {toc};
                    num_transmitter = length(TXers);
                    for i = 1 : length(TXers)
                        num_transmitter = num_transmitter - isempty(TXers{i});
                    end
                    
                    data_(file_no) = {num_transmitter};
                    type_(file_no) = {strcat(int2str(snr(snr_no)),'dB ','file_no:',int2str(file_no))};
                end
                result.n_fft(n_fft_no).time_window(time_window_no).mul(multi_scale).snr(snr_no).time_avg = {toc(b_time)};               
                result.n_fft(n_fft_no).time_window(time_window_no).mul(multi_scale).snr(snr_no).time = time_;
                result.n_fft(n_fft_no).time_window(time_window_no).mul(multi_scale).snr(snr_no).data = data_;
                result.n_fft(n_fft_no).time_window(time_window_no).mul(multi_scale).snr(snr_no).type = type_;
            end
        end
    end
end

delete(pobj);
save('2_signal_100_datafiles.mat','result')
