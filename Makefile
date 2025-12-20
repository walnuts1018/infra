# Python-based infrautil (primary implementation)
PYTHON ?= python3
INFRAUTIL_PY = $(PYTHON) -m infrautil.cli

# Go-based infrautil (legacy, kept for compatibility)
INFRAUTIL_GO = scripts/infrautil/infrautil

.PHONY: setup-python
setup-python:
	cd scripts && $(PYTHON) -m pip install -q -e .

.PHONY: build-infrautil
build-infrautil:
	cd scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: setup-python
	cd scripts && $(INFRAUTIL_PY) namespace -d ../k8s/apps -o ../k8s/namespaces/namespaces.json5

.PHONY: snapshot
snapshot: setup-python
	make app-snapshot
	make helm-snapshot

.PHONY: app-snapshot
app-snapshot: setup-python
	cd scripts && $(INFRAUTIL_PY) snapshot -d ../k8s/apps -o ../k8s/snapshots/apps

.PHONY: helm-snapshot
helm-snapshot: build-infrautil
	$(INFRAUTIL_GO) helm-snapshot -d ./k8s/snapshots/apps -o ./k8s/snapshots/helm

.PHONY: terraform-init
terraform-init:	
	terraform -chdir="./terraform" init -upgrade -migrate-state

.PHONY: terraform-plan
terraform-plan:
	$(eval MINIO_SECRET_KEY := $(shell op item get minio --field terraform-secret-key --reveal))
	$(eval CLOUDFLARE_API_TOKEN := $(shell op item get hhrmfgqkbfvtpifxqjbtl24ihq --field terraform-api-token --reveal))
	$(eval B2_APPLICATION_KEY := $(shell op item get b2 --field terraform_application_key --reveal))
	terraform -chdir="./terraform" plan -var="minio_secret_key=$(MINIO_SECRET_KEY)" -var="cloudflare_api_token=$(CLOUDFLARE_API_TOKEN)" -var="b2_application_key=$(B2_APPLICATION_KEY)"

.PHONY: terraform-apply
terraform-apply:
	$(eval MINIO_SECRET_KEY := $(shell op item get minio --field terraform-secret-key --reveal))
	$(eval CLOUDFLARE_API_TOKEN := $(shell op item get hhrmfgqkbfvtpifxqjbtl24ihq --field terraform-api-token --reveal))
	$(eval B2_APPLICATION_KEY := $(shell op item get b2 --field terraform_application_key --reveal))
	terraform -chdir="./terraform" apply -var="minio_secret_key=$(MINIO_SECRET_KEY)" -var="cloudflare_api_token=$(CLOUDFLARE_API_TOKEN)" -var="b2_application_key=$(B2_APPLICATION_KEY)" -auto-approve

.PHONY: aqua
aqua:
	aqua i

.PHONY: lint
lint: snapshot
	kubeconform -ignore-missing-schemas -strict -summary k8s/snapshots/apps
