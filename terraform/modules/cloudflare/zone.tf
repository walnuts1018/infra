resource "cloudflare_zone" "walnuts_dev" {
  account_id = var.account_id
  paused     = false
  plan       = "free"
  type       = "full"
  zone       = "walnuts.dev"
}
