function mat2avi(fpath, outputname)
  % read in the whole movie and calculate some mins and maxes
  [basename, ~, ~] = fileparts(fpath);
  load(fpath);
  mf = matfile(fpath);
  siz = mf.sizY;
  % make 5 min movies
  fivemin = 30*5*60;
  maxpx = 0;
  minpx = 0;
  for i=1:floor(siz(3)/fivemin)
    w = VideoWriter(fullfile(basename, sprintf('%s-%d.avi', outputname, i)));
    open(w);
    y = single(mf.Y(:,:, (i-1)*fivemin + 1:i*fivemin));
    if maxpx == 0
      maxpx = max(y(:));
      minpx = min(y(:));
    end
    y = y - minpx;
    y(y < 0) = 0;
    y = y ./ maxpx;
    y(y > 1) = 1;
    y = permute(y, [1 2 4 3]);
    writeVideo(w, y);
    fprintf('Video %d done\n', i);
    close(w);
  end
end % function
