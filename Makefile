INFRAUTIL ?= scripts/infrautil/infrautil

build-infrautil:
	cd scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: build-infrautil
	$(INFRAUTIL) namespace -d ./k8s/apps -o ./k8s/namespaces/namespaces.json5

.PHONY: snapshot
snapshot: build-infrautil
	make app-snapshot
	make helm-snapshot

.PHONY: app-snapshot
app-snapshot:
	$(INFRAUTIL) snapshot -d ./k8s/apps -o ./k8s/snapshots/apps

.PHONY: helm-snapshot
helm-snapshot: 
	$(INFRAUTIL) helm-snapshot -d ./k8s/snapshots/apps -o ./k8s/snapshots/helm

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

.PHONY: jsonnet-fmt
jsonnet-fmt:
	@echo "Formatting Jsonnet files..."
	@find k8s \( -name '*.jsonnet' -o -name '*.libsonnet' \) -type f | xargs jsonnetfmt -i

.PHONY: jsonnet-fmt-check
jsonnet-fmt-check:
	@echo "Checking Jsonnet format..."
	@find k8s \( -name '*.jsonnet' -o -name '*.libsonnet' \) -type f | xargs jsonnetfmt --test

.PHONY: lint
lint: snapshot
	kubeconform -ignore-missing-schemas -strict -summary k8s/snapshots/apps
