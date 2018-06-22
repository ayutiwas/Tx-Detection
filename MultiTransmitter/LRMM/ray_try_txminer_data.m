clear
clc
% pobj = parpool('local');

result = struct;
k = 5;
% fft_n = [1024 2048];
time_win = [5000 10000 50000];
% snr = [0 10 20 30 40];

addpath('../../');
import param_vals.*;

monte_carlo = param_vals.monte_carlo;
symbol_no = param_vals.symbol_no;
mod_type = param_vals.mod_type;
snr_value = param_vals.snr;
training_data_no = param_vals.training_data_no;
numfiles = param_vals.numfiles;


pfa = param_vals.pfa;
fft_n = param_vals.n_fft;
snr = param_vals.snr_mtx;
ms = param_vals.multiscale;

%filecontent = importdata('Redmond99_130401_122821_512-700.tsv','\t');
for time_window_no = 1 : numel(time_win)
    for n_fft_no = 1 : numel(fft_n)
        for multi_scale = param_vals.multiscale
            count_ = 1;
            for snr_no = 1:numel(snr)
                time_ = cell(1,numfiles);
                data_ = cell(1,numfiles);
                type_ = cell(1,numfiles);
                
                b_time = tic;
                
                parfor file_no = 1:param_vals.numfiles
                    tic;
                    data = read_complex_binary(strcat('../DataGenerate/data_2tx_',int2str(snr(snr_no)),'dB_',int2str(file_no),'.dat'));
                    fprintf('Window:%d \t FFT Size:%d \t Multiscale:%d \t SNR:%d dB \t File No: %d\n',time_win(time_window_no),fft_n(n_fft_no),multi_scale,snr(snr_no),file_no);
                    %data = read_complex_binary(strcat('/home/wsrg/verilog/research-ayush/python/data_file/data_0dB_6.dat'));
                    %data = filecontent.data;
                    [~,~,~,ps] = spectrogram(data,hamming(time_win(time_window_no)),0,fft_n(n_fft_no),10e6,'centered');
                    data = 10 * log10(ps');
                    mu_all = [];
                    mu_unclustered = [];
                    phi_all = [];
                    phi_unclustered = [];
                    figno = 1;
                    %multi_scale = 1;
                    d = data_txminer_partition(data,multi_scale);
                    %clear data; 
                    for i_ = 1 : 2^multi_scale
                        for j_ = 1 : 2^multi_scale
                            b = d(i_,j_,:,:);
                            data = b(:)/(10*log10(exp(1)));
                            %subplot(2^multi_scale,2^multi_scale,figno);
                            %plot(data*10*log10(exp(1)));
                            figno = figno + 1;
                            l = zeros(1,k);
                            bic = zeros(1,k);
                            aic = zeros(1,k);

                            for i = 1 : k
                                [mu, phi] = LogRayMM(data,i);
                                [l(i), bic(i), aic(i)] = llr_logray(data,mu, phi);
                                if i == 1
                                    prevAIC = aic(i);
                                    mu_min_aic = mu;
                                    phi_min_aic = phi;
                                else
                                    if prevAIC > aic(i)
                                       mu_min_aic = mu;
                                       phi_min_aic = phi;
                                    end
                                end
                            end
                            [mu,phi] = sort_(mu,phi);
                    %         if length(mu) == 1
                    %             mu_all = [mu_all mu];
                    %         elseif length(mu) > 1
                    %             [idx,c] = kmeans(mu',2);
                    %             mu_all = [mu_all c'];
                    %         end
                            mu_unclustered = [mu_unclustered mu];
                            phi_unclustered = [phi_unclustered phi];
                        end
                    end
                    time_(file_no) = {toc};
                    data_(file_no) = {txminer_cluster_res(mu_unclustered * 10 * log10(exp(1)),8)};
                    type_(file_no) = {strcat(int2str(snr(snr_no)),'dB ','file_no:',int2str(file_no))};
                    %count_ = count_ + 1;

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
