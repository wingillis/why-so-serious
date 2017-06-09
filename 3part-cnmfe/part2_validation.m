%% load the neuron/data here

% look for file that has 'unprocessed' in its name
dat_data = dir('*unprocessed*.mat');
dat_data_file = dat_data(1).name;
% load it into this workspace
load(dat_data_file);

%% delete, trim, split neurons
neuron.viewNeurons([], neuron.C_raw);

save(strrep(dat_data_file, 'unprocessed', '_processed'), '-v7.3');
