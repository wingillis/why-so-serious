
% load cell data from your current dir
cells = load_cells('inscopix');
% n x m where n=cells; m=time

% TODO: add optional code to show how the cells spike over time
show_trace = false;
if show_trace
  plot(cells(1:15, :)')
  figure();
  imagesc(cells(1:15, :)')
end

% do some quality control on the cells. Only choose stuff with high snr and low variance?

% based on visual inspection, any spiking threshold is 2 or above
spikes = detect_spikes(cells);

% if using cnmfe-based cells, also look at how many spikes are present

% load kinect data to compare to pcs and labels

extr = kinect_extract_findall;

% manually decide which dataset corresponds to ds of interest
extr = extr(1);

%% go through different numbers of cells to see which ones explain the labels that
% the model generates the best (figure out how to do this)
rng(1); % set seed to predetermined value

% should we think of correlating neurons across days?

% interested in the spatial component of the cellular spiking as well
