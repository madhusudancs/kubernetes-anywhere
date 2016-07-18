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

FROM ubuntu:16.04
MAINTAINER "Madhusudan C.S. <madhusudancs@google.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
		g++ \
		gcc \
		libc6-dev \
		make \
		ca-certificates \
		unzip \
	&& rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/google/jsonnet.git /jsonnet
RUN cd /jsonnet && make

ENV TERRAFORM_VERSION=0.7.0-rc1

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_'"${TERRAFORM_VERSION}"'_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum --status -c terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin
RUN rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ADD terraform-provider-kubernetes /usr/local/bin/
RUN chmod +x /usr/local/bin/terraform-provider-kubernetes

# WORKDIR cd /kubernetes-anywhere/phase1/gce
# RUN /jsonnet/jsonnet -J ../.. --multi .tmp all.jsonnet

ENTRYPOINT ["/bin/bash"]
