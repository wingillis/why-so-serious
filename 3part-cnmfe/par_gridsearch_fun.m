function [neuron_count]=par_gridsearch_fun(merge_thr, savedir, fname)
  % working directory the newly made dir from master func
  cd(savedir);
  % fname should be symbolically linked into this folder now
  load(fname);
  disp(pwd());
  disp(fname);
  [~, file_nm, ~] = fileparts(fname);
  rawfile = strrep(file_nm, '_processed', '');

  % cnmfe_quick_merge vars
  display_merge = false;
  view_neurons = false;
  cnmfe_quick_merge;

  disp('Merge done');

  neuron.Coor = neuron.get_contours(0.8); % energy within the contour is 80% of the total
  [Cn, pnr] = calc_corr_image([rawfile '.mat'], options);
  figure();
  Cn = imresize(Cn, [d1, d2]);
  plot_contours(neuron.A, Cn, 0.8, 0, [], neuron.Coor, 2);
  colormap winter;
  title('contours of estimated neurons');
  saveas(gcf, 'contours.png', 'png')
  neuron.Cn = Cn;

  param_savefile = [rawfile '_results.mat'];
  save(param_savefile, 'neuron', 'd1', 'd2', 'numFrame', 'options', 'Fs', '-v7.3');

  disp('File is now saved');

  neuron_count = size(neuron.C, 1);
end % function
