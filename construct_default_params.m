function [options] = construct_default_options(options)

  if ~isfield(options, 'patch_sz')
    options.patch_sz = [64 64]; % rndm default for how large the patches are
  end

  if ~isfield(options, 'overlap')
    options.overlap = [20 20]; % # pixels between chunks for overlap
  end

  if ~isfield(options, 'min_patch')
    options.min_patch = [16 16]; % minimum patch size in either direction
  end

  if ~isfield(options, 'gauss_kernel')
    % width of the gaussian kernel, which can approximates the average neuron shape
    options.gauss_kernel = 5;
  end

  if ~isfield(options, 'neuron_dia')
    % maximum diameter of neurons in the image plane. larger values are preferred
    options.neuron_dia = 10;
  end

  if ~isfield(options, 'min_corr')
    options.min_corr = 0.8;
  end

  if ~isfield(options, 'ds_time')
    options.ds_time = 5;
  end

  if ~isfield(options, 'ds_space')
    options.ds_space = 1;
  end

  if ~isfield(options, 'min_pnr')
    options.min_pnr = 20;
  end

  if ~isfield(options, 'bd')
    options.bd = 0;
  end

  if ~isfield(options, 'dendrites')
    options.dendrites = false;
  end

  if ~isfield(options, 'max_neurons')
    options.max_neurons = []; % default searches for # neurons in sample
  end

  if ~isfield(options, 'spatial_corr')
    options.spatial_corr = 0.6;
  end

  if ~isfield(options, 'temporal_corr')
    options.temporal_corr = 0.5;
  end

  if ~isfield(options, 'spiketime_corr')
    options.spiketime_corr = 0.1;
  end

  if ~isfield(options, 'save_corr_img')
    options.save_corr_img = false;
  end

end % function
