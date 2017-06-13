function part3_recomputing(fname)
  load(fname);
  %% merge neurons
  display_merge = true; % set to true if you want to inspect every candidate merge
  view_neurons = false; % set to true if you want to inspect all neurons after quick merge routine

  % have lower thresholds because it doesn't do a great job merging the same neuron
  % detected in different patches
  % thresholds for merging neurons corresponding to:
  % {sptial overlaps, temporal correlation of C, temporal correlation of S}
  merge_thr = [0.5, 0.5, 0.1];  % choose thresholds for merging neurons (this will primarily merge neurons redundantly found by multiple patch processes, likely in the patch-overlaps)
  cnmfe_quick_merge;            % run neuron merges

  %% display neurons
  [dir_nm, file_nm, file_type] = fileparts(fname);
  dir_neurons = fullfile(dir_nm, [file_nm '_neurons']);
  if exist(dir_neurons, 'dir') == 7
      temp = cd();
      cd(dir_neurons);
      delete neuron*.png;
      cd(temp);
  else
      mkdir(dir_neurons);
  end
  neuron.viewNeurons([], neuron.C_raw, dir_neurons);
  close(gcf);

  %% display contours of the neurons
  neuron.Coor = neuron.get_contours(0.8); % energy within the contour is 80% of the total

  % plot contours with IDs
  figure;
  Cn = imresize(Cn, [d1, d2]);
  plot_contours(neuron.A, Cn, 0.8, 0, [], neuron.Coor, 2);
  colormap winter;
  title('contours of estimated neurons');
  saveas(gcf, fullfile(dir_neurons, 'contours.png'), 'png')

  neuron.Cn = Cn;
  clear Cn;
  clear merge_thr;

  %% save results
  processed_path = fullfile(dir_nm, [file_nm '_results.mat']);
  save(processed_path, '-v7.3');
end % function
