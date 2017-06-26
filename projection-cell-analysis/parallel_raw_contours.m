function parallel_raw_contours(fname, cnmfefname)
  % read in the size of the movie and send indices to each
  % batch script to make 1 min movies
  c = parcluster();
  mf = matfile(fname);

  %insertShape(mtx, 'Polygon', coords, 'LineWidth', 1);
  
end
