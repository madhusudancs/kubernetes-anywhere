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

ENV TERRAFORM_VERSION=0.6.16

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_'"${TERRAFORM_VERSION}"'_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum --status -c terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin
RUN rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ADD terraform-provider-kubernetes /bin/

# WORKDIR cd /kubernetes-anywhere/phase1/gce
# RUN /jsonnet/jsonnet -J ../.. --multi .tmp all.jsonnet

ENTRYPOINT ["/bin/bash"]

# To build
# docker build -t jsonnet:0.1 .

# To run
# docker run -it -m 12G --memory-swap=16G -v ~/godev/src/k8s.io/kubernetes-anywhere:/kubernetes-anywhere -v $HOME/.config/gcloud/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json jsonnet:0.1
