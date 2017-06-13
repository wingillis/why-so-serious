function part2_validation(fname)
  %% load the neuron/data here

  load(fname);

  %% delete, trim, split neurons
  neuron.viewNeurons([], neuron.C_raw);
  % assumes the file you gave it has _unprocessed in its name
  save([strrep(fname, '_unprocessed.mat', '') '_processed.mat'], '-v7.3');

end
