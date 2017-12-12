function mat2tiff(fname)
  %% this function is mainly to use the downsampled recording files
  % that I've already made and pass them through the inscopix processing
  % pipeline
  tifname = [fname(1:end-3) 'tif'];
  mf = matfile(fname);
  frames = mf.sizY(1,3);
  imwrite(mf.Y(:,:,1), tifname);
  for i=2:frames
    if mod(i, 500) == 0
      fprintf('Wrote %d frames out of %d\n', i, frames);
    end
    imwrite(mf.Y(:,:,i), tifname, 'WriteMode', 'append');
  end

end % function
