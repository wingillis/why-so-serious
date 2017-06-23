[g, extr] = load_pcaica_init();
mkdir('all_pcaica_neurons')
pcaica_neuron_chart(g, 'all_pcaica_neurons');
g.exclude_pcaica_cells();
mkdir('excluded_pcaica_neurons');
pcaica_neuron_chart(g, 'excluded_pcaica_neurons');

g.detect_spikes(5); % 6*std
cp_length_characterization;
g.save_png('cp_length_dist');

cp_2_cell_activity_characterization;
g.save_png('cell activity aligned to cp');
figure();
subplot(2,1,1);
imagesc(g.neurons, [0 10])
subplot(2,1,2);
plot(smooth(mean(g.spikes, 1), 15))
sh(1) = subplot(2,1,1);
sh(2) = subplot(2,1,2);
linkaxes(sh, 'x');
title('Metric of # neurons active')
subplot(2,1,1);
title('Single cell activity')
xlim([1e4 1.3e4]);
g.save_png('single cell activity vs mean activity');

g.plot_overview();
xlim([1 1e3]);
g.save_png('compare cells rps and cps');

g.plot_overview2();
xlim([1 1e3]);
g.save_png('compare cells rps and total activity');
