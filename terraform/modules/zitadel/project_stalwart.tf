
resource "zitadel_project" "stalwart" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Stalwart"
  project_role_assertion = false
}
