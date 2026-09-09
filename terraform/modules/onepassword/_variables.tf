
variable "argocd_cli_client_id" {
  type = string
}

variable "seaweedfs_biscuit_terraform_access_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit Terraform S3 access key supplied by the root Terraform variable"
}

variable "seaweedfs_biscuit_terraform_secret_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit Terraform S3 secret key supplied by the root Terraform variable"
}

variable "seaweedfs_biscuit_backup_access_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit backup writer access key supplied by the root Terraform variable"
}

variable "seaweedfs_biscuit_backup_secret_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit backup writer secret key supplied by the root Terraform variable"
}
