function [c]=instantiate_cluster()
  configCluster();
  ClusterInfo.setQueueName('mpi');
  ClusterInfo.setWallTime('24:00:00');
  ClusterInfo.setMemUsage('20G');
  c = parcluster();
end
