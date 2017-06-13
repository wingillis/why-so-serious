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
end % function
