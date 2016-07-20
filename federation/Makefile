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

IMAGE_NAME?=gcr.io/madhusudancs-k8s/kubernetes-anywhere-federation
IMAGE_VERSION?=v0.0.1

KUBE_VERSION?=v1.3.0

UID?=$(shell id -u)
GID?=$(shell id -g)
TEMP_DIR:=$(shell mktemp -d)

.PHONY: build
build:
	tar czf $(TEMP_DIR)/kubernetes-anywhere.tar.gz ../federation ../phase{1,2,3}
	cp Dockerfile $(TEMP_DIR)/
	cd $(TEMP_DIR) && docker build \
	  --build-arg VERSION=$(KUBE_VERSION) \
	  -t $(IMAGE_NAME):$(IMAGE_VERSION) .
	rm -rf $(TEMP_DIR)

.PHONY: push
push:
	gcloud docker push $(IMAGE_NAME):$(IMAGE_VERSION)

.PHONY: run
run:
	docker run \
	  --user=$(id -u):$(id -g) \
	  -m 12G \
	  -v ${HOME}/.config/gcloud/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json:ro \
	  -v ${HOME}/.kube:/root/.kube \
	  -v ${PWD}/.gen:/_output \
	  $(IMAGE_NAME):$(IMAGE_VERSION) \
	  ${do}

.PHONY: runbash
runbash:
	docker run \
	  --user=$(UID):$(GID) \
	  -m 12G \
	  -v ${HOME}/.config/gcloud/application_default_credentials.json:/.config/gcloud/application_default_credentials.json \
	  -v ${HOME}/.kube:/.kube \
	  -v ${PWD}/.gen:/_output \
	  -it \
	  --entrypoint "/bin/bash" \
	  $(IMAGE_NAME):$(IMAGE_VERSION)