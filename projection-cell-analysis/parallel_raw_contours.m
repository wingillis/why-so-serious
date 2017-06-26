function parallel_raw_contours(fname, cnmfename, outfile)
  % read in the size of the movie and send indices to each
  % batch script to make 1 min movies
  ClusterInfo.setQueueName('short');
  ClusterInfo.setWallTime('12:00:00');
  ClusterInfo.setMemUsage('10G');
  ClusterInfo.setUserNameOnCluster('wg41');
  ClusterInfo.setEmailAddress('wgillis@g.harvard.edu');
  c = parcluster();
  mf = matfile(fname);
  siz = mf.sizY;
  cnmf = load(cnmfename);
  contours = cnmf.neuron.get_contours();
  clear cnmf;
  onemin = 30 * 60; % 30 fps
  chunk = ceil(siz(3)/onemin);
  jobs = cell(chunk, 1);
  for i=1:chunk
    jobs{i} = batch(c, @par_mat2contour, 1,...
              {fname, [(i-1)*onemin+1 i*onemin], contours, sprintf('%s-%d', outfile, i)});
  end
  for i=1:chunk
    wait(jobs{i});
    delete(jobs{i});
  end

end
