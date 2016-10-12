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

IMAGE_NAME?=gcr.io/madhusudancs-containers/federation-charts
IMAGE_VERSION?=v0.9.1

KUBE_VERSION?=v1.4.2

.PHONY: build
build:
	docker build \
	  --build-arg VERSION=$(KUBE_VERSION) \
	  -t $(IMAGE_NAME):$(IMAGE_VERSION) .

.PHONY: push
push:
	gcloud docker push $(IMAGE_NAME):$(IMAGE_VERSION)

.PHONY: runbash
runbash:
	docker run \
	  -it \
	  -m 12G \
	  --memory-swap=16G \
	  -v $(HOME)/.kube/config:/root/.kube/config:ro \
	  --entrypoint=/bin/bash \
	  $(IMAGE_NAME):$(IMAGE_VERSION)
