local base_cfg = import "../../.config.a.json";
local tf_cluster = import "gce.jsonnet";
{ "federation.tf": std.foldl(std.mergePatch, [
  tf_cluster(base_cfg + cfg)
  for cfg in base_cfg
], {}) }
