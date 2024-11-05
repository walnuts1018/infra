INFRAUTIL ?= .github/scripts/infrautil/infrautil

.PHONY: build-tools
build-tools: build-infrautil build-infrautil2

build-infrautil:
	cd .github/scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: build-infrautil
	$(INFRAUTIL) namespace -d ./k8s/apps -o ./k8s/namespaces/namespaces.json5

.PHONY: snapshot
snapshot: build-infrautil
	$(INFRAUTIL) snapshot -d ./k8s/apps -o ./k8s/snapshots/apps

# SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal)
# .PHONY: terraform
# terraform: 
# 	terraform -chdir=".\terraform\kurumi" init
# 	terraform -chdir=".\terraform\kurumi" plan -var="minio_secret_key=$(SECRET_KEY)"
# 	terraform -chdir=".\terraform\kurumi" apply -var="minio_secret_key=$(SECRET_KEY)" -auto-approve

.PHONY: aquq
aquq:
	aqua i

.PHONY: lint
lint: snapshot
	kubeconform -ignore-missing-schemas -strict -summary k8s/snapshots/apps
