function [] = txminer_plot_gmm_fit(X,model,freqrange,minhold,maxhold,fStart,fEnd)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

xx=[min(X):1:max(X)];
%% Plot GMM.fit
figure(1);
clf('reset');
hold on; box on;
set(gca, 'LineWidth', 2, 'FontSize',30);%, 'Position', [.1 .1 3 5]);%,'PlotBoxAspectRatio',[3 1.5 1]);%, 'FontWeight', 'bold');

pdf_num = histc(X,xx);
pdf_prob = pdf_num/length(X);
bar(xx,pdf_prob);

for j=1:model.NComponents
    line(xx,model.PComponents(j)*normpdf(xx,model.mu(j),sqrt(model.Sigma(j))),'color','r','linewidth',4)
    line([model.mu(j) model.mu(j)],[0 0.1],'color','m','linewidth',3)
end

xlabel('PSD, dBm/Hz');
ylabel('PDF')

end

