function neuron=make_neuron(d1, d2, fs, options)
  neuron = Sources2D('d1', d1, 'd2', d2, ... % dimensions of datasets
    'ssub', options.ds_space, ...
    'tsub', options.ds_time, ...  % downsampling
    'gSig', options.gauss_kernel, ...    % sigma of the 2D gaussian that approximates cell bodies
    'gSiz', options.neuron_dia, ...    % average neuron size (diameter)
    'use_parallel', false,...    % disable parallellization within CNMF_E to avoid transparency violations
    'temporal_parallel', false, ... % disable parallellization within CNMF_E
    'min_corr', options.min_corr, ...
    'min_pnr', options.min_pnr, ...
    'bd', options.bd);
  neuron.Fs = fs;  % frame rate
end
