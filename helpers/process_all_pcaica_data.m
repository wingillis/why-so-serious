function process_all_pcaica_data()
  % traverse all directories to look for folder with saved data
  
  % what are the dirs?
  top_dirs = dir('*');
  is_dir = [top_dirs.isdir];
  top_dir_cell = struct2cell(top_dirs);
  notdot = and(~cellfun(@(x) strcmp('.', x), top_dir_cell(1,:)), ~cellfun(@(x) strcmp('..', x), top_dir_cell(1,:)));
  top_dirs = top_dirs(notdot & is_dir);
  for i=1:length(top_dirs)
    % this is the animal ID + experiment folder
    folder = top_dirs(i).name;
    disp(['going through ' folder ' folder']);
    ica_files = dir(fullfile(folder, 'processedMovie-ICs*-Objects'));
    for j=1:length(ica_files)
      disp(['Creating file for ' ica_files(j).name]);
      % now concat mixing, unmixing, and trace data
      object_path = fullfile(folder, ica_files(j).name);
      traces = load_object_tree(object_path, 'trace');
      mixing = load_object_tree(object_path, 'mixing');
      unmixing = load_object_tree(object_path, 'unmixing');
      % save it in the proper groups folder
      newfolder = fullfile('/groups/datta/win/inscopix', folder);
      if exist(newfolder, 'dir') ~= 7
        disp('Directory does not exist, making it...');
        mkdir(newfolder);
      end

      save(fullfile(newfolder, strrep(ica_files(j).name, '-Objects', '.mat')), 'traces', 'mixing', 'unmixing', '-v7.3');
    end
  end

end % function
