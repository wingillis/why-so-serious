% I copied the kinect_extract object from
% /groups/datta/Jeff/kinect2_data/inscopix/K9/_analysis/backup
% on orchestra

% directory
d = '/Volumes/Data2/k9_01212017_kinect';
cd(d);

% load it up
load('../kinect_object.mat')

% the 3rd object corresponds with the neuron extracted dataset I have
extr = extract_object(3);

clear extract_object;

% get the random projections
rps = extr.projections.rp(:, 1:80);

% load the extracted cells
load('motionCorre-borderless-downsample2x_results.mat')

extr.load_inscopix_timestamps();


fprintf('Nan frames %d\n', sum(isnan(extr.timestamps.inscopix)));
fprintf('Number timestamps: %d\n', length(extr.timestamps.inscopix));
fprintf('Number frames: %d\n', size(neuron.C, 2));

% grab 10 of the cells
grin = hifiber(neuron.C_raw(1:10, :), extr.timestamps.inscopix);

figure(1);
subplot(2,1,1);
imagesc(rps(1:2000, :)');
subplot(2,1,2);
hold on;
for i=1:10
  plot(grin.traces(i).raw(1:2000));
end
