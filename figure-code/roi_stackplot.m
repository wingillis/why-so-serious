function roi_stackplot(movie_fname, cnmfe_fname, savefolder)
  num_plots = 10;
  colors = cubehelix(num_plots, 0.0, -0.93, 0.96, 0.83, [0.13 0.82], [0.19 0.85]);
  load(cnmfe_fname);
  mf = matfile(movie_fname);
  % TODO: do mean instead of dff
  % img = dff(mf, 9000);
  img = mean(double(mf.Y(:,:,1:9000)), 3);
  ptile = @(x) [prctile(x(:), 0.5) prctile(x(:), 99.5)];
  img = mat2gray(img, ptile(img));
  f = figure();
  subplot(2, 1, 1);
  imshow(repmat(img, 1, 1, 3));
  hold on;
  for i=1:num_plots
    h = imshow(permute(repmat(colors(i, :), d1, 1, d2), [1 3 2]));
    set(h, 'AlphaData', reshape(neuron.A(:,i), d1, d2));
  end
  hold off;

  subplot(2,1,2);
  % TODO: decide btw C and C_raw
  data = neuron.C_raw(1:num_plots, :);
  maxes = max(data, [], 2);
  additions = 1:num_plots;
  hold on;
  for i=additions
    data(i, :) = data(i, :) ./ maxes(i);
    data(i, :) = data(i, :) + i;
    plot(data(i,:), 'color', colors(i,:));
  end
  box off;
  axis tight;
  axis off;

  if nargin == 3
    f.PaperUnits = 'inches';
    f.PaperPosition = [0 0 8.5 11];
    saveas(f, fullfile(savefolder, 'roi-stackplot'), 'epsc');
    saveas(f, fullfile(savefolder, 'roi-stackplot'));
    print(f, fullfile(savefolder, 'roi-stackplot'), '-dpng', '-r300');
  end

end % function
