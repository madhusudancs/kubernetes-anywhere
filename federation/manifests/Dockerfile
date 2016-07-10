FROM ubuntu:16.04
MAINTAINER "Madhusudan C.S. <madhusudancs@google.com>"

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

RUN mkdir -p $(dirname ${HELMSRC})
RUN git clone https://github.com/kubernetes/helm.git ${HELMSRC}
RUN cd ${HELMSRC} && make bootstrap build 
RUN cd ${HELMSRC} && cp bin/{helm,tiller} ${GOBIN}
RUN helm init -c

# RUN curl https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl -o /bin/kubectl 
# RUN chmod +x /bin/kubectl

ENTRYPOINT ["/bin/bash"]

# To build
# docker build -t helm:0.1 .

# To run
# docker run -it -m 12G --memory-swap=16G -v ~/godev/src/k8s.io/kubernetes-anywhere/federation/manifests:/manifests helm:0.1