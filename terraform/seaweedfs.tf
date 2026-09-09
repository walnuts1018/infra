module "seaweedfs" {
  source = "./modules/seaweedfs"

  providers = {
    aws         = aws
    aws.biscuit = aws.biscuit
    external    = external
  }

  biscuit_endpoint             = "https://seaweedfs-biscuit.local.walnuts.dev"
  biscuit_terraform_access_key = var.seaweedfs_biscuit_terraform_access_key
  biscuit_terraform_secret_key = var.seaweedfs_biscuit_terraform_secret_key
  depends_on                   = [module.onepassword]
}
