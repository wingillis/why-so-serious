function mat2cnmfe_raw_trace(mfile, cnmfefile)
	% calculates the raw fluorescence values from a given cnmfe contour mask
	load(cnmfefile);
	contours = neuron.get_contours();
	mf = matfile(mfile);
	outdata = struct();
	outdata.cells = zeros(mf.sizY(3), length(contours));
	masks = zeros(d1*d2, length(contours));

	[x, y] = meshgrid(1:d1, 1:d2);
	for i=1:length(contours)
		a = inpolygon(x, y, contours{i}(2,:), contours{i}(1,:));
		a = reshape(a, [], 1);
		% set the mask for each neuron
		masks(:, i) = a;
	end

	% go through each frame once and then compute the fluorescence for each contour
	for i=1:mf.sizY(3)
		y = mf.Y(:, :, i);
		y = reshape(y, [], 1);
		for j=1:length(contours)
			outdata.cells(i, j) = mean(y(masks(:, j)));
		end
	end

	[basename, fname, ~] = fileparts(mfile);
	save(fullfile(basename, [fname '-contour-extracted-raw-trace.mat']), '-struct', 'outdata');

	% TODO: save the masks at the end

end % function
