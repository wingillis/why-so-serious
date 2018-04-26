function [out]=compute_correlations(fname)
	mf = matfile(fname);
	neuron = Sources2D();
	neuron.options.d1 = mf.Ysiz(1, 1);
	neuron.options.d2 = mf.Ysiz(1, 2);
	neuron.options.gSiz = 10;
	neuron.options.gSig = 2.5;

	frames = mf.Y(:, :, 1:2500);
	Yr = reshape(frames, [], 2500);

	[Cn, pnr] = correlation_image_endoscope(Yr, neuron.options);

	figure();
	imagesc(Cn);
	caxis([0.5 1]);
	colorbar();
	saveas(gcf, 'correlation-image', 'png');

	figure();
	imagesc(pnr);
	caxis([5 20]);
	colorbar();
	saveas(gcf, 'pnr', 'png');

end % function
