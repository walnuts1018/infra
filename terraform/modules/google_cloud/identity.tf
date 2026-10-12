resource "google_iam_workload_identity_pool" "terraform_cloud" {
  project                   = google_project.gemini_free.project_id
  workload_identity_pool_id = "horse-tfc"
  display_name              = "Horse HCP Terraform"
  description               = "HCP Terraform infra workspace plan/apply identity pool"
  disabled                  = false

  depends_on = [
    google_project_service.gemini_free_iam_api,
    google_project_service.gemini_free_sts_api,
  ]
}

resource "google_iam_workload_identity_pool_provider" "terraform_cloud" {
  project                            = google_project.gemini_free.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.terraform_cloud.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud"
  display_name                       = "HCP Terraform infra workspace"

  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.tfc_org"             = "assertion.terraform_organization_name"
    "attribute.tfc_project"         = "assertion.terraform_project_name"
    "attribute.tfc_workspace_id"    = "assertion.terraform_workspace_id"
    "attribute.tfc_workspace_phase" = "assertion.terraform_workspace_id + ':' + assertion.terraform_run_phase"
  }

  attribute_condition = "assertion.terraform_organization_name == 'walnuts-dev' && assertion.terraform_project_name == 'Default Project' && assertion.terraform_workspace_name == 'infra' && assertion.terraform_workspace_id == 'ws-feVzA68c4v9PiFDK' && assertion.terraform_run_phase in ['plan', 'apply'] && assertion.aud == '//iam.googleapis.com/projects/${google_project.gemini_free.number}/locations/global/workloadIdentityPools/horse-tfc/providers/terraform-cloud'"

  oidc {
    issuer_uri = "https://app.terraform.io"
  }

  depends_on = [google_iam_workload_identity_pool.terraform_cloud]
}

resource "google_service_account" "terraform_cloud_plan" {
  project      = google_project.gemini_free.project_id
  account_id   = "horse-tfc-plan"
  display_name = "Horse Terraform plan"
  description  = "Read-only Google Cloud access for the HCP Terraform infra workspace plan phase"

  depends_on = [google_project_service.gemini_free_iam_api]
}

resource "google_service_account" "terraform_cloud_apply" {
  project      = google_project.gemini_free.project_id
  account_id   = "horse-tfc-apply"
  display_name = "Horse Terraform apply"
  description  = "Project-scoped Google Cloud access for the HCP Terraform infra workspace apply phase"

  depends_on = [google_project_service.gemini_free_iam_api]
}

resource "google_service_account_iam_member" "terraform_cloud_plan" {
  service_account_id = google_service_account.terraform_cloud_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform_cloud.name}/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:plan"
}

resource "google_service_account_iam_member" "terraform_cloud_apply" {
  service_account_id = google_service_account.terraform_cloud_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform_cloud.name}/attribute.tfc_workspace_phase/ws-feVzA68c4v9PiFDK:apply"
}

resource "google_project_iam_member" "terraform_cloud_plan_viewer" {
  for_each = toset([local.free_project_id, local.paid_project_id])

  project = each.value
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.terraform_cloud_plan.email}"
}

resource "google_project_iam_member" "terraform_cloud_apply_viewer" {
  for_each = toset([local.free_project_id, local.paid_project_id])

  project = each.value
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_billing_account_iam_member" "terraform_cloud_plan_billing_costs_manager" {
  billing_account_id = local.billing_account_id
  role               = "roles/billing.projectCostsManager"
  member             = "serviceAccount:${google_service_account.terraform_cloud_plan.email}"
}

resource "google_project_iam_member" "terraform_cloud_apply_service_usage" {
  for_each = toset([local.free_project_id, local.paid_project_id])

  project = each.value
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_project_iam_member" "terraform_cloud_apply_api_keys" {
  for_each = toset([local.free_project_id, local.paid_project_id])

  project = each.value
  role    = "roles/serviceusage.apiKeysAdmin"
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_project_iam_custom_role" "terraform_cloud_apply_budgets" {
  project     = google_project.gemini_paid.project_id
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

resource "google_project_iam_custom_role" "terraform_cloud_plan_budgets" {
  project     = google_project.gemini_paid.project_id
  role_id     = "horseGeminiBudgetReader"
  title       = "Horse Gemini project budget reader"
  description = "Read budgets and spend caps scoped to the Horse Gemini paid project"
  permissions = [
    "billing.resourcebudgets.read",
    "billing.resourceCosts.get",
    "resourcemanager.projects.get",
    "serviceusage.services.use",
  ]
}

resource "google_project_iam_member" "terraform_cloud_plan_budgets" {
  project = google_project.gemini_paid.project_id
  role    = google_project_iam_custom_role.terraform_cloud_plan_budgets.name
  member  = "serviceAccount:${google_service_account.terraform_cloud_plan.email}"
}

resource "google_project_iam_member" "terraform_cloud_apply_budgets" {
  project = google_project.gemini_paid.project_id
  role    = google_project_iam_custom_role.terraform_cloud_apply_budgets.name
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_project_iam_member" "terraform_cloud_apply_billing_project_manager" {
  project = google_project.gemini_paid.project_id
  role    = "roles/billing.projectManager"
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_billing_account_iam_member" "terraform_cloud_apply_billing_user" {
  billing_account_id = local.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}
