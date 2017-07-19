function merging_gridsearch(fname, opt)
  % this function searches through a large list of parameters used for merging
  % cells captured with cnmfe for the optimal merging parameters.
  % it creates a directory and stores the results of each merge in its own
  % subdirectory. The amount of neurons kept in each merge is captured here
  % and graphed in a 3d figure for threshold determination

  assert(contains(fname, '_processed'), 'Must supply processed data');

  % load the unmerged data
  load(fname);

  if nargin < 2
    opt = options;
  end

  % file handling stuff goes here
  [~, file_nm, ~] = fileparts(fname);
  rawfile = strrep(file_nm, '_processed', '');
  curdir = pwd();
  savedir = 'gridsearch';
  if ~exist(savedir, 'dir')
    mkdir(savedir);
  end

  % linking some files for batch jobs
  cnmfe_files = strsplit(genpath(opt.cluster.cnmfe_code), ':');
  grin_files = strsplit(genpath(opt.cluster.grin_code), ':');
  additional_files = cat(2, cnmfe_files(1:end-1), grin_files(1:end-1));
  c = instantiate_cluster(opt);

  % construct the parameters to search: correlation thresholds
  % 0.8 cutoff is slightly arbitrary, but in the past I havent
  % seen much change with numbers higher than this
  npoints = 10;
  spatial = linspace(0.8, 0, npoints);
  temporal = linspace(0.8, 0, npoints);
  spike_thresh = 0.1;

  [S, T] = ndgrid(spatial, temporal);

  job = createJob(c, 'AdditionalPaths', additional_files);

  % loop through each parameter combo
  for i=1:numel(S)
    fprintf('Merging param set %d\n', i);
    merge_thr = [S(i) T(i) spike_thresh];
    fprintf('Spatial: %0.3f\tTemporal: %0.3f\n', S(i), T(i));
    param_savedir = fullfile(savedir, sprintf('spatial-%0.4f-temporal-%0.4f', S(i), T(i)));
    if ~(exist(param_savedir, 'dir') == 7)
      mkdir(param_savedir);
    end
    % link the original (_processed) file to the folder
    output = system(sprintf('ln -s %s %s/', fullfile(curdir, fname), fullfile(curdir, param_savedir)));
    output2 = system(sprintf('ln -s %s %s/', fullfile(curdir, [rawfile '.mat']), fullfile(curdir, param_savedir)));
    if output ~= 0 || output2 ~= 0
      disp('File linking did not work');
    end

    % send data thru a batch job
    createTask(job, @par_gridsearch_fun, 1, {merge_thr, param_savedir, fname});

  end

  wait(job);

  neuron_count = fetchOutputs(job);
  save('neuron_count.mat', 'neuron_count');

  delete(job);

end % function
