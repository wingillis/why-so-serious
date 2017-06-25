function mat2tiff(infile)
  [basename, fname, ~] = fileparts(infile);
  mf = matfile(infile);
  siz = mf.sizY;
  newf = fullfile(basename, [fname '.tiff']);
  imwrite(mf.Y(:,:,1), newf);
  for k = 2:siz(3)
    imwrite(mf.Y(:,:,k), newf, 'writemode', 'append');
  end
end % function
