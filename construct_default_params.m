function [options] = construct_default_options()
  options.patch_sz = [64 64];
  options.overlap = [20 20];
  options.min_patch = [16 16];
  options.gauss_kernel = 5;
  options.neuron_dia = 10;
  options.min_corr = 0.8;
  options.min_pnr = 20;
  options.bd = 0;
  options.dendrites = false;
  options.max_neurons = [];

  options.spatial_corr = 0.6;
  options.temporal_corr = 0.5;
  options.spiketime_corr = 0.1;
end % function
