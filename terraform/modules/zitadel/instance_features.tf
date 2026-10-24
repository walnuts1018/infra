resource "zitadel_instance_features" "default" {
  login_v2 {
    required = true
    base_uri = "https://auth.walnuts.dev/ui/v2/login"
  }

  lifecycle {
    prevent_destroy = true
  }
}
