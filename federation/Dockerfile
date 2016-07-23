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

ARG VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        jq \
		g++ \
		gcc \
		libc6-dev \
		make \
		curl \
		ca-certificates \
		unzip \
	&& rm -rf /var/lib/apt/lists/*


ADD https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod +x /bin/kubectl

RUN git clone https://github.com/google/jsonnet.git /jsonnet
RUN cd /jsonnet && make && cp jsonnet /usr/local/bin/

ENV TERRAFORM_VERSION=0.7.0-rc1

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_'"${TERRAFORM_VERSION}"'_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum --status -c terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin
RUN rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ADD https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz ./
RUN tar xzf go1.6.2.linux-amd64.tar.gz

ENV GOROOT /go
ENV GOPATH /godev
ENV GOBIN ${GOPATH}/bin

ENV PATH ${GOBIN}:${GOROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p ${GOBIN}
RUN curl https://glide.sh/get | sh

RUN mkdir -p ${GOPATH}/src/k8s.io
ENV KUBEFORM_DIR ${GOPATH}/src/k8s.io/contrib/kubeform

RUN git clone https://github.com/madhusudancs/contrib.git ${GOPATH}/src/k8s.io/contrib -b kubeform-kubeconfig-delete
RUN cd ${KUBEFORM_DIR} && glide install && make
RUN cd ${KUBEFORM_DIR} && cp terraform-provider-kubernetes /usr/local/bin/

# Docker is weird. If I add the directory without creating a tarball and
# change the permissions, I can't access anything within the subdirectories
# in /kubernetes-anywhere when I run the container with --user
# (non-privileged user). But I can when I extract the tarball.
# Also see https://github.com/docker/docker/issues/7511
ADD kubernetes-anywhere.tar.gz /tmp/kubernetes-anywhere
RUN cp -r /tmp/kubernetes-anywhere /kubernetes-anywhere && chmod -R a+rwx /kubernetes-anywhere && rm -r /tmp/kubernetes-anywhere

WORKDIR /kubernetes-anywhere/federation

ENTRYPOINT ["./entrypoint.sh"]
