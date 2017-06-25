function mat2avi(fpath, outputname)
  [basename, ~, ~] = fileparts(fpath);
  mf = matfile(fpath);
  siz = mf.sizY;
  % make 5 min movies
  fivemin = 30*5*60;
  for i=1:floor(siz(3)/fivemin)
    w = VideoWriter(fullfile(basename, sprintf('%s-%d.avi', outputname, i)));
    open(w);
    for j=1:fivemin
      % TODO: make this scale less arbitrary
      frame = single(mf.Y(:,:,(i-1)*fivemin + j));
      frame = frame - 183;
      frame(frame < 0) = 0;
      frame = frame ./ 870;
      frame(frame > 1) = 1;
      writeVideo(w, frame);
    end
    fprintf('Video %d done\n', i);
    close(w);
  end
end % function
