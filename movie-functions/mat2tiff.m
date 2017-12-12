function mat2tiff(fname)
  %% this function is mainly to use the downsampled recording files
  % that I've already made and pass them through the inscopix processing
  % pipeline
  % it reads in the recording, then writes subsequent tif files with each frame
  prepend = 1;
  tifname = sprintf('%s-%03d.tif', fname(1:end-4), prepend);
  disp(sprintf('Output file name: %s', tifname));
  mf = matfile(fname);
  disp('Loading in the data...');
  data = mf.Y(:,:,:);
  frames = mf.sizY(1,3);
  disp('Loaded - writing new tif files...');
  imwrite(mf.Y(:,:,1), tifname);
  for i=2:frames
    try
      if mod(i, 500) == 0
        fprintf('Wrote %d frames out of %d\n', i, frames);
      end
      imwrite(data(:,:,i), tifname, 'WriteMode', 'append');
    catch
      disp('File too big - writing new file now');
      prepend = prepend + 1;
      tifname = sprintf('%s-%03d.tif', fname(1:end-4), prepend);
      imwrite(data(:,:,i), tifname);
    end

  end

end % function
