function verify_downsample_size(f1, f2)
  mf1 = matfile(f1);
  mf2 = matfile(f2);
  s1 = size(mf1, 'Y');
  s2 = size(mf2, 'Y');
  assert(s1(3)==s2(3), 'Frame ranges are not the same length!');
  disp('Frame ranges are the same length');
end % function
