function master_merge_for_parameter(spatial, temporal, spike)
  if nargin == 2
    spike = 0.05;
  end

  curdir = pwd();

  % make a dir for this merge (assume it's in the inscopix dir)
  newfolder = sprintf('t-%0.3f-s-%0.3f-sp-%0.3f', temporal, spatial, spike);
  mkdir(newfolder);
  disp(['made dir ' newfolder]);

  % gather all the folders with kinect in the name
  dirs = dir('*kinect*');

  % loop thru each dir and link relevant files
  for i=1:length(dirs)
    foldername = dirs(i).name;
    disp(['running for ' foldername]);
    processed_files = dir(fullfile(foldername, '*_processed.mat'));
    mkdir(fullfile(curdir, newfolder, foldername));
    for j=1:length(processed_files)
      procfile = processed_files(j).name;
      rawfile = strrep(procfile, '_processed', '');
      disp(['on file ' procfile]);
      system(sprintf('ln -s %s %s', fullfile(curdir, foldername, procfile), fullfile(curdir, newfolder, foldername, procfile)));
      system(sprintf('ln -s %s %s', fullfile(curdir, foldername, rawfile), fullfile(curdir, newfolder, foldername, rawfile)));
      cd(fullfile(curdir, newfolder, foldername));
      nn = load(procfile);
      nn.options.cnmfe.spatial_corr = spatial;
      nn.options.cnmfe.temporal_corr = temporal;
      nn.options.cnmfe.spiketime_corr = spike;
      part3_recomputing(procfile, nn.options);
    end
    % to make sure nothing gets really screwed up, return to curdir
    cd(curdir);
    % just so many windows open up each time :O
    close('all');
  end

end % function
