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
        gcc \
        libc6-dev \
		make \
		ca-certificates \
		mercurial \
		curl \
	&& rm -rf /var/lib/apt/lists/*

ADD https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz ./
RUN tar xzf go1.6.2.linux-amd64.tar.gz

ENV GOROOT /go
ENV GOPATH /godev
ENV GOBIN ${GOPATH}/bin

ENV HELMSRC ${GOPATH}/src/k8s.io/helm

ENV PATH ${GOBIN}:${GOROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p ${GOBIN}
RUN curl https://glide.sh/get | sh

ADD https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubectl /bin/kubectl 
RUN chmod +x /bin/kubectl

RUN mkdir -p $(dirname ${HELMSRC})
RUN git clone https://github.com/kubernetes/helm.git ${HELMSRC}
RUN cd ${HELMSRC} && make bootstrap build 
RUN cd ${HELMSRC} && cp bin/helm ${GOBIN}
RUN cd ${HELMSRC} && cp bin/tiller ${GOBIN}
RUN helm init -c

ADD install.sh /
ADD uninstall.sh /
ADD entrypoint.sh /
ADD /namespace /namespace
ADD /federation /federation

ENTRYPOINT ["/entrypoint.sh"]
