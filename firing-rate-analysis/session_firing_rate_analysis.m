
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
  spikes = tmp > 2*std(tmp);
  spikes = conv([1 -1], double(spikes));
  spikeTimes{i} = diff(find(spikes == 1));
  spikeTimes{i} = 1./spikeTimes{i}.*30;
  itis = itis + histcounts(spikeTimes{i}, edges);
  allITIs = [allITIs; spikeTimes{i}];
  spikeOnsets(find(spikes==1)+1) = spikeOnsets(find(spikes==1)+1)+1;
  allSpikes(i, find(spikes==1)+1) = 1;
end

medianTimes = cellfun(@median, spikeTimes);

figure(1);
histogram(medianTimes, 100);


figure(2);
bar(edges(1:end-1), itis);

% figure(3);
% plot(spikeOnsets);

sigma = 0.5;
sz = 55;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
%
smoothedSpikes = conv(spikeOnsets, gaussFilter, 'same');

figure(3);
plot(smoothedSpikes)

cellSpikes = mat2cell(allSpikes, ones(1, size(allSpikes,1)), size(allSpikes, 2));
cellSmoothedSpikes = cellfun(@(x) conv(x, gaussFilter, 'same'), cellSpikes, 'uniformoutput', false);
cellSmoothedSpikes = cell2mat(cellSmoothedSpikes);

figure(4);
imagesc(cellSmoothedSpikes)

% what the hellll happens when we try to compute the spectrum of the signal
sampling = 901;
fftsig = fft(smoothedSpikes, sampling); % arbitrary sample size
powah = fftsig.*conj(fftsig)/floor(sampling/2);
freq = 30/sampling*(0:floor(sampling/2));

fig = figure(5);
plot(freq, powah(1:ceil(sampling/2)));
ylim([0 500]);
xlim([0 5]);
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 4 2];
print(fig, 'frequency-analysis', '-dpng', '-r150');
