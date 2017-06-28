function mat2tiff(infile, framerange)
  [basename, fname, ~] = fileparts(infile);
  mf = matfile(infile);
  siz = mf.sizY;
  if nargin < 2
    framerange = [1 siz(3)];
  end
  newf = fullfile(basename, [fname '.tiff']);
  imwrite(mf.Y(:,:,framerange(1)), newf);
  for k = framerange(1)+1:framerange(2)
    imwrite(mf.Y(:,:,k), newf, 'writemode', 'append');
  end
end % function
