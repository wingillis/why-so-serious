
% load cell data from your current dir
cells = load_cells('inscopix');

% TODO: add optional code to show how the cells spike over time

% based on visual inspection, any spiking threshold is 2 or above
spikes = detect_spikes(cells);

% if using cnmfe-based cells, also look at how many spikes are present

% load kinect data to compare to pcs and labels

extr = kinect_extract_findall;

% manually decide which dataset corresponds to ds of interest
