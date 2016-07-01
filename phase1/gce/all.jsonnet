local clusterCfgs = import "../../federation/config.json";
local tf_cluster = import "gce.jsonnet";
{ 
  "federation.tf": std.foldl(
    std.mergePatch,
    [
      tf_cluster(cfg + {
        phase1+: {
          instance_prefix: cfg.name + "-" + cfg.phase1.instance_prefix
        }
      })
      for cfg in clusterCfgs
    ],
    {}
  )
}