clc
clear

load('../Normalize Threshold/result_5tx_SP.mat');

addpath('../../');
import param_vals.*;

monte_carlo = param_vals.monte_carlo;
symbol_no = param_vals.symbol_no;
mod_type = param_vals.mod_type;
snr_value = param_vals.snr;
training_data_no = param_vals.training_data_no;
numfiles = param_vals.numfiles;


pfa = param_vals.pfa;
n_fft = param_vals.n_fft;
snr = param_vals.snr_mtx;
ms = param_vals.multiscale;

% n_fft = [1024 2048];
% snr = 0:10:40;
% ms = 1:3;
user_num = 5;

for fft_no = 1 : length(n_fft)
    for ms_no = 1 : length(ms)
        for snr_no = 1:length(snr)
            data = zeros(param_vals.numfiles, 1);
            for i = 1:param_vals.numfiles
                data(i) = result(i).multi_scale(ms_no).fft(fft_no).snr(snr_no).time;
%                 data = [data result(i).multi_scale(ms_no).fft(fft_no).snr(snr_no).time];
            end
            data_mean(snr_no) = mean(data);
        end
        data_all_mean_sp(fft_no,ms_no) = mean(data_mean);
    end
end

save('data_sp.mat','data_all_mean_sp');

        