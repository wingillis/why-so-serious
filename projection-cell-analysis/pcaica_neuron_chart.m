function pcaica_neuron_chart(obj, pth)
  delete(fullfile(pth, '*.png'));
  fig = figure();
  neurons = obj.neurons;
  unmixing = obj.unmixing;
  for i=1:size(neurons, 1)
    subplot(2,2,1);
    imagesc(squeeze(unmixing(i, :, :)));
    subplot(2, 2, 3:4);
    plot(neurons(i,:));
    saveas(fig, fullfile(pth, sprintf('neuron_%d.png', i)), 'png');
  end % function
end % function
