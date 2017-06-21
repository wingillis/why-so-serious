figure();
thresholds = [0 0.1 0.2 0.25 0.29 0.33 0.4];
for i=1:length(thresholds)
  % what am I doing here? I am using different thresholds for the changepoints
  g.find_cp_peaks(thresholds(i));
  [xi, f] = ksdensity(diff(g.changepoints));
  plot(f, xi, 'LineWidth', 2);
  hold on;
end

legend(cellfun(@(x) num2str(x), num2cell(thresholds), 'UniformOutput', false));
xlabel('Frames btw changepoints')
ylabel('Probability')
title('Comparison of cp peaks with different thresholds')
