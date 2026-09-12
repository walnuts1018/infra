resource "random_id" "seaweedfs_biscuit_terraform_access_key" {
  byte_length = 15
}

resource "random_password" "seaweedfs_biscuit_terraform_secret_key" {
  length  = 48
  special = false
}

module "terraform_cloud" {
  source = "./modules/terraform_cloud"

  seaweedfs_biscuit_terraform_access_key = random_id.seaweedfs_biscuit_terraform_access_key.hex
  seaweedfs_biscuit_terraform_secret_key = random_password.seaweedfs_biscuit_terraform_secret_key.result
}
