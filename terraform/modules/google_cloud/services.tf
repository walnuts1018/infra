locals {
  service_project_ids = {
    existing    = google_project.existing.project_id
    gemini_free = google_project.gemini_free.project_id
    gemini_paid = google_project.gemini_paid.project_id
  }

  common_enabled_services = toset([
    "analyticshub.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudtrace.googleapis.com",
    "dataform.googleapis.com",
    "dataplex.googleapis.com",
    "datastore.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "telemetry.googleapis.com",
  ])

  project_enabled_services = {
    existing = local.common_enabled_services
    gemini_free = toset([
      "apptopology.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "serviceusage.googleapis.com",
    ])
    gemini_paid = toset([
      "apptopology.googleapis.com",
      "serviceusage.googleapis.com",
    ])
  }

  current_project_services = {
    for service in flatten([
      for project_key, project_id in local.service_project_ids : [
        for api in local.project_enabled_services[project_key] : {
          key     = "${project_key}/${api}"
          project = project_id
          service = api
        }
      ]
    ]) : service.key => service
  }
}

resource "google_project_service" "currently_enabled" {
  for_each = local.current_project_services

  project            = each.value.project
  service            = each.value.service
  disable_on_destroy = true
}

import {
  for_each = local.current_project_services

  to = google_project_service.currently_enabled[each.key]
  id = "${each.value.project}/${each.value.service}"
}

import {
  to = google_project_service.gemini_free_iam_api
  id = "walnuts-horse-gemini-free/iam.googleapis.com"
}

import {
  to = google_project_service.gemini_free_iamcredentials_api
  id = "walnuts-horse-gemini-free/iamcredentials.googleapis.com"
}

import {
  to = google_project_service.gemini_free_sts_api
  id = "walnuts-horse-gemini-free/sts.googleapis.com"
}
