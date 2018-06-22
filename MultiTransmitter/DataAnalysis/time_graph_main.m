clc
clear

load('data_logray.mat');
load('data_sp.mat');
load('data_txminer.mat');

time_win = [0.5 1];
fft_no = [1024 2048];

for f = 1 :2
    for w =  1:2   
        data_log = data_avg_log(f,w,:);
        data_log = data_log(:)/100;
        data_txminer = data_avg_txminer(f,w,:);
        data_txminer = data_txminer(:)/100;
        data_sp = data_all_mean_sp(f,:);
        bar_plot = [data_log(2:3)';data_txminer(2:3)';data_sp(2:3)];
        %c = categorical({'Log-Rayleigh','TxMiner','Energy Detection'},'Ordinal',false);
        fig = figure;
        bar(bar_plot);
        axis([0 4 0 10]);
        legend('Multiscale 2','Multiscale 3');
        %set(gcf,'LineWidth', 4);
        set(gca,'fontsize', 18);
        set(gca,'xticklabel',{'LRMM','TxMiner','Norm. Thr.'});
        ylabel('Time (s)');
        %title(sprintf('Time Complexity \n Time Window: %.1f ms nfft: %d',time_win(w),fft_no(f)));
        %saveas(fig,strcat('fig_time_',int2str(f),int2str(w),'.eps'),'epsc')
    end
        
end
