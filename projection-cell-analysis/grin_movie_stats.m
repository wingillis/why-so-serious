function grin_movie_stats(matname, outfile)
  % produces 3 images based on the maximum projection,
  % the mean projection,
  % and the max - mean / mean (almost dff)
  [basename, ~, ~] = fileparts(matname);

  mf = matfile(matname);
  siz = mf.sizY;
  meanframe = zeros(siz(1), siz(2), 'double');
  maxframe = zeros(size(meanframe), 'double');
  % read in chunks of frames
  fivemin = 30 * 60 * 5;
  chunks = floor(siz(3)/fivemin);
  for i=1:chunks
    fprintf('Running on chunk %d of %d\n', i, chunks);
    y = mf.Y(:, :, (i-1)*fivemin+1:i*fivemin);

    meanframe = meanframe + mean(y, 3) ./ chunks;
    maxframe = max(cat(3, maxframe,  max(y, [], 3)), [], 3);

  end

  img = (double(maxframe) - meanframe) ./ meanframe;
  % returns the percentile range of values
  ptile = @(x) [prctile(x(:), 0.5) prctile(x(:), 99.5)];

  imwrite(mat2gray(img, ptile(img)), fullfile(basename, [outfile '-dff.png']), 'png');
  imwrite(mat2gray(double(maxframe), ptile(double(maxframe))), fullfile(basename, [outfile '-max.png']), 'png');
  imwrite(mat2gray(meanframe, ptile(meanframe)), fullfile(basename, [outfile '-mean.png']), 'png');
end % function
