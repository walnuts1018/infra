resource "aws_identitystore_user" "walnuts" {
  identity_store_id = local.sso_instance_id

  display_name = "Walnuts"
  user_name    = "walnuts"

  name {
    given_name  = "Ryota"
    family_name = "Tawara"
  }

  emails {
    value   = "r.juglans.1018@gmail.com"
    primary = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ssoadmin_account_assignment" "walnuts" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_user.walnuts.user_id
  principal_type = "USER"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}
