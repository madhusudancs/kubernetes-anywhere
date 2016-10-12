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
VALUES_FILE="${OUTPUT_DIR}/values.yaml"

API_SERVER_SVC_NAMESPACE="federation"
API_SERVER_SVC_NAME="federation-apiserver"

if [[ ! -f "${VALUES_FILE}" ]]; then
	VALUES_FILE=""
fi

TILLER_LOG="/var/log/tiller.log"
tiller > "${TILLER_LOG}" 2>&1 &

for i in $(seq 1 30); do
	if grep -q "Tiller is listening on :44134" "${TILLER_LOG}" || false; then
		break
	fi
	sleep 1
done

grep "Tiller is listening on :44134" /var/log/tiller.log

helm --host localhost:44134 install namespace
helm --host localhost:44134 --values "${VALUES_FILE}" install federation

function get_svc_ep {
  local ip=""
  local hname=""
  echo "Waiting for \"${API_SERVER_SVC_NAME}\" to acquire an external IP address/hostname"
  for i in $(seq 1 30); do
    ip=$(kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[?(@.ip!="")].ip}' svc ${API_SERVER_SVC_NAME})
    hname=$(kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[?(@.hostname!="")].hostname}' svc ${API_SERVER_SVC_NAME})
    if [[ -n ${ip} ]]; then
      EP=${ip}
      echo "IP address found for \"${API_SERVER_SVC_NAME}\": ${EP}"
      break
    elif [[ -n ${hname} ]]; then
      EP=${hname}
      echo "Hostname found for \"${API_SERVER_SVC_NAME}\": ${EP}"
      break
    fi
    echo "No IP address or hostname found for \"${API_SERVER_SVC_NAME}\". Trying again in 5 seconds..."
    sleep 5
  done
}

EP=""
get_svc_ep
TOKEN=$(cat /apiserver.token)

kubectl config set-cluster federation-cluster --insecure-skip-tls-verify=true --server="https://${EP}"
kubectl config set-credentials federation-cluster --token="${TOKEN}"
kubectl config set-context federation-cluster --user=federation-cluster --cluster=federation-cluster
