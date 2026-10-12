module "terraform_cloud" {
  source = "./modules/terraform_cloud"

  google_cloud_workload_provider_name      = module.google_cloud.terraform_cloud_workload_provider_name
  google_cloud_plan_service_account_email  = module.google_cloud.terraform_cloud_plan_service_account_email
  google_cloud_apply_service_account_email = module.google_cloud.terraform_cloud_apply_service_account_email
}
