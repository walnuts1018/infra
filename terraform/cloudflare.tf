module "cloudflare" {
  source               = "./modules/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
}

locals {
  account_id = "38b5eab012d216dfcc52dcd69e7764b5"
  zone_id    = "48b02398c8bc932f4d0b1dba83de196c"
}


import {
  to = module.cloudflare.cloudflare_dns_record.kubeflow_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/e27a65fb1498030f44e9685ec9c66b5f"
}

import {
  to = module.cloudflare.cloudflare_dns_record.samba_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/d115f6a6190de99c996d739c34d2a80d"
}

import {
  to = module.cloudflare.cloudflare_dns_record.smtp_send_resend_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/8fece9f2d3a7f0070b77c2c3101c645d"
}

import {
  to = module.cloudflare.cloudflare_dns_record.route3_mx_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/fc9f15052628d57e43f8d64bd67e5981"
}

import {
  to = module.cloudflare.cloudflare_dns_record.route_2_mx_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/a56317241bd260245151536d56175805"
}

import {
  to = module.cloudflare.cloudflare_dns_record.route1_mx_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/f50389cf81daf9aef770e422af0f691c"
}

import {
  to = module.cloudflare.cloudflare_dns_record.dmarc
  id = "48b02398c8bc932f4d0b1dba83de196c/3bcba7bd4b61fd21dbbf52d7164dd740"
}

import {
  to = module.cloudflare.cloudflare_dns_record.resend_domainkey_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/52809b82fc5e93f5d20192f93b74f884"
}

import {
  to = module.cloudflare.cloudflare_dns_record.spf_send_resend_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/7fcb19b7bea399e699d5f6af4fd265f7"
}

import {
  to = module.cloudflare.cloudflare_dns_record.spf_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/b3aa52624d17e28a78c729cd51533e1b"
}

import {
  to = module.cloudflare.cloudflare_dns_record.google_site_verification_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/a95a9a38f2f9db38790102b666d980b3"
}

import {
  to = module.cloudflare.cloudflare_dns_record.keybase_site_verification_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/cb6d40bd779430bc5c123e3c6120cacc"
}

import {
  to = module.cloudflare.cloudflare_dns_record.blog_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/1d6aee56d3b2d2306a8678633717ae63"
}

import {
  to = module.cloudflare.cloudflare_dns_record.www_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/70eda40d54d15eabbfa3fb7471ce1c59"
}

import {
  to = module.cloudflare.cloudflare_dns_record.acme_challenge_kubeflow_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/96ed274b22ede46cb6ed81cc722fdd7a"
}

import {
  to = module.cloudflare.cloudflare_dns_record.visual_studio_marketplace_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/93a60abce88ab7907b93e4b89075a6a4"
}
