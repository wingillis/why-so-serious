function reconstruct_background(fname)
%% assumes that neurons were extracted using the newest version of cnmfe
% warning: does not correct for neurons that you have discarded after
% manually processing them
load(fname);
mf = matfile(['background-' fname], 'writable', true);
sz = 0;

for i=1:numel(neuron.batches)
	fprintf('Running on batch %d\n', i);
	bneuron = neuron.batches{i}.neuron;
	ybg = bneuron.reconstruct_background([1 size(bneuron.C_prev, 2)]);
	if i == 1
		mf.ybg = ybg;
	else
		mf.ybg(:, :, sz+1:size(ybg, 3) + sz) = ybg;
	end
	sz = sz + size(ybg, 3);
end
