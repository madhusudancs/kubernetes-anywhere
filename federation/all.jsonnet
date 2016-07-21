local clusterCfgs = import "config.json";
local gce = import "../phase1/gce/gce.jsonnet";
local addons = import "../phase3/all.jsonnet";

local manifests = {
  [cfg.phase1.cluster_name]: addons(cfg)
  for cfg in clusterCfgs
};

{ 
  "federation.tf": std.foldl(
    std.mergePatch,
    [
      gce(cfg)
      for cfg in clusterCfgs
    ],
    {}
  )
} + {
  ["manifests/" + name + "/" + manifest]: manifests[name][manifest]
  for name in std.objectFields(manifests)
    for manifest in std.objectFields(manifests[name])
}
