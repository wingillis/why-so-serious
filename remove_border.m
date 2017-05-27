function [borderless]=remove_border(fname, border)
  [pth, fnm, ext] = fileparts(fname);
  newfile = fullfile(pth, [fnm '-borderless' ext]);
  % TODO: check to make sure the dimensions of the processed file
  % match the border the function is passing
  if exist(newfile, 'file') == 2
    disp('Processed file already exists');
    borderless = matfile(newfile);
    return;
  end
  mf = matfile(fname);
  sizY = mf.sizY;
  d1 = sizY(1);
  d2 = sizY(2);
  numframes = sizY(3);
  Y = zeros(d1-2*border, d2-2*border, 2, 'uint16');
  save(newfile, 'Y', '-v7.3');
  mf2 = matfile(newfile, 'Writable', true);
  fprintf('Removing %dpx from %d frames\n', border, numframes);
  for i=1:numframes
    if mod(i, 1000) == 0
      fprintf('%d frames finished\n', i);
    end
    tmp = mf.Y(border+1:d1-border, border+1:d2-border, i);
    mf2.Y(:,:,i) = tmp;
  end
  sizY(1) = d1 - 2*border;
  sizY(2) = d2 - 2*border;
  mf2.sizY = sizY;
  fprintf('New size: %d x %d', sizY(1), sizY(2));
  borderless = mf2;
end
