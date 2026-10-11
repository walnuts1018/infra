provider "google" {}

data "google_client_config" "gemini" {
  count = var.gemini_gcp_enabled ? 1 : 0
}

data "google_billing_account" "gemini_paid" {
  count = var.gemini_gcp_enabled && var.gemini_paid_billing_account_id != "" ? 1 : 0

  billing_account = var.gemini_paid_billing_account_id
  open            = true
  lookup_projects = false
}

provider "restapi" {
  uri                  = "https://billingbudgets.googleapis.com"
  bearer_token         = var.gemini_gcp_enabled ? data.google_client_config.gemini[0].access_token : "disabled"
  write_returns_object = true
  debug                = false

  headers = {
    "Content-Type"        = "application/json"
    "x-goog-user-project" = var.gemini_paid_project_id
  }
}

resource "terraform_data" "gemini_prerequisites" {
  count = var.gemini_gcp_enabled ? 1 : 0

  input = {
    free_project_id = var.gemini_free_project_id
    paid_project_id = var.gemini_paid_project_id
    billing_account = var.gemini_paid_billing_account_id
    currency        = try(data.google_billing_account.gemini_paid[0].currency_code, "")
  }

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gemini_free_project_id)) && can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gemini_paid_project_id)) && var.gemini_free_project_id != var.gemini_paid_project_id
      error_message = "Gemini用の新規Project IDを2つ設定してください。"
    }

    precondition {
      condition     = var.gemini_paid_billing_account_id != ""
      error_message = "有料ProjectへリンクするCloud Billing Account IDが必要です。"
    }

    precondition {
      condition     = try(data.google_billing_account.gemini_paid[0].currency_code, "") == "JPY"
      error_message = "500円のSpendCapを作成するには、リンク先Cloud Billing Accountの通貨がJPYである必要があります。"
    }
  }
}

resource "google_project" "gemini_free" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project_id      = var.gemini_free_project_id
  name            = "Horse Gemini Free"
  org_id          = var.gemini_organization_id != "" ? var.gemini_organization_id : null
  deletion_policy = "PREVENT"

  depends_on = [terraform_data.gemini_prerequisites]
}

resource "google_project" "gemini_paid" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project_id      = var.gemini_paid_project_id
  name            = "Horse Gemini Paid"
  org_id          = var.gemini_organization_id != "" ? var.gemini_organization_id : null
  deletion_policy = "PREVENT"

  depends_on = [terraform_data.gemini_prerequisites]
}

import {
  for_each = var.gemini_gcp_enabled ? { free = var.gemini_free_project_id } : {}

  to = google_project.gemini_free[0]
  id = each.value
}

import {
  for_each = var.gemini_gcp_enabled ? { paid = var.gemini_paid_project_id } : {}

  to = google_project.gemini_paid[0]
  id = each.value
}

resource "google_billing_project_info" "gemini_paid" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project         = google_project.gemini_paid[0].project_id
  billing_account = var.gemini_paid_billing_account_id
}

resource "google_project_service" "gemini_free_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_free[0].project_id
  service            = "generativelanguage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_apikeys_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_free[0].project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_iam_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_free[0].project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_sts_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_free[0].project_id
  service            = "sts.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_iamcredentials_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_free[0].project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_paid[0].project_id
  service            = "generativelanguage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_apikeys_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_paid[0].project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_budgets_api" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project            = google_project.gemini_paid[0].project_id
  service            = "billingbudgets.googleapis.com"
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "gemini_tfc" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project                   = google_project.gemini_free[0].project_id
  workload_identity_pool_id = "horse-tfc"
  display_name              = "Horse HCP Terraform"
  description               = "HCP Terraform credentials for the infra workspace"
  disabled                  = false

  depends_on = [
    google_project_service.gemini_free_iam_api,
    google_project_service.gemini_free_sts_api,
  ]
}

resource "google_iam_workload_identity_pool_provider" "gemini_tfc" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project                            = google_project.gemini_free[0].project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.gemini_tfc[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud"
  display_name                       = "HCP Terraform infra workspace"
  description                        = "Trust only the walnuts-dev infra workspace plan and apply runs"

  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.tfc_org"             = "assertion.terraform_organization_name"
    "attribute.tfc_project"         = "assertion.terraform_project_name"
    "attribute.tfc_workspace_id"    = "assertion.terraform_workspace_id"
    "attribute.tfc_workspace_phase" = "assertion.terraform_workspace_id + ':' + assertion.terraform_run_phase"
  }

  attribute_condition = "assertion.terraform_organization_name == 'walnuts-dev' && assertion.terraform_project_name == 'Default Project' && assertion.terraform_workspace_name == 'infra' && assertion.terraform_workspace_id == 'ws-feVzA68c4v9PiFDK' && assertion.terraform_run_phase in ['plan', 'apply'] && assertion.aud == '//iam.googleapis.com/projects/${var.gemini_free_project_number}/locations/global/workloadIdentityPools/horse-tfc/providers/terraform-cloud'"

  oidc {
    issuer_uri = "https://app.terraform.io"
  }

  depends_on = [google_iam_workload_identity_pool.gemini_tfc]
}

resource "google_service_account" "gemini_tfc_plan" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project      = google_project.gemini_free[0].project_id
  account_id   = "horse-tfc-plan"
  display_name = "Horse Terraform plan"
  description  = "Read-only Google Cloud access for the HCP Terraform infra workspace plan phase"

  depends_on = [google_project_service.gemini_free_iam_api]
}

resource "google_service_account" "gemini_tfc_apply" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project      = google_project.gemini_free[0].project_id
  account_id   = "horse-tfc-apply"
  display_name = "Horse Terraform apply"
  description  = "Project-scoped Google Cloud access for the HCP Terraform infra workspace apply phase"

  depends_on = [google_project_service.gemini_free_iam_api]
}

resource "google_service_account_iam_member" "gemini_tfc_plan" {
  count = var.gemini_gcp_enabled ? 1 : 0

  service_account_id = google_service_account.gemini_tfc_plan[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gemini_tfc[0].name}/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:plan"
}

resource "google_service_account_iam_member" "gemini_tfc_apply" {
  count = var.gemini_gcp_enabled ? 1 : 0

  service_account_id = google_service_account.gemini_tfc_apply[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gemini_tfc[0].name}/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:apply"
}

resource "google_project_iam_member" "gemini_tfc_plan_viewer" {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  project = each.value
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.gemini_tfc_plan[0].email}"
}

resource "google_project_iam_member" "gemini_tfc_apply_viewer" {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  project = each.value
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_billing_account_iam_member" "gemini_tfc_plan_billing_costs_manager" {
  count = var.gemini_gcp_enabled ? 1 : 0

  billing_account_id = var.gemini_paid_billing_account_id
  role               = "roles/billing.projectCostsManager"
  member             = "serviceAccount:${google_service_account.gemini_tfc_plan[0].email}"
}

resource "google_project_iam_member" "gemini_tfc_apply_service_usage" {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  project = each.value
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_project_iam_member" "gemini_tfc_apply_api_keys" {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  project = each.value
  role    = "roles/serviceusage.apiKeysAdmin"
  member  = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_project_iam_custom_role" "gemini_tfc_apply_budgets" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project     = google_project.gemini_paid[0].project_id
  role_id     = "horseGeminiBudgetManager"
  title       = "Horse Gemini project budget manager"
  description = "Manage budgets and Gemini spend caps scoped to the Horse Gemini paid project"
  permissions = [
    "billing.resourcebudgets.configureSpendCap",
    "billing.resourcebudgets.read",
    "billing.resourcebudgets.write",
    "billing.resourceCosts.get",
    "resourcemanager.projects.get",
  ]
}

resource "google_project_iam_custom_role" "gemini_tfc_plan_budgets" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project     = google_project.gemini_paid[0].project_id
  role_id     = "horseGeminiBudgetReader"
  title       = "Horse Gemini project budget reader"
  description = "Read budgets and spend caps scoped to the Horse Gemini paid project"
  permissions = [
    "billing.resourcebudgets.read",
    "billing.resourceCosts.get",
    "resourcemanager.projects.get",
  ]
}

resource "google_project_iam_member" "gemini_tfc_plan_budgets" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project = google_project.gemini_paid[0].project_id
  role    = google_project_iam_custom_role.gemini_tfc_plan_budgets[0].name
  member  = "serviceAccount:${google_service_account.gemini_tfc_plan[0].email}"
}

resource "google_project_iam_member" "gemini_tfc_apply_budgets" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project = google_project.gemini_paid[0].project_id
  role    = google_project_iam_custom_role.gemini_tfc_apply_budgets[0].name
  member  = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_project_iam_member" "gemini_tfc_apply_billing_project_manager" {
  count = var.gemini_gcp_enabled ? 1 : 0

  project = google_project.gemini_paid[0].project_id
  role    = "roles/billing.projectManager"
  member  = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_billing_account_iam_member" "gemini_tfc_apply_billing_user" {
  count = var.gemini_gcp_enabled ? 1 : 0

  billing_account_id = var.gemini_paid_billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.gemini_tfc_apply[0].email}"
}

resource "google_apikeys_key" "gemini_free" {
  count = var.gemini_gcp_enabled ? 1 : 0

  name         = "horse-gemini-free"
  display_name = "Horse Gemini free project"
  project      = google_project.gemini_free[0].project_id

  restrictions {
    api_targets {
      service = "generativelanguage.googleapis.com"
    }
  }

  deletion_policy = "PREVENT"

  depends_on = [
    google_project_service.gemini_free_api,
    google_project_service.gemini_free_apikeys_api,
  ]
}

resource "google_apikeys_key" "gemini_paid" {
  count = var.gemini_gcp_enabled ? 1 : 0

  name         = "horse-gemini-paid"
  display_name = "Horse Gemini paid project"
  project      = google_project.gemini_paid[0].project_id

  restrictions {
    api_targets {
      service = "generativelanguage.googleapis.com"
    }
  }

  deletion_policy = "PREVENT"

  depends_on = [
    google_project_service.gemini_paid_api,
    google_project_service.gemini_paid_apikeys_api,
    restapi_object.gemini_paid_spend_cap,
  ]
}

locals {
  gemini_paid_budget_filter = {
    projects             = ["projects/${var.gemini_paid_project_number}"]
    services             = ["services/AEFD-7695-64FA"]
    calendarPeriod       = "MONTH"
    creditTypesTreatment = "EXCLUDE_ALL_CREDITS"
  }

  gemini_paid_spend_cap_notifications = {
    enableProjectLevelRecipients = true
  }

  gemini_paid_alert_notifications = {
    enableProjectLevelRecipients = true
    disableDefaultIamRecipients  = false
  }

  gemini_paid_spend_cap_data = jsonencode({
    displayName  = "Horse Gemini paid monthly 500 JPY spend cap"
    budgetFilter = local.gemini_paid_budget_filter
    amount = {
      specifiedAmount = {
        currencyCode = "JPY"
        units        = "500"
      }
    }
    thresholdRules = [
      { thresholdPercent = 0.5, spendBasis = "CURRENT_SPEND" },
      { thresholdPercent = 0.8, spendBasis = "CURRENT_SPEND" },
      { thresholdPercent = 1.0, spendBasis = "CURRENT_SPEND" }
    ]
    notificationsRule = local.gemini_paid_spend_cap_notifications
    spendCap          = { inputState = "CONFIGURED" }
  })

  gemini_paid_300_alert_data = jsonencode({
    displayName  = "Horse Gemini paid monthly 300 JPY alert"
    budgetFilter = local.gemini_paid_budget_filter
    amount = {
      specifiedAmount = {
        currencyCode = "JPY"
        units        = "300"
      }
    }
    thresholdRules = [
      { thresholdPercent = 1.0, spendBasis = "CURRENT_SPEND" }
    ]
    notificationsRule = local.gemini_paid_alert_notifications
  })
}

resource "restapi_object" "gemini_paid_spend_cap" {
  count = var.gemini_gcp_enabled ? 1 : 0

  path           = "/v1/billingAccounts/${var.gemini_paid_billing_account_id}/budgets"
  create_path    = "/v1/billingAccounts/${var.gemini_paid_billing_account_id}/budgets"
  read_path      = "/v1/{id}"
  update_path    = "/v1/{id}?updateMask=displayName,budgetFilter,amount,thresholdRules,notificationsRule,spendCap"
  destroy_path   = "/v1/{id}"
  create_method  = "POST"
  read_method    = "GET"
  update_method  = "PATCH"
  destroy_method = "DELETE"
  id_attribute   = "name"
  data           = local.gemini_paid_spend_cap_data

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_billing_project_info.gemini_paid, google_project_service.gemini_paid_budgets_api]
}

resource "restapi_object" "gemini_paid_300_alert" {
  count = var.gemini_gcp_enabled ? 1 : 0

  path           = "/v1/billingAccounts/${var.gemini_paid_billing_account_id}/budgets"
  create_path    = "/v1/billingAccounts/${var.gemini_paid_billing_account_id}/budgets"
  read_path      = "/v1/{id}"
  update_path    = "/v1/{id}?updateMask=displayName,budgetFilter,amount,thresholdRules,notificationsRule"
  destroy_path   = "/v1/{id}"
  create_method  = "POST"
  read_method    = "GET"
  update_method  = "PATCH"
  destroy_method = "DELETE"
  id_attribute   = "name"
  data           = local.gemini_paid_300_alert_data

  depends_on = [google_billing_project_info.gemini_paid, google_project_service.gemini_paid_budgets_api]
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_iam_workload_identity_pool.gemini_tfc[0]
  id = "projects/${var.gemini_free_project_id}/locations/global/workloadIdentityPools/horse-tfc"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_iam_workload_identity_pool_provider.gemini_tfc[0]
  id = "projects/${var.gemini_free_project_id}/locations/global/workloadIdentityPools/horse-tfc/providers/terraform-cloud"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_service_account.gemini_tfc_plan[0]
  id = "projects/${var.gemini_free_project_id}/serviceAccounts/horse-tfc-plan@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_service_account.gemini_tfc_apply[0]
  id = "projects/${var.gemini_free_project_id}/serviceAccounts/horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_service_account_iam_member.gemini_tfc_plan[0]
  id = "projects/${var.gemini_free_project_id}/serviceAccounts/horse-tfc-plan@${var.gemini_free_project_id}.iam.gserviceaccount.com roles/iam.workloadIdentityUser principalSet://iam.googleapis.com/projects/${var.gemini_free_project_number}/locations/global/workloadIdentityPools/horse-tfc/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:plan"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_service_account_iam_member.gemini_tfc_apply[0]
  id = "projects/${var.gemini_free_project_id}/serviceAccounts/horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com roles/iam.workloadIdentityUser principalSet://iam.googleapis.com/projects/${var.gemini_free_project_number}/locations/global/workloadIdentityPools/horse-tfc/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:apply"
}

import {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  to = google_project_iam_member.gemini_tfc_plan_viewer[each.key]
  id = "${each.key} roles/viewer serviceAccount:horse-tfc-plan@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  to = google_project_iam_member.gemini_tfc_apply_viewer[each.key]
  id = "${each.key} roles/viewer serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  to = google_project_iam_member.gemini_tfc_apply_service_usage[each.key]
  id = "${each.key} roles/serviceusage.serviceUsageAdmin serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? toset([var.gemini_free_project_id, var.gemini_paid_project_id]) : toset([])

  to = google_project_iam_member.gemini_tfc_apply_api_keys[each.key]
  id = "${each.key} roles/serviceusage.apiKeysAdmin serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_project_iam_custom_role.gemini_tfc_plan_budgets[0]
  id = "projects/${var.gemini_paid_project_id}/roles/horseGeminiBudgetReader"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_project_iam_member.gemini_tfc_plan_budgets[0]
  id = "${var.gemini_paid_project_id} projects/${var.gemini_paid_project_id}/roles/horseGeminiBudgetReader serviceAccount:horse-tfc-plan@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_project_iam_custom_role.gemini_tfc_apply_budgets[0]
  id = "projects/${var.gemini_paid_project_id}/roles/horseGeminiBudgetManager"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_project_iam_member.gemini_tfc_apply_budgets[0]
  id = "${var.gemini_paid_project_id} projects/${var.gemini_paid_project_id}/roles/horseGeminiBudgetManager serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_project_iam_member.gemini_tfc_apply_billing_project_manager[0]
  id = "${var.gemini_paid_project_id} roles/billing.projectManager serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_billing_account_iam_member.gemini_tfc_plan_billing_costs_manager[0]
  id = "${var.gemini_paid_billing_account_id} roles/billing.projectCostsManager serviceAccount:horse-tfc-plan@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}

import {
  for_each = var.gemini_gcp_enabled ? { gemini = true } : {}

  to = google_billing_account_iam_member.gemini_tfc_apply_billing_user[0]
  id = "${var.gemini_paid_billing_account_id} roles/billing.user serviceAccount:horse-tfc-apply@${var.gemini_free_project_id}.iam.gserviceaccount.com"
}
