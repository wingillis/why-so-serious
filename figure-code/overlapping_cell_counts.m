function overlapping_cell_counts()
  values = [1 8 14;...
            1 25 24;...
            1 16 25];
  f = figure();
  bar(1, mean(a(:,1)), 'facecolor', [222 188 24]./255)
  bar(2, mean(a(:,2)), 'facecolor', [1 0 0])
  bar(3, mean(a(:,3)), 'facecolor', [0 1 0])
  errorbar(1:3, mean(a, 1), std(a, [], 1), 'k.')
  xticks(1:3)
  xticklabels({'both', 'red', 'green'});
  ylabel('# cells');
  f.PaperUnits = 'inches';
  f.PaperPosition = [0 0 4 3];
  saveas(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count', 'epsc');
  savefig(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count');
  print(f, '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/overlapping-cell-count', '-r300', '-dtiff');
end % function
