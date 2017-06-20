function plot_things(gr)
  gr.plot_cell_activity;
  figure();
  imagesc(gr.spikes);
  figure();
  imagesc(gr.s_rate);
end % function
