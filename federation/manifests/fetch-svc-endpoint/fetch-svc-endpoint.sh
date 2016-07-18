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

# TODO: Convert this to a Go program. There are two advantages, the polling
# code could be handled in a much better in Go. Also, it is arguably more
# readable and testable.

function get_svc_ep {
	local ip=""
	local hname=""
	for i in $(seq 1 30); do
		ip=$(kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[?(@.ip!="")].ip}' svc ${API_SERVER_SVC_NAME})
		hname=$(kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[?(@.hostname!="")].hostname}' svc ${API_SERVER_SVC_NAME})
		if [[ -n ${ip} ]]; then
			EP=${ip}
			break
		elif [[ -n ${hname} ]]; then
			EP=${hname}
			break
		fi
		sleep 5
	done
}

function apiserver_endpoint_cm {
	local -r ep="${1:-}"
	if [[ -z "${ep}" ]]; then
		echo "Failed to fetch the load balancer address of the service"
		exit 1
	fi

	if ! kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" configmap "${API_SERVER_ENDPOING_CONFIGMAP_NAME}" || false; then
		kubectl create --namespace="${API_SERVER_SVC_NAMESPACE}" configmap "${API_SERVER_ENDPOING_CONFIGMAP_NAME}" --from-literal="endpoint=${ep}"
	fi 2>/dev/null
}

function kubeconfig_secret {
	local -r ep="${1:-}"

	# TODO: Parametrize this value as a helm chart parameter
	NAME="federation-cluster"
	cfgdir="$(mktemp -d)"
	cfgfile="${cfgdir}/kubeconfig"

	if ! kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" secret "${API_SERVER_TOKENS_SECRET_NAME}" || false; then
		echo "Could not find secret: ${API_SERVER_TOKENS_SECRET_NAME}"
		exit 1
	fi 2>/dev/null

	if kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" secret "${API_SERVER_KUBECONFIG_SECRET_NAME}" || false; then
		echo "Federation API server kubeconfig already exists, not creating a new kubeconfig secret."
		return
	fi 2>/dev/null

	local -r token=$(kubectl get --namespace="${API_SERVER_SVC_NAMESPACE}" secret "${API_SERVER_TOKENS_SECRET_NAME}" --template '{{.data.token}}' | base64 -d)

    touch "${cfgfile}"

	kubectl config set-cluster "${NAME}" \
  	  --kubeconfig=${cfgfile} \
	  --server="${ep}" \
	  --insecure-skip-tls-verify=true

	kubectl config set-credentials "${NAME}" \
	  --kubeconfig="${cfgfile}" \
	  --token="${token}"

	kubectl config set-context "${NAME}" \
	  --kubeconfig=${cfgfile} \
	  --cluster="${NAME}" \
	  --user="${NAME}"

	kubectl config use-context "${NAME}" \
	  --kubeconfig=${cfgfile} \
	  --cluster="${NAME}"

	kubectl create secret generic "${API_SERVER_KUBECONFIG_SECRET_NAME}" \
	  --namespace="${API_SERVER_SVC_NAMESPACE}" \
	  --from-file="${cfgfile}"

	rm -r "${cfgdir}"
}

EP=""
get_svc_ep
apiserver_endpoint_cm "${EP}"
kubeconfig_secret "${EP}"