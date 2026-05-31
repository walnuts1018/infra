resource "zitadel_project" "thermohygrometer" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "thermohygrometer"
  project_role_assertion = false
}

resource "zitadel_project_role" "thermohygrometer_read" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.thermohygrometer.id
  role_key     = "thermohygrometer.read"
  display_name = "Thermohygrometer Read"
}

resource "zitadel_user_grant" "thermohygrometer_exporter_grant" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.thermohygrometer.id
  user_id    = zitadel_machine_user.thermohygrometer_exporter.id
  role_keys  = ["thermohygrometer.read"]
}
