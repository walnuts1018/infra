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

.PHONY: terraform
terraform: 
	make terraform-setup
	make terraform-plan
	make terraform-apply

.PHONY: terraform-setup
terraform-setup:
	kubectl port-forward -n minio services/minio 9000:9000 &
	
	$(eval MINIO_SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal))
	terraform -chdir="./terraform/kurumi" init -upgrade -backend-config="secret_key=$(MINIO_SECRET_KEY)" -migrate-state

.PHONY: terraform-plan
terraform-plan:
	$(eval MINIO_SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal))
	$(eval CLOUDFLARE_API_TOKEN := $(shell op item get cloudflare --field terraform-api-token --reveal))
	terraform -chdir="./terraform/kurumi" plan -var="minio_secret_key=$(MINIO_SECRET_KEY)" -var="cloudflare_api_token=$(CLOUDFLARE_API_TOKEN)"

.PHONY: terraform-apply
terraform-apply:
	$(eval MINIO_SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal))
	$(eval CLOUDFLARE_API_TOKEN := $(shell op item get cloudflare --field terraform-api-token --reveal))
	terraform -chdir="./terraform/kurumi" apply -var="minio_secret_key=$(MINIO_SECRET_KEY)" -var="cloudflare_api_token=$(CLOUDFLARE_API_TOKEN)" -auto-approve

.PHONY: aqua
aqua:
	aqua i

.PHONY: lint
lint: snapshot
	kubeconform -ignore-missing-schemas -strict -summary k8s/snapshots/apps
