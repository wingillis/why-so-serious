function [c]=instantiate_cluster(options)
  % needed to run things through O2
  if ~any(strcmp(parallel.clusterProfiles, 'o2 local R2016b'))
    configCluster();
  end
  % condition for our queue - configure thru your config file
  ClusterInfo.setQueueName(options.cluster.queue);
  ClusterInfo.setWallTime(options.cluster.wall_time);
  ClusterInfo.setMemUsage(options.cluster.mem);
  ClusterInfo.setUserNameOnCluster(options.cluster.username);
  ClusterInfo.setEmailAddress(options.cluster.email);
  ClusterInfo.setUserDefinedOptions(options.cluster.user_defined_opts);
  % create the cluster object
  c = parcluster();
  c.JobStorageLocation = '/n/groups/datta/win/matlab';
end
