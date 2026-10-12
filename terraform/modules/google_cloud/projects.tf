resource "google_project" "gemini_free" {
  project_id      = local.free_project_id
  name            = "Horse Gemini Free"
  billing_account = ""
  deletion_policy = "PREVENT"
}

resource "google_project" "gemini_paid" {
  project_id      = local.paid_project_id
  name            = "Horse Gemini Paid"
  billing_account = local.billing_account_id
  deletion_policy = "PREVENT"
}
