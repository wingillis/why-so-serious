function plt_gridsearch(nc, npoints, maxthresh)
  figure();
  [xx, yy] = meshgrid(1:npoints, 1:npoints);

  surf(xx, yy, nc);
  colormap bone;

  xticks(linspace(1, npoints, 10));
  xticklabels(linspace(maxthresh, 0, 10));
  yticks(linspace(1, npoints, 10));
  yticklabels(linspace(maxthresh, 0, 10));
  xlabel('spatial thresh');
  ylabel('termoral thresh');
  zlabel('neuron count');

  view(0, 90);
  print('grid1', '-dpng', '-r300');

  view(135, 60);
  print('grid2', '-dpng', '-r300');

  view(-45, 60);
  print('grid3', '-dpng', '-r300');

  savefig(gcf, 'grid');

end
