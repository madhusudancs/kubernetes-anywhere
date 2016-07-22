#!/bin/bash

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

readonly OUTPUT_DIR="/_output"
readonly VALUES_OVERRIDE_YAML="${OUTPUT_DIR}/values.yaml" 
readonly VALUES_YAML="/federation/values.yaml"

# First search for the namespace in the override file and capture it
# if it exists.
# Otherwise search for the namespace in the default values file and
# capture it if it exists.
if grep -q '^\s*namespace:.*' "${VALUES_OVERRIDE_YAML}" || false; then
	NAMESPACE=$(grep -Po '^\s*namespace:\s*\K(.*)' "${VALUES_OVERRIDE_YAML}")
elif grep -q '^\s*namespace:.*' "${VALUES_YAML}" || false; then
	NAMESPACE=$(grep -Po '^\s*namespace:\s*\K(.*)' "${VALUES_YAML}")
fi 2>/dev/null

# Ensure the variable NAMESPACE if bound.
NAMESPACE="${NAMESPACE:-}"
# Remove suffix double-quote i.e. transform "federation" -> "federation
NAMESPACE="${NAMESPACE%\"}"
# Remove prefix double-quote i.e. i.e. transform "federation" -> federation"
NAMESPACE="${NAMESPACE#\"}"

# Delete the namespace. This should do cascade delete of all the resources
# in the specified namespace. 
# NOTE: This doesn't delete non-namespaced resources. The only non-namespaced
# federation resource we have today is a PV dynamically provisioned for the
# API server etcd and it is the right/expected behavior to not delete the
# persistent volume upon resource deletion, so this operation is safe for now.
kubectl delete namespace "${NAMESPACE}"
