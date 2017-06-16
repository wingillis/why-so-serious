function batch_cnmfe(data_path, config_path)

  if nargin < 2
    % check a hierarchy of places for a config file: experiment dir, home dir,
    % then dir where 3part-cnmfe is installed
    % config file has to have cnmfe in its name
    fprintf('Automatically searching for a config file\n');
    [exp_dir, ~, ~] = fileparts(data_path);
    home_dir = getenv('HOME');
    [grin_dir, ~, ~] = fileparts(which('part1_parallel_extraction'));
    exp_config = dir(fullfile(exp_dir, '*cnmfe*.config'));
    home_config = dir(fullfile(home_dir, '*cnmfe*.config'));
    grin_config = dir(fullfile(grin_dir, '*cnmfe*.config'));
    if ~isempty(exp_config)
      epath = exp_config(1);
      epath = fullfile(epath.folder, epath.name);
      fprintf('Automatically found config in experiment dir: %s\n', epath);
      options = read_cnmfe_params(epath);
    elseif ~isempty(home_config)
      hpath = home_config(1);
      hpath = fullfile(hpath.folder, hpath.name);
      fprintf('Automatically found config in home dir: %s\n', hpath);
      options = read_cnmfe_params(hpath);
    elseif ~isempty(grin_config)
      gpath = grin_config(1);
      gpath = fullfile(gpath.folder, gpath.file);
      fprintf('Automatically found config in cnmfe code dir: %s\n', gpath);
      options = read_cnmfe_params(gpath);
    else
      warning('No config file found anywhere: will populate an options file with default parameters');
      options = struct();

  else
    options = read_cnmfe_params(config_path);
  end

  % to fill in any values not already added in the config file
  options = construct_default_params(options);

  processed_path = part1_parallel_extraction(data_path, options);
  fprintf('Unprocessed file saved: %s\n', processed_path)

end % function
