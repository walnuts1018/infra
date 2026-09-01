locals {
  seaweedfs_desired_state = jsondecode(file("${path.module}/../k8s/apps/seaweedfs-default/_configs/desired-state.json"))
  seaweedfs_terraform_identity = one([
    for identity in local.seaweedfs_desired_state.accessKeyIdentities : identity
    if identity.name == "terraform"
  ])
}

module "seaweedfs" {
  source     = "./modules/seaweedfs"
  access_key = local.seaweedfs_terraform_identity.accessKey
  secret_key = var.seaweedfs_secret_key
}

