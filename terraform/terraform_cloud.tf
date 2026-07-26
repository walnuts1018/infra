module "terraform_cloud" {
  source = "./modules/terraform_cloud"

  b2_application_key               = var.b2_application_key
  cloudflare_api_token             = var.cloudflare_api_token
  netbird_management_token         = var.netbird_management_token
  oci_private_key                  = var.oci_private_key
  seaweedfs_secret_key             = var.seaweedfs_secret_key
  zitadel_google_idp_client_secret = var.zitadel_google_idp_client_secret
  zitadel_jwt_profile_json         = var.zitadel_jwt_profile_json
}

import {
  to = module.terraform_cloud.tfe_organization.walnuts_dev
  id = "walnuts-dev"
}

import {
  to = module.terraform_cloud.tfe_project.default
  id = "prj-2PMnnqkJPcRr9PVZ"
}

import {
  to = module.terraform_cloud.tfe_organization_default_settings.walnuts_dev
  id = "walnuts-dev"
}

import {
  to = module.terraform_cloud.tfe_workspace.infra
  id = "ws-feVzA68c4v9PiFDK"
}

import {
  to = module.terraform_cloud.tfe_workspace_settings.infra
  id = "ws-feVzA68c4v9PiFDK"
}

import {
  to = module.terraform_cloud.tfe_variable_set.aws_iam
  id = "varset-dQbUdG52Fsj6ELfM"
}

import {
  to = module.terraform_cloud.tfe_project_variable_set.aws_iam
  id = "walnuts-dev/prj-2PMnnqkJPcRr9PVZ/AWS IAM"
}

import {
  to = module.terraform_cloud.tfe_workspace_variable_set.aws_iam
  id = "walnuts-dev/infra/AWS IAM"
}

import {
  to = module.terraform_cloud.tfe_variable.aws_provider_auth
  id = "walnuts-dev/varset-dQbUdG52Fsj6ELfM/var-3paB8Arxxs1L3C2H"
}

import {
  to = module.terraform_cloud.tfe_variable.aws_run_role_arn
  id = "walnuts-dev/varset-dQbUdG52Fsj6ELfM/var-VWXybkNkMT3E586i"
}

import {
  to = module.terraform_cloud.tfe_variable.b2_application_key
  id = "walnuts-dev/infra/var-srC7qBuFcNEDJGLV"
}

import {
  to = module.terraform_cloud.tfe_variable.cloudflare_api_token
  id = "walnuts-dev/infra/var-dDDrn8W4ijTmiW57"
}

import {
  to = module.terraform_cloud.tfe_variable.netbird_management_token
  id = "walnuts-dev/infra/var-pLdyVcgB2B896Vdt"
}

import {
  to = module.terraform_cloud.tfe_variable.oci_private_key
  id = "walnuts-dev/infra/var-fr7PTPmEQqhr6cSB"
}

import {
  to = module.terraform_cloud.tfe_variable.seaweedfs_secret_key
  id = "walnuts-dev/infra/var-AxVvUy4EnnaJdotr"
}

import {
  to = module.terraform_cloud.tfe_variable.zitadel_google_idp_client_secret
  id = "walnuts-dev/infra/var-WPCPeeSrE1r4sxf4"
}

import {
  to = module.terraform_cloud.tfe_variable.zitadel_jwt_profile_json
  id = "walnuts-dev/infra/var-chRukYvQPXvq4gWC"
}
