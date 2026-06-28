resource "zitadel_project" "minio_biscuit" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "MinIO biscuit"
  project_role_assertion = true
}

resource "zitadel_project_role" "minio_biscuit_console_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.minio_biscuit.id
  role_key     = "minio-consoleAdmin"
  display_name = "MinIO Console Admin"
}

resource "zitadel_user_grant" "walnuts_minio_biscuit_console_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.minio_biscuit.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.minio_biscuit_console_admin.role_key]
}
