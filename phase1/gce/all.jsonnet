local clusterCfgs = import "../../federation/config.json";
local util = import "../../util/arrayMerge.jsonnet";
local tfCluster = import "gce.jsonnet";
{ 
  "federation.tf": std.foldl(
    std.mergePatch,
    [
      tfCluster(cfg)
      for cfg in clusterCfgs
    ],
    {}
  )
}