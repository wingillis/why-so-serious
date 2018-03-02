function subsample_background(fname)
	mf = matfile(fname);
	sz = size(mf, 'ybg');
	numsamples = 2000;
	iterations = floor(sz(3)/numsamples);
	subs = 5;
	xs = floor(sz(2)/subs);
	ys = floor(sz(1)/subs);
	[xx, yy] = meshgrid(1:xs:sz(2), 1:ys:sz(1));
	xx = xx(:);
	yy = yy(:);
	traces = zeros(subs^2, 1);
	for i=1:iterations+1
		start = (i-1)*numsamples + 1;
		en = i*numsamples;
		if en>sz(3)
			en = sz(3);
		end
		y = mf.ybg(:,:,start:en);
		fprintf('Iteration %d\n', i);
		for j=1:numel(xx)
			fprintf('Chunk %d\n', j);
			chunk = y(yy(j):yy(j)+ys-1, xx(j):xx(j)+xs-1, :);
			chunk = reshape(chunk, xs*ys, []);
			chunk = mean(chunk, 1);
			traces(j, start:en) = chunk;
		end
	end
	save(['subsample-' fname], 'traces');
end
