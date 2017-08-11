
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

figure(3);
plot(spikeOnsets);

sigma = 1.4;
sz = 35;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
%
smoothedSpikes = conv(spikeOnsets, gaussFilter, 'same');

figure(4);
imagesc(allSpikes)

cellSpikes = mat2cell(allSpikes, ones(1, size(allSpikes,1)), size(allSpikes, 2));
cellSmoothedSpikes = cellfun(@(x) conv(x, gaussFilter, 'same'), cellSpikes, 'uniformoutput', false);

cellSmoothedSpikes = cell2mat(cellSmoothedSpikes);
