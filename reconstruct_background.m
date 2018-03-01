function reconstruct_background(fname)
%% assumes that neurons were extracted using the newest version of cnmfe
% warning: does not correct for neurons that you have discarded after
% manually processing them
load(fname);
mf = matfile(['background-' fname], 'writable', true);
sz = 0;

for i=1:numel(neuron.batches)
	bneuron = neuron.batches{i};
	ybg = bneuron.reconstruct_background();
	sz = sz + size(ybg, 3);
	if i == 1
		mf.ybg = ybg;
	else
		mf.ybg(:, :, sz+1:size(ybg, 3) + sz +1) = ybg;
	end

end
