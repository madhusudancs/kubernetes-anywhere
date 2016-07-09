/*
Copyright 2016 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
{
  mergeConcatArr(target, patch)::
    if std.type(patch) == "object" then
      local res = if std.type(target) == "object" then target else {};

      local flds = if std.type(res) == "object" then std.objectFields(res) else [];

      local null_fields = [k for k in std.objectFields(patch) if patch[k] == null];

      local both_fields = std.setUnion(flds, std.objectFields(patch));

      {
        [k]:
          if !std.objectHas(patch, k) then
            res[k]
          else if !std.objectHas(res, k) then
            std.mergePatch(null, patch[k]) tailstrict
          else if std.type(res[k]) == "array" && std.type(patch[k]) == "array" then
            res[k] + patch[k]
          else
            std.mergePatch(res[k], patch[k]) tailstrict
          for k in std.setDiff(both_fields, null_fields)
      }
    else
      patch,
}