function [cells]=load_cells(type)
  % load extracted traces into matlab
  % TODO: add support for path specification
  % load cells
  if strcmp(type, 'inscopix')
    objects = length(dir('Obj*'));
    cells = cell(objects, 1);
    for i=1:objects
      % this is for when inscopix saves a shitload of object files for extracted traces
       tmp = load(sprintf('Obj_%d/Obj_2 - IC trace %d.mat', i, i), 'Object');
       cells{i} = tmp.Object.Data;
    end
    % make it into a matrix
    cells = cell2mat(cells);
  end

  if strcmp(type, 'csv')

  end

  if strcmp(type, 'cnmfe')
    files = dir('*_results.mat');
    if length(files) > 1
      disp('multiple results files found, loading the first one:')
      fprintf('\t%s\n', files(1).name);
    end
    f = files(1).name;
    cells = load(f);
  end
end
