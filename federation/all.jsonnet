local clusterCfgs = import "config.json";
local gce = import "../phase1/gce/gce.jsonnet";
{ 
  "federation.tf": std.foldl(
    std.mergePatch,
    [
      gce(cfg)
      for cfg in clusterCfgs
    ],
    {}
  )
}