function roi_stackplot(cnmfe_file)
  load(cnmfe_file);

  num_plots = 10;
  figure();

  % plot only the first ten neurons
  data = neuron.C(1:num_plots, :);
  data = zscore(data, [], 2);
  additions = 1:num_plots;
  data = data * additions';

  plot(data);

end % function
