module "seaweedfs" {
  source = "./modules/seaweedfs"

  biscuit_endpoint   = "https://seaweedfs-biscuit.local.walnuts.dev"
  biscuit_access_key = var.seaweedfs_biscuit_access_key
  biscuit_secret_key = var.seaweedfs_biscuit_secret_key
}
