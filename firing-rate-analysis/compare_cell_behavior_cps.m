
obj=kinect_extract_findall_objects(pwd,[],'rp');
uuid_list={'faaac17c-7f71-402e-9ab1-4448a991e1b9',...
    '816d2c07-6e2b-4bb4-a344-ca450628da53',...
    'cb1bdc39-775b-44f1-8a8d-784783d6058d',...
    '13300a48-e03a-47c6-8e00-fbd369195004',...
    '4e4da87a-4989-4a14-8eea-dc5f6f1eaa13',...
    'fd72855d-e504-40ac-9457-c44f69328aae',...
    'bb1b64d9-7d57-4b90-963a-0c053c8de074',...
    'd4e7232c-ca26-4cbc-8963-9c5fab8b33ea'};
load('../kube_modeling/inscopix/kubejob_2017-07-29_15-12-10/export_results_6dbe20f3-2151-46fb-b74f-1dd9d2e359d9.mat');
obj.load_model_labels(labels,metadata,9);
beh=obj.get_behavior_object;
beh.sort_states_by_usage;
[~,usage]=beh.get_syllable_usage;
%

obj=obj(obj.filter_by_uuid(uuid_list));
beh=obj.get_behavior_object;

cadata=obj.get_imaging;

%%

phan=phanalysis(cadata,beh,obj,'imaging');
phan.load_metadata('mouse_metadata.json');
phan.set_option('syllable_cutoff',max(find(usage>=.01)));
phan.set_option('filter_trace',false);
phan.set_option('changepoint_threshold',1);
phan.set_option('max_lag',100);
phan.set_option('scalar_shift',-.15);

%%
%
% window around behavior transitions, and changepoints

phan.window_imaging('b');
phan.window_imaging('c');

% gets the vector we need for scalar correlations (and decoding)

phan.get_scalars_correlation;

% gets scalar summaries of each syllable (note: this take a while)

phan.get_scalars_summary;

% gets the kl and scalar distances

phan.get_interbehavior_distance;

% make sure the frames are aligned with the kinect data
allSpikes = zeros(size(neuron.C_raw));

for i=1:size(neuron.C_raw, 1)
  tmp = smooth(diff(neuron.C_raw(i,:)), 5);
  spikes = tmp > (2*std(tmp) + mean(tmp));
  spikes = conv([1 -1], double(spikes));
  allSpikes(i, find(spikes==1)+1) = 1;
end

sigma = % TODO: use value from gridsearch when it finishes
sz = 55;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);

cellSpikes = mat2cell(allSpikes, ones(1, size(allSpikes,1)), size(allSpikes, 2));
cellSmoothedSpikes = cellfun(@(x) conv(x, gaussFilter, 'same'), cellSpikes, 'uniformoutput', false);
cellSmoothedSpikes = cell2mat(cellSmoothedSpikes);
deltac = delta_coefficients(zscore(cellSmoothedSpikes), 2);

thresh = 1;
bin_score=abs(deltac)>thresh;
kernel=normpdf([round(-smooth_sig(i)*6):round(smooth_sig(i)*6)],0,smooth_sig(i));
smooth_score=conv(mean(bin_score),kernel, 'same');
% grab the indices of the changepoints
[pks, locs] = findpeaks(smooth_score, 'minpeakdistance', 3);
