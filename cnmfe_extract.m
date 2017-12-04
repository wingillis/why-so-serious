function cnmfe_extract(fname, spatial_thresh, temporal_thresh, min_corr, min_pnr)
	%% extract neurons from an inscopix recording using the new version of CNMF_E
	if nargin < 2
		spatial_thresh = 0.7;
	end
	if nargin < 3
		temporal_thresh = 0.1;
	end
	if nargin < 4
		min_corr = 0.75;     % minimum local correlation for a seeding pixel
	end
	if nargin < 5
		min_pnr = 12;       % minimum peak-to-noise ratio for a seeding pixel
	end

	mf = matfile(fname, 'writable', true);
	mf.Ysiz = mf.sizY;

	%% choose multiple datasets or just one
	neuron = Sources2D();
	nams = neuron.select_multiple_files({fname});  %if nam is [], then select data interactively

	%% parameters
	% -------------------------    COMPUTATION    -------------------------  %
	pars_envs = struct('memory_size_to_use', 40, ...   % GB, memory space you allow to use in MATLAB
	    'memory_size_per_patch', 5, ...   % GB, space for loading data within one patch
	    'patch_dims', [64, 64],...  %GB, patch size
	    'batch_frames', 3000);           % number of frames per batch
	  % -------------------------      SPATIAL      -------------------------  %
	gSig = 4.5;  % pixel, gaussian width of a gaussian kernel for filtering the data. 0 means no filtering
	gSiz = 15; % pixel, neuron diameter
	ssub = 1;  % spatial downsampling factor
	with_dendrites = false;   % with dendrites or not
	if with_dendrites
	    % determine the search locations by dilating the current neuron shapes
	    updateA_search_method = 'dilate';  %#ok<UNRCH>
	    updateA_bSiz = 5;
	    updateA_dist = neuron.options.dist;
	else
	    % determine the search locations by selecting a round area
	    updateA_search_method = 'ellipse'; %#ok<UNRCH>
	    updateA_dist = 5;
	    updateA_bSiz = neuron.options.dist;
	end
	spatial_constraints = struct('connected', true, 'circular', false);  % you can include following constraints: 'circular'
	spatial_algorithm = 'hals';

	% -------------------------      TEMPORAL     -------------------------  %
	Fs = 30;             % frame rate
	tsub = 1;           % temporal downsampling factor
	deconv_options = struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
	    'method', 'foopsi', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
	    'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
	    'optimize_pars', true, ...  % optimize AR coefficients
	    'optimize_b', true, ...% optimize the baseline);
	    'max_tau', 100);    % maximum decay time (unit: frame);

	nk = 3;             % detrending the slow fluctuation. usually 1 is fine (no detrending)
	% when changed, try some integers smaller than total_frame/(Fs*30)
	detrend_method = 'spline';  % compute the local minimum as an estimation of trend.

	% -------------------------     BACKGROUND    -------------------------  %
	bg_model = 'ring';  % model of the background {'ring', 'svd'(default), 'nmf'}
	nb = 1;             % number of background sources for each patch (only be used in SVD and NMF model)
	bg_neuron_factor = 1.4;
	ring_radius = round(bg_neuron_factor * gSiz);  % when the ring model used, it is the radius of the ring used in the background model.
	%otherwise, it's just the width of the overlapping area
	num_neighbors = 50; % number of neighbors for each neuron

	% -------------------------      MERGING      -------------------------  %
	show_merge = false;  % if true, manually verify the merging step
	merge_thr = 0.65;     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
	method_dist = 'max';   % method for computing neuron distances {'mean', 'max'}
	dmin = 5;       % minimum distances between two neurons. it is used together with merge_thr
	dmin_only = 2;  % merge neurons if their distances are smaller than dmin_only.
	merge_thr_spatial = [spatial_thresh, temporal_thresh, -inf];  % merge components with highly correlated spatial shapes (corr=0.8) and small temporal correlations (corr=0.1)

	% -------------------------  INITIALIZATION   -------------------------  %
	K = [];             % maximum number of neurons per patch. when K=[], take as many as possible.
	% these two are defined at the top of the function now
	% min_corr = 0.75;     % minimum local correlation for a seeding pixel
	% min_pnr = 12;       % minimum peak-to-noise ratio for a seeding pixel
	min_pixel = gSig^2;      % minimum number of nonzero pixels for each neuron
	bd = 0;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
	frame_range = [];   % when [], uses all frames
	save_initialization = false;    % save the initialization procedure as a video.
	use_parallel = true;    % use parallel computation for parallel computing
	show_init = false;   % show initialization results
	choose_params = false; % manually choose parameters
	center_psf = true;  % set the value as true when the background fluctuation is large (usually 1p data)
	% set the value as false when the background fluctuation is small (2p)

	% -------------------------  Residual   -------------------------  %
	min_corr_res = 0.7;
	min_pnr_res = 6;
	seed_method_res = 'auto';  % method for initializing neurons from the residual
	update_sn = true;

	% ----------------------  WITH MANUAL INTERVENTION  --------------------  %
	with_manual_intervention = false;

	% -------------------------  FINAL RESULTS   -------------------------  %
	save_demixed = true;    % save the demixed file or not

	% -------------------------    UPDATE ALL    -------------------------  %
	neuron.updateParams('gSig', gSig, ...       % -------- spatial --------
	    'gSiz', gSiz, ...
	    'ring_radius', ring_radius, ...
	    'ssub', ssub, ...
	    'search_method', updateA_search_method, ...
	    'bSiz', updateA_bSiz, ...
	    'dist', updateA_bSiz, ...
	    'spatial_constraints', spatial_constraints, ...
	    'spatial_algorithm', spatial_algorithm, ...
	    'tsub', tsub, ...                       % -------- temporal --------
	    'deconv_options', deconv_options, ...
	    'nk', nk, ...
	    'detrend_method', detrend_method, ...
	    'background_model', bg_model, ...       % -------- background --------
	    'nb', nb, ...
	    'ring_radius', ring_radius, ...
	    'num_neighbors', num_neighbors, ...
	    'merge_thr', merge_thr, ...             % -------- merging ---------
	    'dmin', dmin, ...
	    'method_dist', method_dist, ...
	    'min_corr', min_corr, ...               % ----- initialization -----
	    'min_pnr', min_pnr, ...
	    'min_pixel', min_pixel, ...
	    'bd', bd, ...
	    'center_psf', center_psf);
	neuron.Fs = Fs;

neuron.getReady_batch(pars_envs);

%% initialize neurons in batch mode
use_prev = false; % turn off using previous initializations
neuron.initComponents_batch(K, save_initialization, use_parallel, use_prev);

%% udpate spatial components for all batches
neuron.update_spatial_batch(use_parallel);

%% udpate temporal components for all bataches
neuron.update_temporal_batch(use_parallel);

%% update background
neuron.update_background_batch(use_parallel);

%% get the correlation image and PNR image for all neurons
neuron.correlation_pnr_batch();

%% concatenate temporal components
neuron.concatenate_temporal_batch();
neuron.remove_false_positives();
neuron.merge_neurons_dist_corr(show_merge);
neuron.merge_high_corr(show_merge, merge_thr_spatial);
neuron.viewNeurons([],neuron.C_raw);

%% save workspace
neuron.save_workspace_batch();

	%% initialize neurons in batch mode
	[center, Cn, PNR] = neuron.initComponents_parallel(K, frame_range, save_initialization, use_parallel, use_prev);

	neuron.compactSpatial();

	neuron.update_background_parallel(use_parallel);

	neuron.merge_neurons_dist_corr(show_merge);
	neuron.merge_high_corr(show_merge, merge_thr_spatial);

	%% udpate spatial components for all batches
	neuron.update_spatial_parallel(use_parallel);

	for m=1:2
	  % update temporal
	  neuron.update_temporal_parallel(use_parallel);

	  % delete bad neurons
	  neuron.remove_false_positives();

	  % merge neurons based on temporal correlation + distances
	  neuron.merge_neurons_dist_corr(show_merge);
	end

	%% update background
	neuron.update_background_parallel(use_parallel);

	%% delete neurons
	neuron.remove_false_positives();

	%% merge neurons
	neuron.merge_neurons_dist_corr(show_merge);
	neuron.merge_high_corr(show_merge, merge_thr_spatial);

	%% get the correlation image and PNR image for all neurons
	neuron.correlation_pnr_parallel();

	%% save workspace
	% neuron.save_workspace();
	neuron.save_results(sprintf('neuron-extract_%s', fname));
	neuron.save_neurons();
end % function
