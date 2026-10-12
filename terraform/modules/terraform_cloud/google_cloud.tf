locals {
  google_cloud_credentials = {
    TFC_GCP_PROVIDER_AUTH               = "true"
    TFC_GCP_WORKLOAD_PROVIDER_NAME      = var.google_cloud_workload_provider_name
    TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL  = var.google_cloud_plan_service_account_email
    TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL = var.google_cloud_apply_service_account_email
  }
}

resource "tfe_variable" "google_cloud_credentials" {
  for_each     = local.google_cloud_credentials
  workspace_id = tfe_workspace.infra.id
  key          = each.key
  value        = each.value
  category     = "env"
  hcl          = false
  sensitive    = false
}

import {
  for_each = {
    TFC_GCP_PROVIDER_AUTH               = "var-NyMHvKWQ2Gv3tNKf"
    TFC_GCP_WORKLOAD_PROVIDER_NAME      = "var-bBjFnJ4Em8zUhuM2"
    TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL  = "var-vqzQuo4HHWZKWd35"
    TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL = "var-jSJtG6PdrZCKxV5g"
  }
  to = tfe_variable.google_cloud_credentials[each.key]
  id = "walnuts-dev/infra/${each.value}"
}
