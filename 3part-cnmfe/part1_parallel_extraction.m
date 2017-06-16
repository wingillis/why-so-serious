function [processed_path]=part1_parallel_extraction(nam, options)
  %% This function controls the deployment of all the parallel extractions that
  % will be going on - hopefully reducing the factor of time spent extracting
  % by a factor of 50
  cnmfe_files = strsplit(genpath('/home/wg41/code/CNMF_E'), ':');
  grin_files = strsplit(genpath('/home/wg41/code/grin-analysis'), ':');
  additional_files = cat(2, cnmfe_files(1:end-1), grin_files(1:end-1));

  % instantiate a cluster
  c = instantiate_cluster();

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
  if isempty(whos(data, 'sizY'))
    Ysiz = data.Ysiz;
  else
    Ysiz = data.sizY;
  end
  d1 = Ysiz(1);   %height
  d2 = Ysiz(2);   %width
  if options.num_frames == -1
    numFrame = Ysiz(3);    %total number of frames
  else
    warning('Number of frames specified is probably not the same as the entire length of the movie');
    numFrame = options.num_frames;
  end

  %% create indices for splitting field-of-view into spatially overlapping patches (for parallel processing)
  patches = construct_patches([d1 d2], options.patch_sz, ...
                              options.overlap, options.min_patch);

  %% create Source2D class object for storing results and parameters
  Fs = 30;     % frame rate
  neuron_full = make_cnmfe_class(d1, d2, Fs, options);

  % TODO: deal with this at a later date: right now not using it at all
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


  %% display correlation image
  if options.save_corr_img
    calc_corr_image(nam, options);
  end

  %% Load and run CNMF_E on full dataset in patches

  sframe=options.start_frame;						% user input: first frame to read (optional, default:1)

  RESULTS(length(patches)) = struct();
  jobs = cell(length(patches), 1);

  %%  PARALLEL CNMF_E

  disp('Going through the patches');
  for i = 1:length(patches)

    % shape a new neuron to handle each patch and send it to mpi node
    fprintf('Sending patch %d\n', i);

    % Load data from individual (i-th) patch and store in temporary Sources2D() object ('neuron_patch')
    neuron_patch = neuron_full.copy();

    % get movie data relevant to this chunk
    if and(options.ds_space==1, options.ds_time==1)
      % temporal info is the same, but spatial info is now in chunks
      Y = data.Y(patches{i}(1):patches{i}(2), ...
                        patches{i}(3):patches{i}(4), ...
                        (sframe-1)+(1:numFrame));
      Y = double(Y);
      [d1p, d2p, ~] = size(Y);
    else
      Yraw = data.Y(patches{i}(1):patches{i}(2), ...
                    patches{i}(3):patches{i}(4), ...
                    (sframe-1)+(1:numFrame));
      [neuron_patch_ds, Y] = neuron_patch.downSample(double(Yraw));
      [d1p, d2p, ~] = size(Y);
      neuron_patch = neuron_patch_ds.copy();
      clear neuron_patch_ds;
    end

    neuron_patch.updateParams('d1', d1p, 'd2', d2p);
    Y = neuron_patch.reshape(Y, 1);  % convert a 3D video into a 2D matrix

    jobs{i} = createJob(c, 'AdditionalPaths', additional_files);
    createTask(jobs{i}, @extract_neurons, 1, {neuron_patch, Y, options});
    submit(jobs{i});

  end

  % after all jobs are sent, wait for the data to come back, and aggregate
  for i=1:length(jobs)
    wait(jobs{i});
    fprintf('Finished processing patch # %d of %d.\n', i, length(patches));
  end

  % ok, jobs are done, let's fetch the results
  for i=1:length(jobs)
    r = fetchOutputs(jobs{i});
    r = r{1};
    RESULTS(i).A = r.A;
    RESULTS(i).C = r.C;
    RESULTS(i).C_raw = r.C_raw;
    RESULTS(i).S = r.S;
    RESULTS(i).P = r.P;
  end


  neuron_full.P.kernel_pars = [];
  for i = 1:length(patches)
    if size(RESULTS(i).A,2)>0
      Atemp = zeros(neuron_full.options.d1,neuron_full.options.d2,size(RESULTS(i).A,2));

      for k = 1:size(RESULTS(i).A,2)
        Atemp(patches{i}(1):patches{i}(2), patches{i}(3):patches{i}(4), k) =  reshape(RESULTS(i).A(:, k), patches{i}(2)-patches{i}(1)+1, patches{i}(4)-patches{i}(3)+1);
      end

      neuron_full.A = [neuron_full.A, reshape(Atemp,d1*d2,k)];
      neuron_full.C = [neuron_full.C; RESULTS(i).C];
      neuron_full.C_raw = [neuron_full.C_raw; RESULTS(i).C_raw];
      neuron_full.S = [neuron_full.S; RESULTS(i).S];
      neuron_full.P.sn = [neuron_full.P.sn, RESULTS(i).P.sn];
      neuron_full.P.kernel_pars = [neuron_full.P.kernel_pars; RESULTS(i).P.kernel_pars];
    end
      clear Atemp;
  end

  neuron = neuron_full.copy();

  % save what we have done here
  processed_path = fullfile(dir_nm, [file_nm '_unprocessed.mat']);
  save(processed_path, 'neuron', 'd1', 'd2', 'numFrame', 'options', 'Fs', 'Ysiz', '-v7.3');

end % function
