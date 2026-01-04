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
