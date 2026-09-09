resource "cloudflare_zone" "waln_uk" {
  name   = "waln.uk"
  paused = false
  type   = "full"
  account = {
    id   = cloudflare_account.walnuts1018.id
    name = "walnuts1018"
  }
}

resource "cloudflare_zone" "walnuts_dev" {
  name   = "walnuts.dev"
  paused = false
  type   = "full"
  account = {
    id   = cloudflare_account.walnuts1018.id
    name = "walnuts1018"
  }
}
