function [g, extr] = load_grin_initialization()
  % load cnmfe neurons
  f = dir('*_results.mat');
  disp(['Loading ' f(1).name]);
  gg = load(f(1).name);
  neurons = gg.neuron;
  f = dir('kinect_object.mat');
  disp(['Loading ' f(1).name]);
  kk = load(f(1).name);
  extr = kk.extract_object;
  g = grin(neurons.C, neurons.S);
  g.load_kinect(extr);
  % need the nidaq.dat file in this dir
  g.load_inscopix_timestamps();
  g.align_everything();
  % calculate firing rate for a 300ms window
  g.calc_firing_rate(9);
end % function
