function part2_validation(fname)
  %% load the neuron/data here

  load(fname);

  fprintf('Will process %d neurons\n\n', size(neuron.C, 2));

  %% delete, trim, split neurons
  % neuron.viewNeurons([], neuron.C_raw);
  neuron.displayNeurons([], neuron.C_raw);
  % assumes the file you gave it has _unprocessed in its name
  fname = [strrep(fname, '_unprocessed.mat', '') '_processed.mat'];
  save(fname, 'neuron', 'd1', 'd2', 'numFrame', 'options', 'Fs', '-v7.3')
end
