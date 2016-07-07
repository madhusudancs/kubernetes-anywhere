local clusterCfgs = import "../../federation/config.json";
local util = import "../../util/arrayMerge.jsonnet";
local tfCluster = import "gce.jsonnet";
{ 
  "federation.tf": std.foldl(
    util.mergeConcatArr,
    [
      tfCluster(cfg + {
        phase1+: {
          instance_prefix: cfg.name + "-" + cfg.phase1.instance_prefix
        }
      })
      for cfg in clusterCfgs
    ],
    {}
  )
}