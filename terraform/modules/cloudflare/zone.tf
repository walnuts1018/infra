resource "cloudflare_zone" "waln_uk" {
  name   = "waln.uk"
  paused = false
  type   = "full"
  account = {
    id   = "38b5eab012d216dfcc52dcd69e7764b5"
    name = "walnuts1018"
  }
}

resource "cloudflare_zone" "walnuts_dev" {
  name   = "walnuts.dev"
  paused = false
  type   = "full"
  account = {
    id   = "38b5eab012d216dfcc52dcd69e7764b5"
    name = "walnuts1018"
  }
}

