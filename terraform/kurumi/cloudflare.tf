module "cloudflare" {
  source               = "../modules/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
}

locals {
  account_id = "38b5eab012d216dfcc52dcd69e7764b5"
  zone_id    = "48b02398c8bc932f4d0b1dba83de196c"
}

import {
  to = module.cloudflare.cloudflare_account.walnuts1018
  id = local.account_id
}

import {
  to = module.cloudflare.cloudflare_zone.walnuts_dev
  id = local.zone_id
}

import {
  to = module.cloudflare.cloudflare_zone_dnssec.walnuts_dev
  id = local.zone_id
}

import {
  to = module.cloudflare.cloudflare_record.samba
  id = format("%s/%s", local.zone_id, "d115f6a6190de99c996d739c34d2a80d")
}

import {
  to = module.cloudflare.cloudflare_record.resend_mx
  id = format("%s/%s", local.zone_id, "8fece9f2d3a7f0070b77c2c3101c645d")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_3bcba7bd4b61fd21dbbf52d7164dd740
  id = format("%s/%s", local.zone_id, "3bcba7bd4b61fd21dbbf52d7164dd740")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_52809b82fc5e93f5d20192f93b74f884
  id = format("%s/%s", local.zone_id, "52809b82fc5e93f5d20192f93b74f884")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_7fcb19b7bea399e699d5f6af4fd265f7
  id = format("%s/%s", local.zone_id, "7fcb19b7bea399e699d5f6af4fd265f7")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_b3aa52624d17e28a78c729cd51533e1b
  id = format("%s/%s", local.zone_id, "b3aa52624d17e28a78c729cd51533e1b")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_cb6d40bd779430bc5c123e3c6120cacc
  id = format("%s/%s", local.zone_id, "cb6d40bd779430bc5c123e3c6120cacc")
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_a95a9a38f2f9db38790102b666d980b3
  id = format("%s/%s", local.zone_id, "a95a9a38f2f9db38790102b666d980b3")
}

import {
  to = module.cloudflare.cloudflare_ruleset.terraform_managed_resource_d3a7c2d6242d41068be770b71e25b365
  id = format("zone/%s/%s", local.zone_id, "d3a7c2d6242d41068be770b71e25b365")
}

import {
  to = module.cloudflare.cloudflare_ruleset.terraform_managed_resource_304092e7f9904942998f39441eb19203
  id = format("zone/%s/%s", local.zone_id, "304092e7f9904942998f39441eb19203")
}
