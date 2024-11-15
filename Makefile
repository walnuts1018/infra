INFRAUTIL ?= .github/scripts/infrautil/infrautil

build-infrautil:
	cd .github/scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: build-infrautil
	$(INFRAUTIL) namespace -d ./k8s/apps -o ./k8s/namespaces/namespaces.json5

.PHONY: snapshot
snapshot:
	make app-snapshot
	make helm-snapshot

.PHONY: app-snapshot
app-snapshot: build-infrautil
	$(INFRAUTIL) snapshot -d ./k8s/apps -o ./k8s/snapshots/apps

.PHONY: helm-snapshot
helm-snapshot: build-infrautil
	$(INFRAUTIL) helm-snapshot -d ./k8s/snapshots/apps -o ./k8s/snapshots/helm

.PHONY: terraform
terraform: 
	$(eval SECRET_KEY := $(shell op item get minio-default-secret-key --field secret_key --reveal))
	kubectl port-forward -n zitadel services/zitadel 8080:8080 &
	kubectl port-forward -n minio services/minio 9000:9000 &
	terraform -chdir=".\terraform\kurumi" init -upgrade
	terraform -chdir=".\terraform\kurumi" plan -var="minio_secret_key=$(SECRET_KEY)"
	terraform -chdir=".\terraform\kurumi" apply -var="minio_secret_key=$(SECRET_KEY)" -auto-approve

.PHONY: aquq
aquq:
	aqua i

.PHONY: lint
lint: snapshot
	kubeconform -ignore-missing-schemas -strict -summary k8s/snapshots/apps
