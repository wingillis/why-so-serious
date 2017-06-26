function [full_outfile]=par_mat2contour(matname, ind, contours, outfile)
  mf = matfile(matname);
  [basename, ~, ~] = fileparts(matname);
  siz = mf.sizY;
  fivemin = 30 * 60 * 5;
  full_outfile = fullfile(basename, [outfile '.avi']);
  vid = VideoWriter(full_outfile);
  fprintf('Running on part %d of %d\n', i, ceil(siz(3)/fivemin));
  mmin = 0;
  mmax = 0;

  if ind(2) > siz(3)
    ind(2) = siz(3);
  end
  y = single(mf.Y(:, :, ind(1):ind(2)));
  if mmin == 0
    mmin = prctile(y(:), 10);
    mmax = max(y(:));
  end

  ycolor = permute(y, [1 2 4 3]);
  ycolor = ycolor(:, :, [1 1 1], :);
  for j=1:size(y, 3)
    gry = mat2gray(squeeze(y(:,:,j)), double([mmin mmax]));
    gry = gry(:, :, [1 1 1]);
    for k=1:length(contours)
      points = 2*size(contours{k}, 2);
      a_contour = zeros(1,points);
      a_contour(1:2:points) = contours{k}(1,:);
      a_contour(2:2:points) = contours{k}(2,:);
      gry = insertShape(gry, 'Line', a_contour, 'LineWidth', 1, 'Color', 'g');
    end
    ycolor(:,:,:,j) = gry;
  end
  writeVideo(vid, ycolor);
end
