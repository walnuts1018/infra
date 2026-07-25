resource "netbird_identity_provider" "zitadel" {
  name          = "ZITADEL"
  type          = "zitadel"
  issuer        = "https://auth.walnuts.dev"
  client_id     = var.zitadel_client_id
  client_secret = var.zitadel_client_secret

}

resource "netbird_group" "kubernetes_routers" {
  name = "kubernetes-routers"
}

resource "netbird_group" "remote_clients" {
  name = "remote-clients"
}

resource "netbird_group" "kubernetes_lan_resources" {
  name = "kubernetes-lan-resources"
}

resource "netbird_network" "kubernetes_lan" {
  name        = "kubernetes-lan"
  description = "LANs reachable through the Kubernetes routing peer"
}

resource "netbird_network_router" "kubernetes_lan" {
  network_id  = netbird_network.kubernetes_lan.id
  peer_groups = [netbird_group.kubernetes_routers.id]
  enabled     = true
  masquerade  = true
}

resource "netbird_network_resource" "node_lan" {
  network_id  = netbird_network.kubernetes_lan.id
  name        = "kubernetes-node-lan"
  description = "Kubernetes node subnet"
  address     = "192.168.0.0/24"
  groups      = [netbird_group.kubernetes_lan_resources.id]
  enabled     = true
}

resource "netbird_network_resource" "management_lan" {
  network_id  = netbird_network.kubernetes_lan.id
  name        = "management-lan"
  description = "Management subnet"
  address     = "192.168.4.0/24"
  groups      = [netbird_group.kubernetes_lan_resources.id]
  enabled     = true
}

resource "netbird_network_resource" "kubernetes_load_balancer_lan" {
  network_id  = netbird_network.kubernetes_lan.id
  name        = "kubernetes-load-balancer-lan"
  description = "Kubernetes LoadBalancer service subnet"
  address     = "192.168.12.0/24"
  groups      = [netbird_group.kubernetes_lan_resources.id]
  enabled     = true
}

resource "netbird_policy" "remote_clients_to_kubernetes_lan" {
  name        = "remote-clients-to-kubernetes-lan"
  description = "Allow remote NetBird clients to reach the routed Kubernetes LANs"
  enabled     = true

  rule {
    name          = "remote-clients-to-kubernetes-lan"
    action        = "accept"
    bidirectional = true
    enabled       = true
    protocol      = "all"
    sources       = [netbird_group.remote_clients.id]
    destinations  = [netbird_group.kubernetes_lan_resources.id]
  }
}

resource "netbird_setup_key" "kubernetes_router" {
  name                   = "kubernetes-routing-peer"
  type                   = "reusable"
  expiry_seconds         = 0
  allow_extra_dns_labels = false
  auto_groups            = [netbird_group.kubernetes_routers.id]
  ephemeral              = false
  revoked                = false
  usage_limit            = 0
}

output "kubernetes_router_setup_key" {
  value       = netbird_setup_key.kubernetes_router.key
  sensitive   = true
  description = "Reusable setup key for the Kubernetes routing peer"
}
