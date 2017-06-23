function [g, extr]=pcaica_rpcell_corr()
  [g, extr] = load_grin_initialization();
  g.exclude_pcaica_cells();
end
