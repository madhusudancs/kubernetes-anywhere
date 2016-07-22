TAG=v2
IMAGE=gcr.io/madhusudancs-containers/install-k8s

build:
	docker build -t "$(IMAGE):$(TAG)" .

push: build
	gcloud docker push "$(IMAGE):$(TAG)"

.PHONY: build push
