
variable "argocd_cli_client_id" {
  type = string
}

variable "seaweedfs_biscuit_access_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit S3 access key supplied by the root Terraform variable"
}

variable "seaweedfs_biscuit_secret_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit S3 secret key supplied by the root Terraform variable"
}
