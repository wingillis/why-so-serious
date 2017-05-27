function [cells]=load_cells(type)
  % load extracted traces into matlab
  % TODO: add suppor for path specification
  if ~exist('cells', 'var')==1
    % load cells
    objects = length(dir('Obj*'));
    cells = {};
    if strcmp(type, 'inscopix')
      for i=1:objects
        % this is for when inscopix saves a shitload of object files for extracted traces
         tmp = load(sprintf('Obj_%d/Obj_2 - IC trace %d.mat', i, i), 'Object')
         cells{i} = tmp.Object.Data;
      end
      % make it into a matrix
      cells = cell2mat(cells);
    end

    if strcmp(type, 'csv')

    end

    if strcmp(type, 'cnmfe')

    end
  end
end
