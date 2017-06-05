function [tree]=construct_object_tree(pth, file_glob)
  objects = dir(fullfile(pth, 'Obj_1', 'Obj*'));
  isdir = [objects.isdir];
  objects = objects(isdir);
  tree = cell(length(objects), 1);
  for i=1:length(objects)
    f = fullfile(objects(i).folder, objects(i).name);
    files = dir(fullfile(f, file_glob));
    if length(files) ~= 1
      disp(fullfile(f, file_glob))
      disp(f)
      error('Too many files in this directory');
    end
    tree{i} = fullfile(files(1).folder, files(1).name);
  end

end %function
