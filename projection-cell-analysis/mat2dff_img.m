function mat2dff_img(matname, outfile)
  [basename, ~, ~] = fileparts(matname);

  mf = matfile(matname);
  siz = mf.sizY;
  meanframe = zeros(siz(1), siz(2), 'double');
  maxframe = zeros(size(meanframe), 'double');
  % read in many frames ()
  fivemin = 30 * 60 * 5;
  chunks = floor(siz(3)/fivemin);
  for i=1:chunks
    y = mf.Y(:, :, (i-1)*fivemin+1:i*fivemin);

    meanframe = meanframe + mean(y, 3) ./ chunks;
    maxframe = max(cat(3, maxframe,  max(y, [], 3)), [], 3);

  end

  img = (maxframe - meanframe) ./ meanframe;

  imwrite(img, fullfile(basename, [outfile '.png']), 'png');
end % function
