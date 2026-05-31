resource "zitadel_human_user" "zitadel_admin" {
  org_id             = zitadel_org.ZITADEL.id
  user_name          = "zitadel-admin@zitadel.auth.walnuts.dev"
  first_name         = "ZITADEL"
  last_name          = "Admin"
  display_name       = "ZITADEL Admin"
  preferred_language = "ja"
  email              = "zitadel-admin@zitadel.auth.walnuts.dev"
  is_email_verified  = true

  lifecycle {
    ignore_changes = [
      initial_password,
    ]
  }
}

resource "zitadel_human_user" "test" {
  org_id             = zitadel_org.ZITADEL.id
  user_name          = "test"
  first_name         = "test"
  last_name          = "test"
  display_name       = "test test"
  preferred_language = "und"
  email              = "test@walnuts.dev"
  is_email_verified  = true

  lifecycle {
    ignore_changes = [
      initial_password,
    ]
  }
}

locals {
  zitadel_human_user_ids = {
    walnuts      = "237477703714865517"
    latticeheart = "239374746813202867"
    rh_98        = "238838777223577993"
    tawara_ryota = "352141163228037441"
    junya        = "352145707823530837"
  }
}

resource "zitadel_machine_user" "terraform" {
  org_id            = zitadel_org.ZITADEL.id
  user_name         = "terraform"
  name              = "terraform"
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}

resource "zitadel_machine_user" "thermohygrometer_exporter" {
  org_id            = zitadel_org.ZITADEL.id
  user_name         = "thermohygrometer-exporter"
  name              = "thermohygrometer-exporter"
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}

resource "zitadel_machine_user" "kurumi" {
  org_id            = zitadel_org.ZITADEL.id
  user_name         = "kurumi"
  name              = "kurumi"
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
}

resource "zitadel_machine_key" "terraform" {
  org_id          = zitadel_org.ZITADEL.id
  user_id         = zitadel_machine_user.terraform.id
  key_type        = "KEY_TYPE_JSON"
  expiration_date = "9999-12-31T23:59:59Z"
}

resource "zitadel_machine_key" "thermohygrometer_exporter" {
  org_id          = zitadel_org.ZITADEL.id
  user_id         = zitadel_machine_user.thermohygrometer_exporter.id
  key_type        = "KEY_TYPE_JSON"
  expiration_date = "9999-12-31T23:59:59Z"
}

resource "zitadel_instance_member" "zitadel_admin" {
  user_id = zitadel_human_user.zitadel_admin.id
  roles   = ["IAM_OWNER"]
}

resource "zitadel_instance_member" "walnuts" {
  user_id = local.zitadel_human_user_ids.walnuts
  roles   = ["IAM_OWNER", "IAM_ORG_MANAGER", "IAM_USER_MANAGER", "IAM_OWNER_VIEWER"]
}

resource "zitadel_instance_member" "terraform" {
  user_id = zitadel_machine_user.terraform.id
  roles   = ["IAM_OWNER"]
}
