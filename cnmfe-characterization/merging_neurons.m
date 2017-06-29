function [neuron_count]=merging_neurons(neuron)
  display_merge = false;
  view_neurons = false;
  npoints = 30;
  neuron_win = neuron.copy();

  neuron_count = zeros(npoints, npoints, npoints);

  % which correlation thresholds to change
  spatial = linspace(0.3, 0, npoints);
  temporal = linspace(0.3, 0, npoints);
  spiking = linspace(0.1, 0, npoints);

  merge_thr = [1, 1, 0.1];

  for i=1:npoints
    merge_thr(1) = spatial(i);
    for j=1:npoints
      merge_thr(2) = temporal(j);
      neuron = neuron_win.copy();
      for k=1:npoints
        merge_thr(3) = spiking(k);
        cnmfe_quick_merge;
        neuron_count(i, j, k) = size(neuron.C, 1);
      end
    end
  end
end % function
