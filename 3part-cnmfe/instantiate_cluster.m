function [c]=instantiate_cluster()
  % TODO: make this configurable by the user
  configCluster();
  ClusterInfo.setQueueName('mpi');
  ClusterInfo.setWallTime('24:00:00');
  ClusterInfo.setMemUsage('25G');
  ClusterInfo.setUserNameOnCluster('wg41');
  ClusterInfo.setEmailAddress('wgillis@g.harvard.edu');
  ClusterInfo.setUserDefinedOptions('--mail-type=END');
  c = parcluster();
end
