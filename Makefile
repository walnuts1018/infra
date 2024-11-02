INFRAUTIL ?= .github/scripts/infrautil/infrautil

.PHONY: build-tools
build-tools: build-infrautil build-infrautil2

build-infrautil:
	cd .github/scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: build-infrautil
	$(INFRAUTIL) namespace -d ./k8s/argocdapps -o ./k8s/namespaces/namespaces.json5

SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal)

.PHONY: terraform
terraform:
	terraform -chdir=".\terraform\kurumi" init
	terraform -chdir=".\terraform\kurumi" plan -var="minio_secret_key=$(SECRET_KEY)"
	terraform -chdir=".\terraform\kurumi" apply -var="minio_secret_key=$(SECRET_KEY)" -auto-approve
