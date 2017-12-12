function motion_correct(fname)
  %% takes a movie with a lot of motion, and registers each frame to the
  % mean of the first 100 frames.
  mf = matfile(fname);
  template = fft2(nanmean(mf.Y(:,:,1:100), 3));
  out = matfile(['motion-corrected-' fname], 'writable', true);
  out.Y = zeros(mf.Ysiz(1,1), mf.Ysiz(1,2), 2);
  frames = mf.Ysiz(1,3);
  fprintf('Starting to motion correct...\n');
  for i=1:frames
    if mod(i, 500) == 0
      fprintf('Completed %d/%d frames\r', i, frames);
    end
    tmp = mf.Y(:,:,i);
    [~, Greg] = dftregistration(template, fft2(tmp), 100);
    out.Y(:,:,i) = abs(ifft2(Greg));
  end

end % function
