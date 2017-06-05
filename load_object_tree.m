function [data]=load_object_tree(pth, type)

  switch type
  case 'trace'
    tree = construct_object_tree(pth, 'Obj_2*trace*.mat');
  case 'mixing'
    tree = construct_object_tree(pth, 'Obj_3*mixing*.mat');
  case 'unmixing'
    tree = construct_object_tree(pth, 'Obj_1*unmixing*.mat');
  end
  data = cell(length(tree), 1);
  for i=1:length(tree)
    % load object.data and add it to the data cell
    tmp = load(tree{i});
    data{i} = tmp.Object.Data;
  end

end % function
