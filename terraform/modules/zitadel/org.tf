resource "zitadel_org" "ZITADEL" {
  name = "ZITADEL"
}

resource "zitadel_organization_domain" "walnuts_dev" {
  organization_id = zitadel_org.ZITADEL.id
  domain          = "walnuts.dev"
  validation_type = "DOMAIN_VALIDATION_TYPE_UNSPECIFIED"
}

resource "zitadel_organization_domain" "kmc_gr_jp" {
  organization_id = zitadel_org.ZITADEL.id
  domain          = "kmc.gr.jp"
  validation_type = "DOMAIN_VALIDATION_TYPE_UNSPECIFIED"
}

moved {
  from = zitadel_domain.walnuts_dev
  to   = zitadel_organization_domain.walnuts_dev
}

moved {
  from = zitadel_domain.kmc_gr_jp
  to   = zitadel_organization_domain.kmc_gr_jp
}

resource "zitadel_login_policy" "default" {
  org_id                        = zitadel_org.ZITADEL.id
  user_login                    = true
  allow_register                = true
  allow_external_idp            = true
  force_mfa                     = false
  force_mfa_local_only          = false
  hide_password_reset           = false
  ignore_unknown_usernames      = false
  default_redirect_uri          = ""
  password_check_lifetime       = "864000s"
  external_login_check_lifetime = "864000s"
  mfa_init_skip_lifetime        = "2592000s"
  second_factor_check_lifetime  = "64800s"
  multi_factor_check_lifetime   = "43200s"
  second_factors                = ["SECOND_FACTOR_TYPE_OTP", "SECOND_FACTOR_TYPE_U2F"]
  multi_factors                 = ["MULTI_FACTOR_TYPE_U2F_WITH_VERIFICATION"]
  passwordless_type             = "PASSWORDLESS_TYPE_ALLOWED"
  allow_domain_discovery        = true
  disable_login_with_email      = false
  disable_login_with_phone      = true
  idps = [
    zitadel_idp_google.google.id,
    # zitadel_org_idp_github.github.id,
  ]
}

resource "zitadel_password_complexity_policy" "default" {
  org_id        = zitadel_org.ZITADEL.id
  min_length    = 8
  has_uppercase = false
  has_lowercase = true
  has_number    = true
  has_symbol    = false
}

resource "zitadel_org_member" "zitadel_admin" {
  org_id  = zitadel_org.ZITADEL.id
  user_id = zitadel_human_user.zitadel_admin.id
  roles   = ["ORG_OWNER"]
}

resource "zitadel_org_member" "walnuts" {
  org_id  = zitadel_org.ZITADEL.id
  user_id = local.zitadel_human_user_ids.walnuts
  roles   = ["ORG_OWNER"]
}
