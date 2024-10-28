.PHONY: tool-build
tool-build:
	cd .github/scripts/infrautil && go build -o infrautil .


.PHONY: snapshot
snapshot:
	./.github/scripts/infrautil/infrautil snapshot ./k8s/apps ./k8s/.snapshot.yaml

.PHONY: namespace
namespace:
	./.github/scripts/infrautil/infrautil namespace -o ./k8s/namespaces/namespaces.yaml ./k8s/.snapshot.yaml
