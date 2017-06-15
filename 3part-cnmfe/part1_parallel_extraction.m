function [processed_path]=part1_parallel_extraction(nam, options)
  %% This function controls the deployment of all the parallel extractions that
  % will be going on - hopefully reducing the factor of time spent extracting
  % by a factor of 50

  % load in the data, get the patches for each img subset

  if nargin < 2
    options = struct();
  end

  options = construct_default_params(options);
  %% end option construction

  %% select data and map it to RAM
  % following info is from: cnmfe_choose_data;
  [dir_nm, file_nm, ~] = fileparts(nam);
  data = matfile(nam);
  % the size variable name could vary - this naming scheme is from
  % the memmap_file.m script in cnmfe. Conditional should fix any errors
  if isempty(whos(mf, 'sizY'))
    Ysiz = data.Ysiz;
  else
    Ysiz = data.sizY;
  end
  d1 = Ysiz(1);   %height
  d2 = Ysiz(2);   %width
  numFrame = Ysiz(3);    %total number of frames

  %% create indices for splitting field-of-view into spatially overlapping patches (for parallel processing)
  patches = construct_patches([d1 d2], options.patch_sz, ...
                              options.overlap, options.min_patch);

  %% create Source2D class object for storing results and parameters
  Fs = 30;            % frame rate
  neuron_full = make_cnmfe_class(d1, d2, Fs, options);

  % with dendrites or not
  if options.dendrites
      % determine the search locations by dilating the current neuron shapes
      neuron_full.options.search_method = 'dilate';
      neuron_full.options.bSiz = 20;
  else
      % determine the search locations by selecting a round area
      neuron_full.options.search_method = 'ellipse';
      neuron_full.options.dist = 4;
  end

  %% options for running deconvolution
  neuron_full.options.deconv_options = struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
      'method', 'thresholded', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
      'optimize_pars', true, ...  % optimize AR coefficients
      'optimize_b', false, ... % optimize the baseline
      'optimize_smin', true);  % optimize the threshold


  %% load small portion of data for displaying correlation image
  if options.save_corr_img
    calc_corr_image(nam, options);
  end


  %% Load and run CNMF_E on full dataset in patches

  sframe=1;						% user input: first frame to read (optional, default:1)
  num2read = numFrame;             % user input: how many frames to read (optional, default: until the end)
  % time to test some stuff
  % num2read = 1000;
  if num2read ~= numFrame
    warning('Only reading a subset of frames: change this for full analysis');
  end

  RESULTS(length(patches)) = struct();

  %%  PARALLEL CNMF_E
  % If you change main loop to a for loop (sequential processing), you can save space by condensing many of the
  % steps below into scripts, as is done in the original demo_endoscope.m

  disp('Going through the patches');
  % for i = 1:length(patches)

  % shape a new neuron to handle each patch and send it to mpi node
  fprintf('On patch %d\n', i);

  % Load data from individual (i-th) patch and store in temporary Sources2D() object ('neuron_patch')

  neuron_patch = neuron_full.copy();

  % get movie data relevant to this chunk
  if and(options.ds_space==1, options.ds_time==1)
    % temporal info is the same, but spatial info is now in chunks
    % TODO: maybe turn this into single?
    Y = data.Y(patches{i}(1):patches{i}(2), ...
                      patches{i}(3):patches{i}(4), ...
                      (sframe-1)+(1:num2read));
    Y = double(Y);
    [d1p, d2p, T] = size(Y);
  else
    Yraw = data.Y(patches{i}(1):patches{i}(2), ...
                  patches{i}(3):patches{i}(4), ...
                  (sframe-1)+(1:num2read));
    [neuron_patch_ds, Y] = neuron_patch.downSample(double(Yraw));
    [d1p, d2p, T] = size(Y);
    neuron_patch = neuron_patch_ds.copy();
    clear neuron_patch_ds;
  end

  neuron_patch.updateParams('d1', d1p, 'd2', d2p);
  Y = neuron_patch.reshape(Y, 1);  % convert a 3D video into a 2D matrix

end % function
