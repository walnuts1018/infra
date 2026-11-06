output "vyos_router_setup_key" {
  value     = netbird_setup_key.vyos_router.key
  sensitive = true
}
