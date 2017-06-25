function mov2contour(movfile, cnmfefile, outfile)
  r = VideoReader(movfile);
  [basename, ~, ~] = fileparts(movfile);
  f = load(cnmfefile);
  contours = f.neuron.get_contours();
  clear f
  w = VideoWriter(fullfile(basename, [outfile '.avi']));
  open(w);
  while hasFrame(r)
    frame = readFrame(r);
    imshow(frame);
    hold on;
    for k=1:length(contours)
      plot(contours{k}(1,:), contours{k}(2, :), 'g', 'LineWidth', 0.8);
    end
    hold off;
    writeVideo(w, getframe(gca));
  end
end % function
