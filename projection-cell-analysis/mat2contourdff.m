function mat2contourdff(matmov, cnmfefile, outfile)
  [basename, ~, ~] = fileparts(matmov);
  mf = matfile(matmov);
  siz = mf.sizY;
  f = load(cnmfefile);
  contours = f.neuron.get_contours();
  clear f
  w = VideoWriter(fullfile(basename, [outfile '.avi']));
  open(w);
  for i=1:siz(3)
    frame = mf.Y(:,:,i);
    imagesc(frame, [220 870]);
    hold on;
    for k=1:length(contours)
      plot(contours{k}(1,:), contours{k}(2, :), 'g', 'LineWidth', 1.5);
    end
    hold off;
    writeVideo(vid, getframe(gcf));
  end
end % function
