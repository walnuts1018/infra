import {
  to = google_project.gemini_free
  id = local.free_project_id
}

import {
  to = google_project.gemini_paid
  id = local.paid_project_id
}

import {
  to = google_iam_workload_identity_pool.terraform_cloud
  id = "projects/${local.free_project_id}/locations/global/workloadIdentityPools/horse-tfc"
}

import {
  to = google_iam_workload_identity_pool_provider.terraform_cloud
  id = "projects/${local.free_project_id}/locations/global/workloadIdentityPools/horse-tfc/providers/terraform-cloud"
}

import {
  to = google_service_account.terraform_cloud_plan
  id = "projects/${local.free_project_id}/serviceAccounts/horse-tfc-plan@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account.terraform_cloud_apply
  id = "projects/${local.free_project_id}/serviceAccounts/horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account_iam_member.terraform_cloud_plan
  id = "projects/${local.free_project_id}/serviceAccounts/horse-tfc-plan@${local.free_project_id}.iam.gserviceaccount.com roles/iam.workloadIdentityUser principalSet://iam.googleapis.com/projects/${google_project.gemini_free.number}/locations/global/workloadIdentityPools/horse-tfc/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:plan"
}

import {
  to = google_service_account_iam_member.terraform_cloud_apply
  id = "projects/${local.free_project_id}/serviceAccounts/horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com roles/iam.workloadIdentityUser principalSet://iam.googleapis.com/projects/${google_project.gemini_free.number}/locations/global/workloadIdentityPools/horse-tfc/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:apply"
}

import {
  for_each = toset([local.free_project_id, local.paid_project_id])

  to = google_project_iam_member.terraform_cloud_plan_viewer[each.key]
  id = "${each.key} roles/viewer serviceAccount:horse-tfc-plan@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = toset([local.free_project_id, local.paid_project_id])

  to = google_project_iam_member.terraform_cloud_apply_viewer[each.key]
  id = "${each.key} roles/viewer serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = toset([local.free_project_id, local.paid_project_id])

  to = google_project_iam_member.terraform_cloud_apply_service_usage[each.key]
  id = "${each.key} roles/serviceusage.serviceUsageAdmin serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = toset([local.free_project_id, local.paid_project_id])

  to = google_project_iam_member.terraform_cloud_apply_api_keys[each.key]
  id = "${each.key} roles/serviceusage.apiKeysAdmin serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_custom_role.terraform_cloud_plan_budgets
  id = "projects/${local.paid_project_id}/roles/horseGeminiBudgetReader"
}

import {
  to = google_project_iam_member.terraform_cloud_plan_budgets
  id = "${local.paid_project_id} projects/${local.paid_project_id}/roles/horseGeminiBudgetReader serviceAccount:horse-tfc-plan@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_custom_role.terraform_cloud_apply_budgets
  id = "projects/${local.paid_project_id}/roles/horseGeminiBudgetManager"
}

import {
  to = google_project_iam_member.terraform_cloud_apply_budgets
  id = "${local.paid_project_id} projects/${local.paid_project_id}/roles/horseGeminiBudgetManager serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_member.terraform_cloud_apply_billing_project_manager
  id = "${local.paid_project_id} roles/billing.projectManager serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_billing_account_iam_member.terraform_cloud_plan_billing_costs_manager
  id = "${var.billing_account_id} roles/billing.projectCostsManager serviceAccount:horse-tfc-plan@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_billing_account_iam_member.terraform_cloud_apply_billing_user
  id = "${var.billing_account_id} roles/billing.user serviceAccount:horse-tfc-apply@${local.free_project_id}.iam.gserviceaccount.com"
}

import {
  to = google_billing_project_info.gemini_paid
  id = "projects/${local.paid_project_id}"
}
