CLUSTER_NAME=berry
NODE_NAME=cheese
NODE_IP=192.168.0.14

.PHONY: gen-config
gen-config:
	talosctl gen config $(CLUSTER_NAME) https://$(NODE_IP):6443 --config-patch @patch.yaml -o ./out --force


INITIAL_NODE_IP:=

.PHONY: initial-apply
initial-apply: gen-config
	talosctl apply-config --insecure --nodes $(INITIAL_NODE_IP) --file ./out/controlplane.yaml

.PHONY: bootstrap
bootstrap:
	talosctl bootstrap --nodes 192.168.0.14 --endpoints 192.168.0.14 --talosconfig=./out/talosconfig

.PHONY: dashboard
dashboard:
	talosctl dashboard --nodes 192.168.0.14 --endpoints 192.168.0.14 --talosconfig=./out/talosconfig

.PHONY: get-kubeconfig
get-kubeconfig:
	talosctl kubeconfig ./out/kubeconfig --nodes 192.168.0.14 --endpoints 192.168.0.14 --talosconfig=./out/talosconfig
