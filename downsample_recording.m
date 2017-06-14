function [fpath]=downsample_recording(mfpath, scale)
  ds = 1/scale;
  [pth, fnm, ext] = fileparts(mfpath);
  mf = matfile(mfpath);
  oldsizY = mf.sizY;
  oldY = mf.Y(:,:,1);
  sizes = size(imresize(oldY, ds));
  Y = zeros(sizes(1), sizes(2), 2, 'uint16');
  sizY = [sizes oldsizY(3)];
  fpath = fullfile(pth, [fnm '-downsample' num2str(scale) 'x' ext]);
  save(fpath, 'Y', 'sizY', '-v7.3');
  % construct the variables for the matfile
  newmf = matfile(fpath, 'Writable', true);
  newmf.Y(:,:, sizY(3)) = Y;
  parfor i=1:oldsizY(3)
    if mod(i, 1000) == 0
      fprintf('%d frames finished\n', i);
    end
    tmp = mf.Y(:,:,i);
    newY = imresize(tmp, ds);
    newmf.Y(:,:,i) = newY;
  end
  disp('finished downsampling')
end
