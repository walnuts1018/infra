output "gemini_free_api_key" {
  value     = google_apikeys_key.gemini_free.key_string
  sensitive = true
}

output "gemini_paid_api_key" {
  value     = google_apikeys_key.gemini_paid.key_string
  sensitive = true
}

output "gemini_free_project_id" { value = google_project.gemini_free.project_id }
output "gemini_paid_project_id" { value = google_project.gemini_paid.project_id }

output "terraform_cloud_workload_provider_name" {
  value = google_iam_workload_identity_pool_provider.terraform_cloud.name
}

output "terraform_cloud_plan_service_account_email" {
  value = google_service_account.terraform_cloud_plan.email
}

output "terraform_cloud_apply_service_account_email" {
  value = google_service_account.terraform_cloud_apply.email
}
