resource "google_project" "existing" {
  project_id      = "walnuts-dev-498009"
  name            = "walnuts-dev"
  billing_account = ""
  deletion_policy = "PREVENT"
}

locals {
  owner_project_ids = {
    existing = google_project.existing.project_id
    free     = google_project.gemini_free.project_id
    paid     = google_project.gemini_paid.project_id
  }
}

resource "google_project_iam_member" "owner" {
  for_each = local.owner_project_ids

  project = each.value
  role    = "roles/owner"
  member  = "user:ryota.juglans@gmail.com"
}

resource "google_billing_account_iam_member" "billing_admin" {
  billing_account_id = local.billing_account_id
  role               = "roles/billing.admin"
  member             = "user:ryota.juglans@gmail.com"
}

resource "google_project_iam_member" "existing_terraform_cloud_plan_viewer" {
  project = google_project.existing.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.terraform_cloud_plan.email}"
}

resource "google_project_iam_member" "existing_terraform_cloud_apply_viewer" {
  project = google_project.existing.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.terraform_cloud_apply.email}"
}

resource "google_logging_project_bucket_config" "existing_default" {
  project          = "projects/${google_project.existing.project_id}"
  location         = "global"
  bucket_id        = "_Default"
  description      = "Default bucket"
  retention_days   = 30
  locked           = false
  enable_analytics = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_logging_project_sink" "existing_default" {
  project     = google_project.existing.project_id
  name        = "_Default"
  destination = "logging.googleapis.com/projects/walnuts-dev-498009/locations/global/buckets/_Default"
  filter      = "NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\")"
  disabled    = false
}

import {
  to = google_project.existing
  id = "walnuts-dev-498009"
}

import {
  for_each = local.owner_project_ids

  to = google_project_iam_member.owner[each.key]
  id = "${each.value} roles/owner user:ryota.juglans@gmail.com"
}

import {
  to = google_billing_account_iam_member.billing_admin
  id = "${local.billing_account_id} roles/billing.admin user:ryota.juglans@gmail.com"
}

import {
  to = google_project_iam_member.existing_terraform_cloud_plan_viewer

  id = "walnuts-dev-498009 roles/viewer serviceAccount:horse-tfc-plan@walnuts-horse-gemini-free.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_member.existing_terraform_cloud_apply_viewer

  id = "walnuts-dev-498009 roles/viewer serviceAccount:horse-tfc-apply@walnuts-horse-gemini-free.iam.gserviceaccount.com"
}

import {
  to = google_logging_project_bucket_config.existing_default
  id = "projects/walnuts-dev-498009/locations/global/buckets/_Default"
}

import {
  to = google_logging_project_sink.existing_default
  id = "projects/walnuts-dev-498009/sinks/_Default"
}
