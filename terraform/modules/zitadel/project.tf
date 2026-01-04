resource "zitadel_project" "default" {
  name                   = "walnuts.dev"
  org_id                 = zitadel_org.ZITADEL.id
  project_role_assertion = true
}
