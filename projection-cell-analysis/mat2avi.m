function mat2avi(fpath, outputname)
  %% transform a memmapped recording .mat file into a movie to watch
  [basename, ~, ~] = fileparts(fpath);
  % load(fpath);
  mf = matfile(fpath);
  siz = mf.sizY;
  % make 5 min movies
  % fivemin = 30*5*60;
  thirtys = 30*30;
  minmax = double(mov_minmax(mf));
  w = VideoWriter(fullfile(basename, sprintf('%s.avi', outputname)));
  open(w);
  segments = floor(siz(3)/thirtys);
  for i=1:segments
    y = double(mf.Y(:,:, (i-1)*thirtys + 1:i*thirtys));
    y = mat2gray(y, minmax);
    y = permute(y, [1 2 4 3]);
    writeVideo(w, y);
    fprintf('Video segment %d of %d done\n', i, segments);
  end
  close(w);
end % function
