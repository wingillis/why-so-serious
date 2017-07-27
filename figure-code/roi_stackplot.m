function roi_stackplot(movie_fname, cnmfe_fname, savefolder)
  num_plots = 5;
  colors = cubehelix(num_plots, 0.0, -0.93, 0.96, 0.83, [0.13 0.82], [0.19 0.85]);
  load(cnmfe_fname);
  mf = matfile(movie_fname);
  % TODO: do mean instead of dff
  % img = dff(mf, 9000);
  img = mean(double(mf.Y(:,:,1:9000)), 3);
  ptile = @(x) [prctile(x(:), 0.5) prctile(x(:), 99.5)];
  img = mat2gray(img, ptile(img));
  f1 = figure();
  imshow(repmat(img, 1, 1, 3));
  hold on;
  for i=1:num_plots
    h = imshow(permute(repmat(colors(i, :), d1, 1, d2), [1 3 2]));
    set(h, 'AlphaData', reshape(neuron.A(:,i), d1, d2));
  end
  hold off;

  f2 = figure();
  % TODO: decide btw C and C_raw
  data = neuron.C_raw(1:num_plots, 1:(30*60));
  % maxes = max(data, [], 2);
  % try doing total max instead of individual max
  maxes = max(data(:));
  additions = 1:num_plots;
  hold on;
  for i=additions
    data(i, :) = data(i, :) ./ maxes;
    data(i, :) = data(i, :) + i;
    plot(data(i,:), 'color', colors(i,:), 'LineWidth', 1.5);
  end
  plot([0 30*60], [0 0], 'k', 'LineWidth', 2);
  box off;
  axis tight;
  axis off;

  if nargin == 3
    f1.PaperUnits = 'inches';
    f1.PaperPosition = [0 0 8.5 5.5];
    f2.PaperUnits = 'inches';
    f2.PaperPosition = [0 0 8.5 5.5];
    saveas(f1, fullfile(savefolder, 'roi-stackplot-1'), 'epsc');
    saveas(f1, fullfile(savefolder, 'roi-stackplot-1'));
    print(f1, fullfile(savefolder, 'roi-stackplot-1'), '-dpng', '-r300');
    print(f1, fullfile(savefolder, 'roi-stackplot-1'), '-dtiff', '-r600');

    saveas(f2, fullfile(savefolder, 'roi-stackplot-2'), 'epsc');
    saveas(f2, fullfile(savefolder, 'roi-stackplot-2'));
    print(f2, fullfile(savefolder, 'roi-stackplot-2'), '-dpng', '-r300');
    print(f2, fullfile(savefolder, 'roi-stackplot-2'), '-dtiff', '-r600');
  end

end % function
