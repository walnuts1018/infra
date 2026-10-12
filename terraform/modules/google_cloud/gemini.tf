resource "google_project_service" "gemini_free_api" {
  project            = google_project.gemini_free.project_id
  service            = "generativelanguage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_apikeys_api" {
  project            = google_project.gemini_free.project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_iam_api" {
  project            = google_project.gemini_free.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_sts_api" {
  project            = google_project.gemini_free.project_id
  service            = "sts.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_free_iamcredentials_api" {
  project            = google_project.gemini_free.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_api" {
  project            = google_project.gemini_paid.project_id
  service            = "generativelanguage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_apikeys_api" {
  project            = google_project.gemini_paid.project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gemini_paid_budgets_api" {
  project            = google_project.gemini_paid.project_id
  service            = "billingbudgets.googleapis.com"
  disable_on_destroy = false
}

resource "google_apikeys_key" "gemini_free" {
  name         = "horse-gemini-free"
  display_name = "Horse Gemini free project"
  project      = google_project.gemini_free.project_id

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
  name         = "horse-gemini-paid"
  display_name = "Horse Gemini paid project"
  project      = google_project.gemini_paid.project_id

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
    projects             = ["projects/${google_project.gemini_paid.number}"]
    services             = ["services/AEFD-7695-64FA"]
    calendarPeriod       = "MONTH"
    creditTypesTreatment = "EXCLUDE_ALL_CREDITS"
  }

  gemini_paid_spend_cap_notifications = {
    enableProjectLevelRecipients = true
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

}

resource "restapi_object" "gemini_paid_spend_cap" {
  path           = "/v1/billingAccounts/${local.billing_account_id}/budgets"
  create_path    = "/v1/billingAccounts/${local.billing_account_id}/budgets"
  read_path      = "/v1/{id}"
  update_path    = "/v1/{id}?updateMask=displayName,amount,thresholdRules,notificationsRule,spendCap"
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

  depends_on = [google_project.gemini_paid, google_project_service.gemini_paid_budgets_api]
}

removed {
  from = restapi_object.gemini_paid_300_alert

  lifecycle {
    destroy = false
  }
}
