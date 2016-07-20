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

FEDERATION_API_TOKEN="$(dd 'if=/dev/urandom' bs=128 count=1 2>/dev/null | base64 | tr -d '=+/' | dd bs=32 count=1 2>/dev/null)"
FEDERATION_API_KNOWN_TOKENS="${FEDERATION_API_TOKEN},admin,admin"

cat <<EOF> /values.yaml
apiserverToken: "${FEDERATION_API_TOKEN}"
apiserverKnownTokens: "${FEDERATION_API_KNOWN_TOKENS}"
EOF

TILLER_LOG="/var/log/tiller.log"
tiller > "${TILLER_LOG}" 2>&1 &

for i in $(seq 1 30); do
	if grep -q "Tiller is running on :44134" "${TILLER_LOG}" || false; then
		break
	fi
	sleep 1
done

grep "Tiller is running on :44134" /var/log/tiller.log

helm --host localhost:44134 install namespace
helm --host localhost:44134 --values /values.yaml install federation