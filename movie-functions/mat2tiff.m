function mat2tiff(fname)
  %% this function is mainly to use the downsampled recording files
  % that I've already made and pass them through the inscopix processing
  % pipeline
  tifname = [fname(1:end-3) 'tif'];
  disp(sprintf('Output file name: %s', tifname));
  mf = matfile(fname);
  disp('Loading in the data...');
  data = mf.Y(:,:,:);
  frames = mf.sizY(1,3);
  disp('Loaded - writing new tif files...');
  imwrite(mf.Y(:,:,1), tifname);
  for i=2:frames
    if mod(i, 500) == 0
      fprintf('Wrote %d frames out of %d\n', i, frames);
    end
    imwrite(data(:,:,i), tifname, 'WriteMode', 'append');
  end

end % function
