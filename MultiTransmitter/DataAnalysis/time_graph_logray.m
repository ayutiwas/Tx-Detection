clc
clear

load('1_signal_100_datafiles.mat');

time_win = [0.5 1 5];
n_fft = [1024 2048];
snr = 0:10:40;
ms = 1:3;

for fft_no = 1 : length(n_fft)
    for time_win_no = 1:2%length(time_win)
        for ms_no = 1 : length(ms)
            data = zeros(1,length(snr));
            for snr_no = 1:length(snr) 
                data(snr_no) = cell2mat(result.n_fft(fft_no).time_window(time_win_no).mul(ms_no).snr(snr_no).time_avg);
                data_ind(snr_no) = mean(cell2mat(result.n_fft(fft_no).time_window(time_win_no).mul(ms_no).snr(snr_no).time));
            end
            data_avg_log(fft_no,time_win_no,ms_no) = mean(data);
            data_ind_avg_log(fft_no,time_win_no,ms_no) = mean(data_ind);
        end
    end
end

save('data_logray.mat','data_avg_log','data_ind_avg_log');
            