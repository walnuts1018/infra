INFRAUTIL ?= .github/scripts/infrautil/infrautil

.PHONY: build-tools
build-tools: build-infrautil build-infrautil2

build-infrautil:
	cd .github/scripts/infrautil && go build -o infrautil .

.PHONY: namespace
namespace: build-infrautil
	$(INFRAUTIL) namespace -d ./k8s/argocdapps -o ./k8s/namespaces/namespaces.json5
