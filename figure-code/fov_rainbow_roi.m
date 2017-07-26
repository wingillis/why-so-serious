function [img, masks, colors] = fov_rainbow_roi(movie_fname, cnmfe_fname)
  % input downsampled image and cnmfe-extracted roi file
  movief = matfile(movie_fname);
  cnmfef = load(cnmfe_fname);

  masks = cnmfef.neuron.A;
  colors = jet(size(masks, 2));

  img = dff(movief, 2000);

  figure();
  imshow(repmat(img, 1, 1, 3));
  hold on;

  for i=1:size(masks, 2)
    h = imshow(permute(repmat(colors(i, :), x, 1, y), [1 3 2]));
    set(h, 'AlphaData', reshape(masks(:,i), x, y));
  end
  
end % function
