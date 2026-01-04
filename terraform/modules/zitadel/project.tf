resource "zitadel_project" "walnuts_dev" {
  name                   = "walnuts.dev"
  org_id                 = zitadel_org.ZITADEL.id
  project_role_assertion = true
}
