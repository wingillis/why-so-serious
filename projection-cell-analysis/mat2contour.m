function mat2contour(matname, cnmfename, outfile)
  mf = matfile(matname);
  [basename, ~, ~] = fileparts(matname);
  siz = mf.sizY;
  fivemin = 30 * 60 * 5;

  cnmfe = load(cnmfename);
  contours = cnmfe.neuron.get_contours();

  mmin = 0;
  mmax = 0;

  vid = VideoWriter(fullfile(basename, [outfile '.avi']));
  open(vid);

  for i=1:ceil(siz(3)/fivemin)
    % read in 5 minutes of data - should be around 2GB
    disp(['Running on part ' i ' of ' ceil(siz(3)/fivemin)]);
    y = single(mf.Y(:, :, (i-1)*fivemin+1:i*fivemin));
    if mmin == 0
      mmin = prctile(y(:), 10);
      mmax = max(y(:));
    end

    ycolor = permute(y, [1 2 4 3]);
    ycolor = ycolor(:, :, [1 1 1], :);
    for j=1:size(y, 3)
      for k=1:length(contours)
        points = 2*size(contours{k}, 2);
        a_contour = zeros(1,points);
        a_contour(1:2:points) = contours{k}(1,:);
        a_contour(2:2:points) = contours{k}(2,:);
        gry = mat2gray(squeeze(y(:,:,j)), single([mmin mmax]));
        ycolor(:,:,:,j) = insertShape(gry(:,:, [1 1 1]), 'Line', a_contour, 'LineWidth', 1, 'Color', 'g');
      end
    end
    writeVideo(vid, ycolor);
  end

  close(vid);

end % function
