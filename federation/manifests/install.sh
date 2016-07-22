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

if [[ ! -f "${VALUES_FILE}" ]]; then
	VALUES_FILE=""
fi

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
helm --host localhost:44134 --values "${VALUES_FILE}" install federation
