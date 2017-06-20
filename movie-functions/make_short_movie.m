function outfile=make_short_movie(filepath, nframes)
  if nargin < 2
    nframes = 6000;
  end
  mf = matfile(filepath);
  [fpath, fname, ~] = fileparts(filepath);
  outfile = matfile(fullfile(fpath, [fname '-short.mat']), 'Writable', true);
  sizY = mf.sizY;
  sizY(3) = nframes; % arbitrary # of frames for a smaller version
  outfile.sizY = sizY;
  outfile.Y = zeros(sizY(1), sizY(2), 2, 'uint16');
  for i=1:nframes
    tmp = mf.Y(:,:,i);
    outfile.Y(:,:,i) = tmp;
    if mod(i, 100) == 0
      fprintf('Frame %d\n', i);
    end
  end
end % function
