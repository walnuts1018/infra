resource "zitadel_action" "flat_roles" {
  org_id          = zitadel_org.ZITADEL.id
  name            = "flatRoles"
  script          = <<-EOT
function flatRoles(ctx, api) {
  if (ctx.v1.user.grants == undefined || ctx.v1.user.grants.count == 0) {
    return;
  }
  let grants = [];
  ctx.v1.user.grants.grants.forEach(claim => {
    claim.roles.forEach(role => {
        grants.push(claim.projectId+':'+role)  
    })
  })
  api.v1.claims.setClaim('my:zitadel:grants', grants)
}
  EOT
  timeout         = "10s"
  allowed_to_fail = true
}

resource "zitadel_action" "flat_minio_roles" {
  org_id          = zitadel_org.ZITADEL.id
  name            = "flatMinioRoles"
  script          = <<-EOT
function flatMinioRoles(ctx, api) {
  if (ctx.v1.user.grants == undefined || ctx.v1.user.grants.count == 0) {
    return;
  }
  let grants = [];
  ctx.v1.user.grants.grants.forEach((claim) => {
    claim.roles.forEach((role) => {
      role.startsWith("minio-") && grants.push(role.replace("minio-", ""));
    });
  });
  api.v1.claims.setClaim("minio-policy", grants);
}
  EOT
  timeout         = "10s"
  allowed_to_fail = true
}

resource "zitadel_trigger_actions" "pre_userinfo_creation" {
  org_id       = zitadel_org.ZITADEL.id
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
  action_ids = [
    zitadel_action.flat_roles.id,
    zitadel_action.flat_minio_roles.id,
  ]
}
