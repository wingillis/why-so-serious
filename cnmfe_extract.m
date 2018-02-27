function cnmfe_extract(fname, spatial_thresh, temporal_thresh, min_corr, min_pnr)
	%% extract neurons from an inscopix recording using the new version of CNMF_E
if nargin < 2
	spatial_thresh = 0.7;
end
if nargin < 3
	temporal_thresh = 0.2;
end
if nargin < 4
	min_corr = 0.82;     % minimum local correlation for a seeding pixel
end
if nargin < 5
	min_pnr = 17;       % minimum peak-to-noise ratio for a seeding pixel
end

%% extract neurons from an inscopix recording using the new version of CNMF_E

p = pwd();
mf = matfile(fname, 'writable', true);
mf.Ysiz = mf.sizY;

%% choose multiple datasets or just one
neuron = Sources2D();
nams = neuron.select_multiple_files({fname});  %if nam is [], then select data interactively

%% parameters
% -------------------------    COMPUTATION    -------------------------  %
pars_envs = struct('memory_size_to_use', 45, ... % GB, memory space you allow to use in MATLAB
	'memory_size_per_patch', 5.5, ... % GB, space for loading data within one patch
	'patch_dims', [128, 128],... % pixels, patch size
	'batch_frames', 2500); % number of frames per batch
  % -------------------------      SPATIAL      -------------------------  %
gSig = 3;  % pixel, gaussian width of a gaussian kernel for filtering the data. 0 means no filtering
gSiz = 6; % pixel, neuron diameter
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
	'method', 'thresholded', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
	'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
	'optimize_pars', true, ...  % optimize AR coefficients
	'optimize_b', true, ...% optimize the baseline);
	'max_tau', 100);    % maximum decay time (unit: frame);

nk = 1;             % detrending the slow fluctuation. usually 1 is fine (no detrending)
% when changed, try some integers smaller than total_frame/(Fs*30)
detrend_method = 'spline';  % compute the local minimum as an estimation of trend.
% detrend_method = 'local_min';  % compute the local minimum as an estimation of trend.

% -------------------------     BACKGROUND    -------------------------  %
bg_model = 'ring';  % model of the background {'ring', 'svd'(default), 'nmf'}
nb = 2;             % number of background sources for each patch (only be used in SVD and NMF model)
bg_neuron_factor = 2;
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
min_pixel = gSig^2;      % minimum number of nonzero pixels for each neuron
bd = 0;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
frame_range = [];   % when [], uses all frames
save_initialization = false;    % save the initialization procedure as a video.
% set to false for debugging
use_parallel = false;    % use parallel computation for parallel computing
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
    'dist', updateA_dist, ...
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

%% distribute data and be ready to run source extraction
neuron.getReady_batch(pars_envs);

%% initialize neurons from the video data within a selected temporal range
% if choose_params
  % change parameters for optimized initialization
% 	[gSig, gSiz, ring_radius, min_corr, min_pnr] = neuron.set_parameters();
% end

%% initialize neurons in batch mode
use_prev = false; % turn off using previous initializations
neuron.initComponents_batch(K, save_initialization, use_parallel, use_prev);

% neuron.compactSpatial();
for m=1:2
	neuron.update_spatial_batch(use_parallel);
	neuron.update_temporal_batch(use_parallel);
	neuron.update_background_batch(use_parallel);
end

neuron.correlation_pnr_batch();
neuron.concatenate_temporal_batch();

save(['cnmfe-new-neuron-results-', fname], 'neuron', '-v7.3');
impath = fullfile(p, 'neurons');
if ~(exist(impath, 'dir') == 7)
	mkdir(impath);
end
neuron.viewNeurons([], neuron.C_raw, impath);

end % function
