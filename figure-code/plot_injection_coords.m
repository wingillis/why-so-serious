function plot_injection_coords()
	nmda_inj_path = '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/implants/nmda_inj_coords.csv';
	fiber_implant_path = '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/implants/fiber-implant-coordinates.csv';
	virus_inj_path = '/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/implants/virus_inj_coords.csv';
	output_path ='/Users/wgillis/Dropbox (HMS)/lab-datta/projects/dls-function/paper/figs/implants/';

	ctx_size = [4.125 5]; % w x h in mm

	illustrator_fig_size = [96.159 114.905]; % w x h in mm

	scaling_factor = illustrator_fig_size ./ ctx_size;

	virus_coords = csvread(virus_inj_path, 1);
	nmda_coords = csvread(nmda_inj_path, 1);
	fiber_coords = csvread(fiber_implant_path, 2);

	f = figure(1);
	clf;
	plot(virus_coords(:, 2) .* scaling_factor(1), illustrator_fig_size(2) + (virus_coords(:, 3) .* scaling_factor(2)), 'k+', 'MarkerSize', 20);

	xlim([0 illustrator_fig_size(1)]);
	ylim([0 illustrator_fig_size(2)]);
	ax = gca;
	set(ax, 'Units', 'normalized', 'Position', [0 0 1 1]);
	box off;

	f.PaperUnits = 'centimeters';
	f.PaperPosition = [0 0 illustrator_fig_size ./ 10];

	saveas(f, fullfile(output_path, 'virus_plot'), 'epsc');

	f = figure(2);
	clf;
	plot(nmda_coords(:, 2) .* scaling_factor(1), illustrator_fig_size(2) + (nmda_coords(:, 3) .* scaling_factor(2)), 'k+', 'MarkerSize', 20);

	xlim([0 illustrator_fig_size(1)]);
	ylim([0 illustrator_fig_size(2)]);
	ax = gca;
	set(ax, 'Units', 'normalized', 'Position', [0 0 1 1]);
	box off;

	f.PaperUnits = 'centimeters';
	f.PaperPosition = [0 0 illustrator_fig_size ./ 10];

	saveas(f, fullfile(output_path, 'nmda_plot'), 'epsc');

	f = figure(3);
	clf;
	plot(fiber_coords(:, 2) .* scaling_factor(1), illustrator_fig_size(2) + (fiber_coords(:, 3) .* scaling_factor(2)), 'k+', 'MarkerSize', 20);

	xlim([0 illustrator_fig_size(1)]);
	ylim([0 illustrator_fig_size(2)]);
	ax = gca;
	set(ax, 'Units', 'normalized', 'Position', [0 0 1 1]);
	box off;

	f.PaperUnits = 'centimeters';
	f.PaperPosition = [0 0 illustrator_fig_size ./ 10];

	saveas(f, fullfile(output_path, 'fiber_plot'), 'epsc');
end % function
