function [dff, masks, colors] = fov_rainbow_roi(movie_fname, cnmfe_fname)
  % input downsampled image and cnmfe-extracted roi file
  movief = matfile(movie_fname);
  cnmfef = load(cnmfe_fname);

  fps = 30;
  fivemin = fps * 60 * 5;
  numframes = 2000;

  [x, y, z] = size(movief, 'Y');
  z = numframes;
  masks = cnmfef.neuron.A;

  meanframe = zeros(x, y, 'double');
  maxframe = zeros(size(meanframe), 'double');

  chunks = ceil(z/fivemin);
  for i=1:chunks
    endindex = i * fivemin;
    if i * fivemin > z
      endindex = z;
    end
    chunk = movief.Y(:, :, (i - 1) * fivemin + 1:endindex);
    meanframe = meanframe + mean(chunk, 3) ./ z;
    maxframe = max(cat(3, maxframe, max(chunk, [], 3)), [], 3);
  end

  img = (double(maxframe) - meanframe) ./ meanframe;

  % returns the percentile range of values
  ptile = @(x) [prctile(x(:), 0.5) prctile(x(:), 99.5)];

  img = mat2gray(img, ptile(img));

  figure();
  imshow(repmat(img, 1, 1, 3));
  hold on;
  colors = jet(size(masks, 2));
  for i=1:size(masks, 2)
    h = imshow(permute(repmat(colors(i, :), x, 1, y), [1 3 2]));
    set(h, 'AlphaData', reshape(masks(:,i), x, y));
  end
end % function
