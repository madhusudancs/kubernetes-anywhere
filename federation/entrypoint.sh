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
set -x

cd "${BASH_SOURCE%/*}"

readonly OUTPUT_DIR="/_output"

# Fetch the list of cluster names from config.json
readonly CLUSTER_NAMES=($(jq -r '.[].phase1.cluster_name' "${OUTPUT_DIR}/config.json"))

# Log and store terraform log.
export TF_LOG=TRACE
export TF_LOG_PATH="${OUTPUT_DIR}/terraform.log"

gen() {
  mkdir -p "${OUTPUT_DIR}"

  for cname in ${CLUSTER_NAMES[@]}; do
    mkdir -p "${OUTPUT_DIR}/manifests/${cname}"
  done

  jsonnet -J "${OUTPUT_DIR}" -J ../ --multi "${OUTPUT_DIR}" all.jsonnet
}

deploy() {
  gen
  terraform apply -state="${OUTPUT_DIR}/terraform.tfstate" "${OUTPUT_DIR}"

  for cname in ${CLUSTER_NAMES[@]}; do
    kubectl create -f "${OUTPUT_DIR}/manifests/${cname}" --context="${cname}"
  done

  # Arbitrarily select the first cluster as the bootstrap cluster.
  kubectl config use-context "${CLUSTER_NAMES[0]}"
}

destroy() {
  terraform destroy -force -state="${OUTPUT_DIR}/terraform.tfstate" "${OUTPUT_DIR}"
}

case "${1:-}" in
  "")
    ;;
  "deploy")
    deploy
    ;;
  "destroy")
    destroy
    ;;
  "gen")
    gen
    ;;
esac
