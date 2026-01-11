module "seaweedfs" {
  source = "./modules/seaweedfs"
  access_key = local.seaweedfs_access_key
  secret_key = var.seaweedfs_secret_key
}

