function cnmfe_compute_background(recfile, neuronfile)
  mf = matfile(recfile);
  mf_bg = matfile(sprintf('%s_background.mat', recfile(1:end-4)), 'writable', true);
  Ysiz = mf.Ysiz;
  mf_bg.Yr = zeros(Ysiz(1)*Ysiz(2), 1);
  load(neuronfile)
  if exist('neuron_results', 'var')
    neuron = neuron_results;
  end
  % split into 1000 frame chunks
  chunks = floor(Ysiz(3)/1000);

  for i=1:chunks
    fprintf('On chunk %d of %d\n', i, chunks);
    index = (i-1)*1000+1:i*1000;
    Y = double(mf.Yr(:, index));
    Ybg = Y - neuron.A*neuron.C(:,index);
    [Ybg, Ybg_weights] = neuron.localBG(Ybg); % estimate local background
    mf_bg.Yr(:, index) = Ybg;
  end

  fprintf('Truncated recording by %d frames\n', Ysiz(3)-(chunks*1000));

end % function
