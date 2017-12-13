function motion_correct(fname)
  %% takes a movie with a lot of motion, and registers each frame to the
  % mean of the first 100 frames.
  mf = matfile(fname);
  fprintf('Loading in frames\n');
  mov = mf.Y(:,:,:);
  template = fft2(nanmean(mov(:,:,1:100), 3));
  out = matfile(['motion-corrected-' fname], 'writable', true);
  out.Y = zeros([mf.Ysiz(1,1) mf.Ysiz(1,2) 2], 'uint16');
  frames = mf.Ysiz(1,3);
  fprintf('Starting to motion correct...\n');
  for i=1:frames
    if mod(i, 500) == 0
      fprintf('Completed %d/%d frames\n', i, frames);
    end
    tmp = mov(:,:,i);
    [~, Greg] = dftregistration(template, fft2(tmp), 10);
    out.Y(:,:,i) = uint16(abs(ifft2(Greg)));
  end
  vinfo = who('-file', fname);
  if ismember('Ysiz', vinfo)
  	out.Ysiz = mf.Ysiz;
	end
	if ismember('sizY', vinfo)
		out.sizY = mf.sizY;
	end
	if ismember('nY', vinfo)
		out.nY = mf.nY;
	end

end % function
