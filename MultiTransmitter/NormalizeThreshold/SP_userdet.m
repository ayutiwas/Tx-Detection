clc
clear

addpath('../../');
import param_vals.*;

monte_carlo = param_vals.monte_carlo;
symbol_no = param_vals.symbol_no;
mod_type = param_vals.mod_type;
% snr_value = 0:11:40; % because gnuradio data is like this
training_data_no = param_vals.training_data_no;
numfiles = param_vals.numfiles;


pfa = param_vals.pfa;
n_fft = param_vals.n_fft;
snr = param_vals.snr_mtx;

result = repmat(struct, numfiles, 1);

for fft_no = 1:numel(n_fft)
    for multiscale = param_vals.multiscale
        for snr_no = 1:numel(snr)
                fprintf('FFT Size:%d \t Multiscale:%d \t SNR:%d dB\n',n_fft(fft_no),multiscale,snr(snr_no)); 
                parfor file_no = 1:numfiles
                tf = 2^multiscale;
                data = read_complex_binary(strcat('../DataGenerate/data_5tx_',int2str(snr(snr_no)),'dB_',int2str(file_no),'.dat'));
                if numel(data) == 0
                    fprintf("ERROR\n");
                end
                %load('noise_5tx_sp.mat');
                b = tic;
                data_part = data_divide(data,multiscale,n_fft(fft_no));
                noise = get_noise(data_part);
                det = zeros(tf,1);
                for i = 1 : tf
                    for j = 1 : tf
                        signal = data_part(i,j,:);
                        signal = signal(:);
                        n = length(signal);
                        tau = gammaincinv(pfa,n,'upper')/n;
                        test_statistics = 0.5 * mean(abs(signal).^2)/mean(abs(noise).^2);

                        if(test_statistics > tau)
                            det(i,j) = test_statistics;
                        else
                            det(i,j) = 0;
                        end
                    end
                end
                if sum(det(:)) == 0
                    no_tx = 0;
                else
                    det1 = (det-mean(det(:)))/sqrt(var(det(:)));
                    no_tx = (length(txminer_cluster_res(det1(:),0.3)) - 1);
                end
                result(file_no).multi_scale(multiscale).fft(fft_no).snr(snr_no).data = no_tx;
                result(file_no).multi_scale(multiscale).fft(fft_no).snr(snr_no).time = toc(b);
                
            end
        end
    end
end
save('result_5tx_SP.mat','result');

