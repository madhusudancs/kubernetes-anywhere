TAG=v2
IMAGE=gcr.io/madhusudancs-k8s/install-k8s

build:
	docker build -t "$(IMAGE):$(TAG)" .

push: build
	gcloud docker push "$(IMAGE):$(TAG)"

.PHONY: build push
