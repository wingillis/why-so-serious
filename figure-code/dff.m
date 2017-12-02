function [img]=dff(mf, numframes)
  fps = 30;
  fivemin = fps * 60 * 5;
  [x, y, z] = size(mf, 'Y');
  if nargin == 2 && numframes < z
    z = numframes;
  end

  meanframe = zeros(x, y, 'double');
  maxframe = zeros(size(meanframe), 'double');

  chunks = ceil(z/fivemin);
  for i=1:chunks
    endindex = i * fivemin;
    if i * fivemin > z
      endindex = z;
    end
    chunk = mf.Y(:, :, (i - 1) * fivemin + 1:endindex);
    meanframe = meanframe + mean(chunk, 3) ./ z;
    maxframe = max(cat(3, maxframe, max(chunk, [], 3)), [], 3);
  end

  img = (double(maxframe) - meanframe) ./ meanframe;

  ptile = @(x) [prctile(x(:), 5) prctile(x(:), 95)];

  img = mat2gray(img, ptile(img));

end % function
