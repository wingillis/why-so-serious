function cnmfe2contouravi(pth, outname)
  [basename, ~ , ~] = fileparts(pth);
  load(pth);
  vid = VideoWriter(fullfile(basename, [outname '.avi']));
  open(vid);
  contours = neuron.get_contours();
  neuron_mask = neuron.A;
  calciums = neuron.C_raw;
  % these will be the frames
  for i=1:size(calciums, 2)
    frame = zeros(d1, d2);
    for j=1:size(neuron_mask, 2)
      frame = frame + reshape(neuron_mask(:,j) .* calciums(j, i), d1, d2);
    end
    imagesc(frame, [0, 80]);
    hold on;
    for k=1:length(contours)
      plot(contours{k}(1,:), contours{k}(2, :), 'g', 'LineWidth', 1.5);
    end
    hold off;
    writeVideo(vid, getframe(gcf));
  end

end % function
