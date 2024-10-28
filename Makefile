INFRAUTIL ?= .github/scripts/infrautil/infrautil

$(INFRAUTIL):
	cd .github/scripts/infrautil && go build -o infrautil .

.PHONY: snapshot
snapshot: $(INFRAUTIL)
	$(INFRAUTIL) snapshot ./k8s/apps ./k8s/.snapshot.yaml

.PHONY: namespace
namespace: $(INFRAUTIL)
	$(INFRAUTIL) namespace -o ./k8s/namespaces/namespaces.yaml ./k8s/.snapshot.yaml
