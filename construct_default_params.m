function [options] = construct_default_params(options)

  if nargin < 1
    options = struct();
    options.cnmfe = struct();
  end

  if ~isfield(options.cnmfe, 'patch_sz')
    options.cnmfe.patch_sz = [64 64]; % rndm default for how large the patches are
  end

  if ~isfield(options.cnmfe, 'overlap')
    options.cnmfe.overlap = [20 20]; % # pixels between chunks for overlap
  end

  if ~isfield(options.cnmfe, 'min_patch')
    options.cnmfe.min_patch = [16 16]; % minimum patch size in either direction
  end

  if ~isfield(options.cnmfe, 'gauss_kernel')
    % width of the gaussian kernel, which can approximates the average neuron shape
    options.cnmfe.gauss_kernel = 5;
  end

  if ~isfield(options.cnmfe, 'neuron_dia')
    % maximum diameter of neurons in the image plane. larger values are preferred
    options.cnmfe.neuron_dia = 10;
  end

  if ~isfield(options.cnmfe, 'min_corr')
    options.cnmfe.min_corr = 0.8;
  end

  if ~isfield(options.cnmfe, 'ds_time')
    options.cnmfe.ds_time = 1;
  end

  if ~isfield(options.cnmfe, 'ds_space')
    options.cnmfe.ds_space = 1;
  end

  if ~isfield(options.cnmfe, 'min_pnr')
    options.cnmfe.min_pnr = 20;
  end

  if ~isfield(options.cnmfe, 'bd')
    options.cnmfe.bd = 0;
  end

  if ~isfield(options.cnmfe, 'dendrites')
    options.cnmfe.dendrites = false;
  end

  if ~isfield(options.cnmfe, 'max_neurons')
    options.cnmfe.max_neurons = []; % default searches for # neurons in sample
  end

  if ~isfield(options.cnmfe, 'spatial_corr')
    options.cnmfe.spatial_corr = 0.6;
  end

  if ~isfield(options.cnmfe, 'temporal_corr')
    options.cnmfe.temporal_corr = 0.5;
  end

  if ~isfield(options.cnmfe, 'spiketime_corr')
    options.cnmfe.spiketime_corr = 0.1;
  end

  if ~isfield(options.cnmfe, 'save_corr_img')
    options.cnmfe.save_corr_img = false;
  end

  if ~isfield(options.cnmfe, 'view_neurons')
    options.cnmfe.view_neurons = true;
  end

  if ~isfield(options.cnmfe, 'start_frame')
    options.cnmfe.start_frame = 1;
  end

  if ~isfield(options.cnmfe, 'num_frames')
    options.cnmfe.num_frames = -1;
  end

  % TODO: add default options for cluster profile

end % function
