% I copied the kinect_extract object from the _analysis/backup folder on Jeff's
% orchestra group folder

% directory
d = '/Volumes/Data2/k9_01212017_kinect';
cd(d);

% load it up
load('../kinect_object.mat')

extr = kinect_extract(3);

clear kinect_extract;

% get the random projections
rps = extr.projections.rp(:, 1:80);

% load the cells
load('motionCorre-borderless-downsample2x_results.mat')

extr.load_inscopix_timestamps();


fprintf('Nan frames %d', sum(isnan(extr.timestamps.inscopix)))


grin = hifiber(neuron.C_raw(1:10, :), extr.timestamps.inscopix);

figure(1);
subplot(2,1,1);
imagesc(rps(1:2000, :)');
subplot(2,1,2);
plot(neuron.C_raw(1:10, 1:2000)');
