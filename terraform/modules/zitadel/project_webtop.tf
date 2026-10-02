resource "zitadel_project" "webtop" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Webtop"
  project_role_check     = true
  project_role_assertion = true
}

resource "zitadel_project_role" "webtop_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.webtop.id
  role_key     = "webtop-user"
  display_name = "Webtop User"
}

resource "zitadel_application_oidc" "webtop" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.webtop.id
  name       = "webtop"

  redirect_uris               = ["https://desktop.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://desktop.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_webtop_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.webtop.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.webtop_user.role_key]
}

output "webtop_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.webtop.client_id)
}

output "webtop_oidc_client_secret" {
  value     = zitadel_application_oidc.webtop.client_secret
  sensitive = true
}

resource "zitadel_action" "webtop_role_claim" {
  org_id          = zitadel_org.ZITADEL.id
  name            = "webtopRoleClaim"
  script          = <<-EOT
function webtopRoleClaim(ctx, api) {
  if (ctx.v1.user.grants == undefined || ctx.v1.user.grants.count == 0) {
    return;
  }
  let roles = [];
  ctx.v1.user.grants.grants.forEach(grant => {
    if (grant.projectId === "${zitadel_project.webtop.id}") {
      grant.roles.forEach(role => roles.push(role));
    }
  });
  if (roles.length > 0) {
    api.v1.claims.setClaim("my:zitadel:webtop-roles", roles);
  }
}
  EOT
  timeout         = "10s"
  allowed_to_fail = true
}
