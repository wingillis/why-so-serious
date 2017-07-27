function overlapping_cell_counts()
  values = [1 8 14;...
            1 25 24;...
            1 16 25;...
            18 223 309;...
            24 213 263];
  totals = sum(values, 2);
  for i=1:size(values, 1)
    values(i,:) = values(i,:) ./ totals(i);
  end
  f = figure();
  hold on;
  bar(1, mean(values(:,1)), 'facecolor', [222 188 24]./255);
  bar(2, mean(values(:,2)), 'facecolor', [1 0 0]);
  bar(3, mean(values(:,3)), 'facecolor', [0 1 0]);
  errorbar(1:3, mean(values, 1), std(values, [], 1), 'k.')
  xticks(1:3)
  xticklabels({'both', 'red', 'green'});
  ylabel('proportion');
  f.PaperUnits = 'inches';
  f.PaperPosition = [0 0 4 3];
  saveas(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count', 'epsc');
  savefig(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count');
  print(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count', '-r300', '-dtiff');
end % function
