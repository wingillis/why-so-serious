g.z_score_cells();
g.find_active_cells(2); % 2x std of z-scored cells
figure();
thresholds = [0 0.1 0.2 0.25 0.29 0.33 0.4];
for i=1:length(thresholds)
  g.find_cp_peaks(thresholds(i));
  g.align_activity2cps(61);
  vals = g.activity_cp_aligned;
  v = squeeze(sum(vals, 2));
  muv = mean(v, 1)';
  muv = zscore(muv);
  plot(muv, 'LineWidth', 2);
  hold on;
end

legend(cellfun(@(x) num2str(x), num2cell(thresholds), 'UniformOutput', false));
xticklabels(linspace(-1, 1, 7));
xlabel('Lag to onset of changepoint (s)')
ylabel('Cell activity (z-scored)')
title('Cell activity aligned to changepoints; showing diff peak cp thresholds')
