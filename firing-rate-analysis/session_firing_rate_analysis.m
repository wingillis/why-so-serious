
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
  allSpikes(i, find(spikes==1)+1) = 1;
end

medianTimes = cellfun(@median, spikeTimes);

figure(1);
histogram(medianTimes, 100);


figure(2);
bar(edges(1:end-1), itis);

% NOTE: I changed sigma from 0.5 to this:
sigma = 1;
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
sampling = 1024;
fftsig = fft(zscore(smoothedSpikes), sampling); % arbitrary sample size
powah = fftsig.*conj(fftsig)/(sampling/2);
freq = 30/sampling*(0:(sampling/2)-1);

fig = figure(5);
plot(freq, powah(1:sampling/2));
ylim([0 500]);
xlim([0 5]);
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 4 2];
print(fig, 'frequency-analysis', '-dpng', '-r150');

% plotting random projections
num_dims = 300;
n = size(cellSmoothedSpikes,1);
% random rotations
S = randn(n, num_dims) / sqrt(num_dims);
C = zscore(cellSmoothedSpikes', [], 1) * S;
figure(6);
imagesc(C');
colormap bone;

thresh = 0.15;
smooth_sig = 0.43;
deltac=delta_coefficients(C',2);
bin_score=abs(deltac)>thresh;
kernel=normpdf([round(-smooth_sig*6):round(smooth_sig*6)],0,smooth_sig);
smooth_score=conv(mean(bin_score),kernel,'same');

figure(7);
plot(smooth_score);

function DELTAC=delta_coefficients(DATA, WIN, PAD)
  if nargin<3 | isempty(PAD), PAD=1; end
  if nargin<2 | isempty(WIN), WIN=2; end
  if nargin<1, error('Need DATA matrix to continue'); end

  if isvector(DATA)
      DATA=DATA(:)';
  end

  if PAD==1
  	DATA=[zeros(size(DATA,1),WIN) DATA  zeros(size(DATA,1),WIN)];
  elseif PAD==2
  	DATA=[ones(size(DATA,1),WIN).*repmat([DATA(:,1)],[1 WIN]) DATA ones(size(DATA,1),WIN).*repmat([DATA(:,end)],[1 WIN])];
  end

  WIN=round(WIN);

  [rows,columns]=size(DATA);

  % lose the edges via the window

  DELTAC=zeros(rows,columns-(2*(WIN+1)));

  for i=WIN+1:columns-(WIN)

  	deltanum=sum(repmat(1:WIN,[rows 1]).*(DATA(:,i+1:i+WIN)-DATA(:,i-WIN:i-1)),2);
  	deltaden=2*sum([1:WIN].^2);

  	DELTAC(:,i-(WIN))=deltanum./deltaden;
  end

end

% detrend and run a periodogram to smooth the data - spectrogram
