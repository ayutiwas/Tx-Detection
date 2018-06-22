clc
clear

num_users = 5; %enter the number of users here

time_win = [0.5 1];

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

%Result Data Load
load(strcat(num2str(num_users),'_signal_100_datafiles_lrmm'));
result_lrmm = result;
clear result;

load(strcat(num2str(num_users),'_signal_100_datafiles_txminer'));
result_txminer = result;
clear result;

load(strcat('result_',num2str(num_users),'tx_SP'));
result_SP = result;
clear result;

for fft_no = 1
    for time_win_no = 1
        for ms_no = 1 :length(ms)
            for snr_no = 1:length(snr)
                for i = 1 : numfiles
                    %For LRMM
                    data_lrmm = cell2mat(result_lrmm.n_fft(fft_no).time_window(time_win_no).mul(ms_no).snr(snr_no).data(i));
                    length_data = length(data_lrmm);
                    accu_lrmm(i) = (1-abs(num_users+1-length_data)/(1+num_users))*100;
                    %For TxMiner
                    data_txminer = cell2mat(result_txminer.n_fft(fft_no).time_window(time_win_no).mul(ms_no).snr(snr_no).data(i));
                    accu_txminer(i) = (1-abs(num_users-data_txminer)/num_users)*100;
                    %For SP
                    data_SP(i) = cell2mat(result_SP(i).multi_scale(ms_no).fft(fft_no).snr(snr_no).data);
                    accu_SP(i) = (num_users-(abs(data_SP(i)-num_users)))/num_users*100;
                end
                %for LRMM
                accu_lrmm_snr(snr_no) = mean(accu_lrmm);
                %for TxMiner
                accu_txminer_snr(snr_no) = mean(accu_txminer);
                %for SP
                accu_SP_snr(snr_no) = mean(accu_SP);
            end
            %For LRMM
            accu_lrmm_ms(ms_no,:) = accu_lrmm_snr;
            %for TxMiner
            accu_txminer_ms(ms_no,:) = accu_txminer_snr;
            %for SP
            accu_SP_ms(ms_no,:) = accu_SP_snr;
        
        
        if ms_no > 1
            f = figure;
           
            
            numb = ms_no; %enter the multiscale value 
            plot(snr,accu_lrmm_ms(numb,:),'--d','LineWidth',4,'MarkerSize',16);
             hold on;
            %plot(snr,accu_lrmm_ms(2,:),'-.b*','LineWidth',5);
            %plot(snr,accu_lrmm_ms(3,:),'-g*','LineWidth',5);
            plot(snr,accu_txminer_ms(numb,:),'--*','LineWidth',4,'MarkerSize',16);
            %plot(snr,accu_txminer_ms(2,:),'-.bo','LineWidth',5);
            %plot(snr,accu_txminer_ms(3,:),'-go','LineWidth',5);
            plot(snr,accu_SP_ms(numb,:),'--o','LineWidth',4,'MarkerSize',16);
            %plot(snr,accu_SP_ms(2,:),'-.bd','LineWidth',5);
            %plot(snr,accu_SP_ms(3,:),'-gd','LineWidth',5);
            set(gca,'fontsize', 18);
            axis([0 43 0 100]);
            %title(sprintf('SNR vs Accuracy, TxMiner''s Method\n No. of TX''s: 1 Time Window: %.1f ms and nfft: %d',time_win(time_win_no),n_fft(fft_no)));
            xlabel('SNR(dB)');
            ylabel('Accuracy (%)');
            legend('LRMM','TxMiner','Norm. Thres');
            %saveas(f,strcat('fig_',int2str(num_users),'_sig_',int2str(fft_no),int2str(time_win_no),'.eps'),'epsc');
            %saveas(f,strcat('fig_',int2str(num_users),'_sig_',int2str(fft_no),int2str(time_win_no),'.jpg'),'jpeg');
           %legend('boxoff'); 
            %legend('Location','southwest');
            hold off;
        end
        
        end
    end
end

                    
                    
                    