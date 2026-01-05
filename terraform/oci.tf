module "oci" {
  source          = "./modules/oci"
  private_key     = var.oci_private_key
  key_fingerprint = local.oci_key_fingerprint
}

locals {
  oci_key_fingerprint = "82:47:a3:82:ae:61:e8:00:43:e4:e7:c0:fc:45:fa:e2"
}

output "oci_orange_public_ip" {
  value = module.oci.orange_public_ip
}
