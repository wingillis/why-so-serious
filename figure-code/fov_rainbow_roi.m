function [img, masks, colors] = fov_rainbow_roi(movie_fname, cnmfe_fname, savepath)
  % input downsampled image and cnmfe-extracted roi file
  movief = matfile(movie_fname);
  cnmfef = load(cnmfe_fname);

  [x, y, z] = size(movief, 'Y');

  masks = cnmfef.neuron.A;
  colors = jet(size(masks, 2));

  img = dff(movief, 2000);

  f = figure();
  imshow(repmat(img, 1, 1, 3));
  hold on;

  for i=1:size(masks, 2)
    h = imshow(permute(repmat(colors(i, :), x, 1, y), [1 3 2]));
    set(h, 'AlphaData', reshape(masks(:,i), x, y));
  end

  if nargin == 3
    saveas(f, fullfile(savepath, 'fov-rainbow-roi'), 'epsc');
    savefig(f, fullfile(savepath, 'fov-rainbow-roi'));
    print(f, fullfile(savepath, 'fov-rainbow-roi'), '-dpng', '-r300');

  end

end % function
