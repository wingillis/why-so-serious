function cnmfe2avi(pth, outname)
  [basename, ~ , ~] = fileparts(pth);
  load(pth);
  vid = VideoWriter(fullfile(basename, [outname '.avi']));
  open(vid);
  neuron_mask = neuron.A;
  calciums = neuron.C_raw;
  % these will be the frames
  for i=1:size(calciums, 2)
    frame = zeros(d1, d2);
    for j=1:size(neuron_mask, 2)
      frame = frame + reshape(neuron_mask(:,j) .* calciums(j, i), d1, d2);
    end
    frame(frame < 0) = 0;
    frame = frame ./ 80;
    frame(frame > 1) = 1;
    writeVideo(vid, single(frame));
  end

end % function
