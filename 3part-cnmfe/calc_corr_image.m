function [Cn, pnr]=calc_corr_image(nam, options)
  % balance number of frames to read against the image dimensions (d1 x d2) to
  % limit RAM footprint
  % get the filename
  sframe = 1;
  num2read = 1000;
  Fs = 30;

  data = matfile(nam);
  if isempty(whos(data, 'sizY'))
    ysiz = data.Ysiz;
  else
    ysiz = data.sizY;
  end
  d1 = ysiz(1);
  d2 = ysiz(2);
  numFrame = ysiz(3);

  neuron_full = make_cnmfe_class(d1, d2, Fs, options);

  if and(options.ds_space==1, options.ds_time==1)
      disp('Loading neuron subset')
      neuron_small = neuron_full;
      Y = double(data.Y(:, :, sframe+(1:num2read)-1));
      [d1s,d2s, T] = size(Y);
      fprintf('\nThe data has been loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
  else
      [Y, neuron_ds] = neuron_full.load_data(nam, sframe, num2read);
      [d1s,d2s, T] = size(Y);
      fprintf('\nThe data has been downsampled and loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
      neuron_small = neuron_ds.copy();
  end

  Y = neuron_small.reshape(Y,1);

  %% compute correlation image and peak-to-noise ratio for selected portion of data
  % this step is not necessary, but it can give you some hints on parameter selection, e.g., min_corr & min_pnr

  [Cn, pnr] = neuron_small.correlation_pnr(Y(:, round(linspace(1, T, min(T, 1000)))));
  % make a neuron w/small # frames and make the correlation images for determining thresholds

  % show correlation image
  figure('position', [10, 500, 1776, 400]);
  subplot(131);
  imagesc(Cn, [0, 1]); colorbar;
  axis equal off tight;
  title('correlation image');

  % show peak-to-noise ratio
  subplot(132);
  imagesc(pnr,[0,max(pnr(:))*0.98]); colorbar;
  axis equal off tight;
  title('peak-to-noise ratio');

  % show pointwise product of correlation image and peak-to-noise ratio
  subplot(133);
  imagesc(Cn.*pnr, [0,max(pnr(:))*0.98]); colorbar;
  axis equal off tight;
  title('Cn*PNR');

  [p, f, ext] = fileparts(nam);
  dir_neurons = [f '_neurons'];
  if ~exist(dir_neurons, 'dir')
    mkdir(dir_neurons);
  end
  if options.save_corr_img
    saveas(gcf, fullfile(p, dir_neurons, 'correlation.png'), 'png');
  end
end % function
