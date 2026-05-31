
resource "zitadel_project" "aerial" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "aerial"
  project_role_assertion = false
}

resource "zitadel_application_api" "aerial_api_server" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.aerial.id
  name       = "API Server"

  auth_method_type = "API_AUTH_METHOD_TYPE_PRIVATE_KEY_JWT"
}
