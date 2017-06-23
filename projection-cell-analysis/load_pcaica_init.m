function [g, extr]=load_pcaica_init()
  f = dir('processed*IC*.mat');
  disp(['Loading ' f(1).name]);
  gg = load(f(1).name);
  traces = cell2mat(gg.traces);
  f = dir('kinect_object.mat');
  disp(['Loading ' f(1).name]);
  kk = load(f(1).name);
  extr = kk.extract_object;
  g = grin(traces);
  unmixed = gg.unmixing;
  [d1, d2] = size(unmixed{1});
  um = zeros(length(unmixed), d1, d2);
  for i=1:length(unmixed)
    um(i, :, :) = unmixed{i};
  end
  g.set_unmixing(um);
  g.load_kinect(extr);
  % need the nidaq.dat file in this dir
  g.load_inscopix_timestamps();
  g.align_everything();
  % calculate firing rate for a 300ms window
  % g.calc_firing_rate(9);
end % function
