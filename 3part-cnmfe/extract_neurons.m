function [results]=extract_neurons(neuron, Y, options)
  %% uses cnmfe to extract neurons from grin lens imaging data
  % neuron = Sources2D object
  % options = struct produced with `construct_default_params`

  %% Initialization of A, C -- parameters
  % must initialize individual update-parameters within parfor loop to avoid
  % transparency violations

  debug_on = false;   % visualize the initialization procedue.
  save_avi = false;   % save the initialization procedure as an avi movie.
  patch_par = [1,1]*1; %1;  % divide the optical field into m X n patches and do initialization patch by patch. It can be used when the data is too large
  K = []; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

  % when using 2x downsampled data, cells are about 2-3 pixels large
  min_pixel = 3;      % minimum number of nonzero pixels for each neuron
  bd = 0;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
  neuron_patch.updateParams('min_pixel', min_pixel, 'bd', bd);

  % not found in CNMFESetParms script - don't know if it will work in
  % neuron_patch.updateParams
  neuron_patch.options.nk = 1;  % number of knots for detrending

  fprintf('Initialization of endoscope\n')

  % greedy method for initialization
  neuron_patch.initComponents_endoscope(Y, options.max_neurons, ...
                                        patch_par, debug_on, save_avi);

  %% iteratively update A, C and B
  % must initialize individual update-parameters within parfor loop to avoid
  % transparency violations

  % parameters, estimate the background
  spatial_ds_factor = 1; % spatial downsampling factor. it's for faster estimation
  thresh = 10; % threshold for detecting frames with large cellular activity. (mean of neighbors' activity  + thresh*sn)

  bg_neuron_ratio = 1;  % spatial range / diameter of neurons

  % parameters, estimate the spatial components
  update_spatial_method = 'hals';  % the method for updating spatial components {'hals', 'hals_thresh', 'nnls', 'lars'}
  Nspatial = 5;       % this variable has different meanings:
  %1) udpate_spatial_method=='hals' or 'hals_thresh',
  %then Nspatial is the maximum iteration
  %2) update_spatial_method== 'nnls', it is the maximum
  %number of neurons overlapping at one pixel

  % parameters for running iterations
  nC = size(neuron_patch.C, 1);    % number of neurons


  %% Continue with full CNMF_E if given patch has any neurons

  if nC>0 % check for presence of neurons in patch
    % TODO: understand the sorting algorithm
    % sort neurons
    neuron_patch.orderROIs();

    maxIter = 2;  % maximum number of iterations
    miter = 1;

    fprintf('Iterating over neuron merging\n');
    while miter <= maxIter
      %% merge neurons, order neurons and delete some low quality neurons
      if nC <= 1 % check if there's at most 1 neuron
         break
      end

      if miter == 1
        merge_thr = [.1 .8 .1];     % thresholds for merging neurons
        % corresponding to {sptial overlaps, temporal correlation of C,
        %temporal correlation of S}
      else
        merge_thr = [options.spatial_corr options.temporal_corr options.spiketime_corr];
      end

      % merge neurons
      neuron_patch.quickMerge(merge_thr); % run neuron merges
      %sort neurons
      neuron_patch.orderROIs();

      fprintf('Neurons merged and sorted\n');

      %% udpate background
      tic;

      Ybg = Y - neuron_patch.A * neuron_patch.C;
      rr = ceil(neuron_patch.options.gSiz * bg_neuron_ratio);
      active_px = []; %(sum(IND, 2)>0); %If some missing neurons are not covered by active_px, use [] to replace IND
      [Ybg, ~] = neuron_patch.localBG(Ybg, spatial_ds_factor, rr, active_px, neuron_patch.P.sn, thresh); %estimate local background

       %subtract background from the raw data to obtain signal for
       %subsequent CNMF
       Ysignal = Y - Ybg;

       % estimate noise
      if ~isfield(neuron_patch.P, 'sn') || isempty(neuron_patch.P.sn)
        % estimate the noise for all pixels
        b0 = zeros(size(Ysignal,1), 1);
        sn = zeros(size(b0));
        for m = 1:size(neuron_patch.A,1)
          [b0(m), sn(m)] = estimate_baseline_noise(Ysignal(m,:));
        end
        Ysigma = bsxfun(@minus,Ysignal,b0);
      end

      fprintf('Time cost in estimating the background:    %.2f seconds\n', toc);
      %% update spatial & temporal components
      fprintf('Updating spatial and temporal components\n');
      tic;
      for m=1:2
        % temporal
        neuron_patch.updateTemporal_endoscope(Ysignal);
        % merge neurons
        [merged_ROI, ~] = neuron_patch.quickMerge(merge_thr); % run neuron merges
        %sort neurons
        [~,srt] = sort(max(neuron_patch.C,[],2).*max(neuron_patch.A,[],1)','descend');
        neuron_patch.orderROIs(srt);

        %spatial
        neuron_patch.updateSpatial_endoscope(Ysignal, Nspatial, update_spatial_method);
        % tricky part
        neuron_patch.trimSpatial(0.01, 2); % for each neuron, apply imopen first and then remove pixels that are not connected with the center
        if isempty(merged_ROI)
          break;
        end
      end
      fprintf('Time cost in updating spatial & temporal components:     %.2f seconds\n', toc);

      %% pick neurons from the residual (cell 4).
      if miter==1
        neuron_patch.options.seed_method = 'auto'; % methods for selecting seed pixels {'auto', 'manual'}
        [center_new, Cn_res, pnr_res] = neuron_patch.pickNeurons(Ysignal - neuron_patch.A * neuron_patch.C, patch_par); % method can be either 'auto' or 'manual'
      end

      %% stop the iteration
      temp = size(neuron_patch.C, 1);
      if or(nC==temp, miter==maxIter)
        break;
      else
        miter = miter+1;
        nC = temp;
      end
    end
  end

  fprintf('Found %d neurons\n', size(nC, 1));

  %% Store results from individual patch in master structure with every patch's output

  RESULTS(i).A = neuron_patch.A;
  RESULTS(i).C = neuron_patch.C;
  RESULTS(i).C_raw = neuron_patch.C_raw;
  RESULTS(i).S = neuron_patch.S;
  RESULTS(i).P = neuron_patch.P;

  fprintf('Finished processing patch # %d of %d.\n', i, length(patches));
end % function
