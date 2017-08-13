
if ~(exist('neuron', 'var') == 1)
  error('No neuron loaded');
end

spikeTimes = {};
spikeOnsets = zeros(1, size(neuron.C_raw, 2));
allSpikes = zeros(size(neuron.C_raw));
edges = linspace(0, 15, 800);
itis = zeros(1, length(edges)-1);
allITIs = [];

for i=1:size(neuron.C_raw, 1)
  tmp = smooth(diff(neuron.C_raw(i,:)), 5);
  spikes = tmp > (2*std(tmp) + mean(tmp));
  spikes = conv([1 -1], double(spikes));
  spikeTimes{i} = diff(find(spikes == 1));
  spikeTimes{i} = 1./spikeTimes{i}.*30;
  itis = itis + histcounts(spikeTimes{i}, edges);
  allITIs = [allITIs; spikeTimes{i}];
  spikeOnsets(find(spikes==1)+1) = spikeOnsets(find(spikes==1)+1)+1;
  % replace calcium transients with a spike indicator
  allSpikes(i, find(spikes==1)+1) = 1;
end

medianTimes = cellfun(@median, spikeTimes);

if false
  figure(1);
  histogram(medianTimes, 100);
end

if false
  figure(2);
  bar(edges(1:end-1), itis);
end

% NOTE: I changed sigma from 0.5 to this:
sigma = 0.43;
sz = 55;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
%
smoothedSpikes = conv(spikeOnsets, gaussFilter, 'same');

if false
  figure(3);
  plot(smoothedSpikes)
end

cellSpikes = mat2cell(allSpikes, ones(1, size(allSpikes,1)), size(allSpikes, 2));
cellSmoothedSpikes = cellfun(@(x) conv(x, gaussFilter, 'same'), cellSpikes, 'uniformoutput', false);
cellSmoothedSpikes = cell2mat(cellSmoothedSpikes);

if false
  figure(4);
  imagesc(cellSmoothedSpikes)
end

% what the hellll happens when we try to compute the spectrum of the signal
sampling = 1024;
fftsig = fft(zscore(smoothedSpikes), sampling); % arbitrary sample size
powah = fftsig.*conj(fftsig)/(sampling/2);
freq = 30/sampling*(0:(sampling/2)-1);

if false
  fig = figure(5);
  plot(freq, powah(1:sampling/2));
  ylim([0 500]);
  xlim([0 5]);
  fig.PaperUnits = 'inches';
  fig.PaperPosition = [0 0 4 2];
  print(fig, 'frequency-analysis', '-dpng', '-r150');
end

if false
  % plotting random projections
  num_dims = 500;
  n = size(cellSmoothedSpikes,1);
  % random rotations
  S = randn(n, num_dims) / sqrt(num_dims);
  C = zscore(cellSmoothedSpikes', [], 1) * S;
  figure(6);
  imagesc(C');
  colormap bone;
end

if false
  [thresh, smooth_sig] = ndgrid(linspace(0, 2, 30), linspace(0, 2, 30));
  % changepoint analysis on random projections
  deltac=delta_coefficients(C',2);
  peakloc = [];
  for i=1:numel(thresh)

    bin_score=abs(deltac)>thresh(i);
    kernel=normpdf([round(-smooth_sig(i)*6):round(smooth_sig(i)*6)],0,smooth_sig(i));
    smooth_score=conv(mean(bin_score),kernel,'same');
    [pks, locs] = findpeaks(smooth_score, 'minpeakdistance', 4);
    if isempty(diff(locs))
      peakloc(i) = 0;
    else
      [f, xi] = ksdensity(diff(locs));
      tmp = xi(find(max(f)==f));
      peakloc(i) = tmp(1);
    end

  end

  figure(7);
  [xx, yy] = meshgrid(1:30, 1:30);
  surf(xx, yy, reshape(peakloc, 30,30));
  title('changepoint on RPs')
  % 60 as in 2 sec @ 30hz
  caxis([0 60]);
  zlim([0 60]);
end

sigma = 0.43; % the changepoint distance doesn't change much with different smoothings
sz = 50;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
cellSpikes = mat2cell(allSpikes, ones(1, size(allSpikes,1)), size(allSpikes, 2));
cellSmoothedSpikes = cellfun(@(x) conv(x, gaussFilter, 'same'), cellSpikes, 'uniformoutput', false);
cellSmoothedSpikes = cell2mat(cellSmoothedSpikes);
deltac = delta_coefficients(zscore(neuron.C_raw')', 2);

% changepoint analysis on point-process spiking information
peakloc = [];
resolution = 35;
smoothing_opts = linspace(0, 4, resolution);
thresh_opts = linspace(0, 2.5, resolution);
[smooth_sig, thresh] = ndgrid(smoothing_opts, thresh_opts);


for i=1:numel(thresh)

  bin_score=abs(deltac)>thresh(i);
  kernel=normpdf([round(-smooth_sig(i)*6):round(smooth_sig(i)*6)],0, smooth_sig(i));
  smooth_score=conv(mean(bin_score), kernel, 'same');
  [pks, locs] = findpeaks(zscore(smooth_score), 'minpeakdistance', 4);
  if isempty(diff(locs))
    peakloc(i) = 0;
  else
    [f, xi] = ksdensity(diff(locs));
    tmp = xi(find(max(f)==f));
    peakloc(i) = tmp(1);
  end
end

figure(9);
[xx, yy] = meshgrid(thresh_opts, smoothing_opts);
surf(xx, yy, reshape(peakloc, length(smoothing_opts), length(thresh_opts)));
title('changepoint on spiking')
ylabel('deltac smoothing');
xlabel('thresholding')
% 60 as in 2 sec @ 30hz
% caxis([0 20]);
% zlim([0 20]);

% just example parameters
thresh = 1;
smooth_sig = 1.5;
bin_score=abs(deltac)>thresh;
kernel=normpdf([round(-smooth_sig*6):round(smooth_sig*6)],0, smooth_sig);
smooth_score=conv(mean(bin_score), kernel, 'same');
[pks, locs] = findpeaks(zscore(smooth_score), 'minpeakdistance', 4);

figure(10);
imagesc(flipud(zscore(neuron.C_raw')'));
colormap bone;
hold on;
plot(smooth_score./max(smooth_score).*400, 'g');
hold off;

% detrend and run a periodogram to smooth the data - spectrogram
