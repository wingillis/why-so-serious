function merging_gridsearch(fname, opt)
  % this function searches through a large list of parameters used for merging
  % cells captured with cnmfe for the optimal merging parameters.
  % it creates a directory and stores the results of each merge in its own
  % subdirectory. The amount of neurons kept in each merge is captured here
  % and graphed in a 3d figure for threshold determination

  % load the unmerged data
  load(fname);

  if nargin < 2
    opt = options;
  end

  % file handling stuff goes here
  [~, file_nm, file_ext] = fileparts(fname);
  rawfile = strrep(file_nm, '_processed', '');
  curdir = pwd();
  savedir = 'gridsearch';
  if ~exist(savedir, 'dir')
    mkdir(savedir);
  end

  % cnmfe_quick_merge vars
  display_merge = false;
  view_neurons = false;

  neuron_original = neuron.copy();

  % construct the parameters to search: correlation thresholds
  % 0.8 cutoff is slightly arbitrary, but in the past I havent
  % seen much change with numbers higher than this
  npoints = 40;
  spatial = linspace(0.8, 0, npoints);
  temporal = linspace(0.8, 0, npoints);
  spike_thresh = 0.1;

  [S, T] = ndgrid(spatial, temporal);

  neuron_count = zeros(size(S));

  % loop through each parameter combo
  for i=1:numel(S)
    % TODO: parallelize this!
    merge_thr = [S(i) T(i) spike_thresh];
    neuron = neuron_original.copy();
    cnmfe_quick_merge;
    neuron_count(i) = size(neuron.C, 1);
    param_savedir = fullfile(savedir, sprintf('spatial-%0.4f-temporal-%0.4f', S(i), T(i)));
    mkdir(param_savedir);
    param_savefile = fullfile(param_savedir, [rawfile '_results.mat']);
    save(param_savefile, 'neuron', 'd1', 'd2', 'numFrame', 'options', 'Fs', '-v7.3');
    % link the original (_processed) file to the folder
    output = system(sprintf('ln -s %s %s/', fullfile(curdir, fname), fullfile(curdir, param_savedir)));
    if output ~= 0
      disp('File linking did not work');
    end

  end
end % function
