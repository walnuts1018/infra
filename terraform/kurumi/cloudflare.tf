module "cloudflare" {
  source             = "../modules/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
  zone_id = "48b02398c8bc932f4d0b1dba83de196c"
  account_id = "38b5eab012d216dfcc52dcd69e7764b5"
}

import {
  to = module.cloudflare.cloudflare_record.samba
  id = "48b02398c8bc932f4d0b1dba83de196c/d115f6a6190de99c996d739c34d2a80d"
}

import {
  to = module.cloudflare.cloudflare_record.resend_mx
  id = "48b02398c8bc932f4d0b1dba83de196c/8fece9f2d3a7f0070b77c2c3101c645d"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_3bcba7bd4b61fd21dbbf52d7164dd740
  id = "48b02398c8bc932f4d0b1dba83de196c/3bcba7bd4b61fd21dbbf52d7164dd740"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_52809b82fc5e93f5d20192f93b74f884
  id = "48b02398c8bc932f4d0b1dba83de196c/52809b82fc5e93f5d20192f93b74f884"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_7fcb19b7bea399e699d5f6af4fd265f7
  id = "48b02398c8bc932f4d0b1dba83de196c/7fcb19b7bea399e699d5f6af4fd265f7"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_b3aa52624d17e28a78c729cd51533e1b
  id = "48b02398c8bc932f4d0b1dba83de196c/b3aa52624d17e28a78c729cd51533e1b"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_cb6d40bd779430bc5c123e3c6120cacc
  id = "48b02398c8bc932f4d0b1dba83de196c/cb6d40bd779430bc5c123e3c6120cacc"
}

import {
  to = module.cloudflare.cloudflare_record.terraform_managed_resource_a95a9a38f2f9db38790102b666d980b3
  id = "48b02398c8bc932f4d0b1dba83de196c/a95a9a38f2f9db38790102b666d980b3"
}

import {
  to = module.cloudflare.cloudflare_zone.walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c"
}

import {
  to = module.cloudflare.cloudflare_ruleset.terraform_managed_resource_d3a7c2d6242d41068be770b71e25b365
  id = "zone/48b02398c8bc932f4d0b1dba83de196c/d3a7c2d6242d41068be770b71e25b365"
}

import {
  to = module.cloudflare.cloudflare_ruleset.terraform_managed_resource_304092e7f9904942998f39441eb19203
  id = "zone/48b02398c8bc932f4d0b1dba83de196c/304092e7f9904942998f39441eb19203"
}
