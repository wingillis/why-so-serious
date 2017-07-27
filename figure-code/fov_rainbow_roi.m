function [img, masks, colors] = fov_rainbow_roi(movie_fname, cnmfe_fname, savepath, iscontour)
  % input downsampled image and cnmfe-extracted roi file
  movief = matfile(movie_fname);
  cnmfef = load(cnmfe_fname);

  [x, y, z] = size(movief, 'Y');

  masks = cnmfef.neuron.A;
  colors = jet(size(masks, 2));

  % don't do dff it's too grainy
  % img = dff(movief, 2000);
  img = mean(movief.Y(:,:,1:9000), 3);
  ptile = @(x) [prctile(x(:), 0.5) prctile(x(:), 99.5)];
  img = mat2gray(img, ptile(img));

  if ~isfield(cnmfef.neuron, 'Coor')
    cnmfef.neuron.Coor = cnmfef.neuron.get_contours(0.8);
  end

  f = figure();
  imshow(repmat(img, 1, 1, 3));
  hold on;

  if ~iscontour
    for i=1:size(masks, 2)
      h = imshow(permute(repmat(colors(i, :), x, 1, y), [1 3 2]));
      set(h, 'AlphaData', reshape(masks(:,i), x, y));
    end
  else
    for i=1:length(cnmfef.neuron.Coor)
      plot(cnmfef.neuron.Coor{i}(1,:), cnmfef.neuron.Coor{i}(2,:), 'color', colors(i,:), 'LineWidth', 1);
    end
  end

  if nargin >= 3
    fname = 'fov-rainbow-roi';
    if iscontour
      fname = [fname '-contour'];
    end
    saveas(f, fullfile(savepath, fname), 'epsc');
    savefig(f, fullfile(savepath, fname));
    print(f, fullfile(savepath, fname), '-dpng', '-r300');
    print(f, fullfile(savepath, fname), '-dtiff', '-r300');

  end

end % function
