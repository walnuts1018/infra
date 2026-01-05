module "b2" {
  source             = "./modules/b2"
  application_key_id = local.b2_application_key_id
  application_key    = var.b2_application_key
}

locals {
  b2_application_key_id = "004ab15b5942e2c0000000004"
}

output "b2_application_key" {
  sensitive = true
  value     = module.b2.application_key
}
