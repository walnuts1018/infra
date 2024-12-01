resource "cloudflare_zone" "walnuts_dev" {
  account_id = cloudflare_account.walnuts1018.id
  paused     = false
  plan       = "free"
  type       = "full"
  zone       = "walnuts.dev"
}
