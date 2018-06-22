function []=txminer_plot_percent_rgmm_time(mu_percent,xrange,RayleighMu, RayleighWt, noiseMu, noiseSigmaSq, noiseWt, domain)

line_type = {'g-'; 'r-'; 'k-'; 'c-'; 'm-'; 'g-.'; 'r-.'; 'b-.'; 'c-.'; 'm-.'; 'g:'; 'r:'; 'k:'; 'c:'; 'm:'; 'c:';'g:'};

figure(4);
hold on; box on;
set(gca, 'LineWidth', 2, 'FontSize',30);%, 'Position', [.1 .1 3 5]);%,'PlotBoxAspectRatio',[3 1.5 1]);%, 'FontWeight', 'bold');

for i=1:length(mu_percent(:,1))
    plot(xrange,mu_percent(i,:),line_type{i}, 'LineWidth', 4, 'MarkerSize', 8);
    if(i<=length(mu_percent(:,1))-1) % The first N-1 components are due transmission
        legendInfo{i} = [sprintf('%0.1f',10*log10(RayleighMu(i))),', ',sprintf('%0.1f',RayleighWt(i))];
    end
    if(i==length(mu_percent(:,1))) % The final component fits over noise.
        %legendInfo{i} = [sprintf('%0.1f',10*log10(noiseMu/100)),', ',sprintf('%0.1f',10*log10(noiseSigmaSq)),', ',sprintf('%0.1f',noiseWt)];
        legendInfo{i} = [sprintf('%0.1f',10*log10(noiseMu)),', ',sprintf('%0.1f',noiseWt)];
    end
end
legend(legendInfo,'Location','NorthOutside');%SouthOutside
legend boxoff
ylabel('Prevalence')
xlabel('Time sample ID');

hold off;
end
