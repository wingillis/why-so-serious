function roi_stackplot(cnmfe_file, movie_file, savefolder)
  num_plots = 10;
  colors = cubehelix(num_plots, 0.0, -0.34, 0.96, 0.83, [0.13 0.90], [0.19 0.85]);
  load(cnmfe_file);
  mf = matfile(movie_file);
  img = dff(mf, 1000);
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

  saveas(f, fullfile(savefolder, 'roi_stackplot'), 'epsc');
  print(f, fullfile(savefolder, 'roi_stackplot'), '-dpng', '-r300');

end % function
