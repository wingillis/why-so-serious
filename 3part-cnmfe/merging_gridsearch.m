function merging_gridsearch(fname, opt)
  % this function searches through a large list of parameters used for merging
  % cells captured with cnmfe for the optimal merging parameters.
  % it creates a directory and stores the results of each merge in its own
  % subdirectory. The amount of neurons kept in each merge is captured here
  % and graphed in a 3d figure for threshold determination

  assert(contains(fname, '_processed'), 'Must supply processed data');

  % load the unmerged data
  load(fname, 'options');

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
  npoints = 20;
  maxthresh = 0.8;
  spatial = linspace(maxthresh, 0, npoints);
  temporal = linspace(maxthresh, 0, npoints);
  spike_thresh = 0.05;

  % TODO: add spike_thresh as a searchable parameter

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
  submit(job);

  disp('Waiting for job to finish');
  wait(job);

  neuron_count = fetchOutputs(job);
  save('neuron_count.mat', 'neuron_count');

  delete(job);

  nc = cell2mat(neuron_count);

  nc = reshape(nc, npoints, npoints);

  figure();
  [xx, yy] = meshgrid(1:npoints, 1:npoints);

  surf(xx, yy, nc);
  colormap bone;

  xticks(linspace(1, npoints, 10));
  xticklabels(linspace(maxthresh, 0, 10));
  yticks(linspace(1, npoints, 10));
  yticklabels(linspace(maxthresh, 0, 10));
  xlabel('spatial thresh');
  ylabel('termoral thresh');
  zlabel('neuron count');

  view(0, 90);
  print('grid1', '-dpng', '-r300');

  view(135, 60);
  print('grid2', '-dpng', '-r300');

  view(-45, 60);
  print('grid3', '-dpng', '-r300');

  savefig(gcf, 'grid');

end % function
