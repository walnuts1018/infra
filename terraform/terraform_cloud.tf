module "terraform_cloud" {
  source = "./modules/terraform_cloud"
}

removed {
  from = module.terraform_cloud.tfe_variable.b2_application_key

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.cloudflare_api_token

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.netbird_management_token

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.oci_private_key

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.seaweedfs_secret_key

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.zitadel_google_idp_client_secret

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.terraform_cloud.tfe_variable.zitadel_jwt_profile_json

  lifecycle {
    destroy = false
  }
}
