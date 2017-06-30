function [neuron_count]=merging_neurons(neuron, spike_thresh)
  display_merge = false;
  view_neurons = false;
  npoints = 25;
  neuron_win = neuron.copy();

  neuron_count = zeros(npoints, npoints);

  % which correlation thresholds to change
  spatial = linspace(0.3, 0, npoints);
  temporal = linspace(0.3, 0, npoints);

  merge_thr = [1, 1, spike_thresh];

  for i=1:npoints
    merge_thr(1) = spatial(i);
    neuron = neuron_win.copy();
    for j=1:npoints
      merge_thr(2) = temporal(j);
      cnmfe_quick_merge;
      neuron_count(i, j) = size(neuron.C, 1);
    end
  end
end % function
