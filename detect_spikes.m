function [spikes]=detect_spikes(cells, thresh)
  % detect spikes from df/f using a threshold
  if nargin == 1
    thresh = 2; % just by default, why not
  end
  spikes = cells > thresh;
  spikes = num2cell(spikes, 2);
  spikes = cellfun(@(x) conv(single(x), [1 -1], 'same'), spikes, 'UniformOutput', false);
  spikes = cell2mat(spikes);
  spikes = spikes(:, 1:end-1)==1;
end  % function
