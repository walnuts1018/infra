module "cloudflare" {
  source               = "./modules/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
}

import {
  to = module.cloudflare.cloudflare_dns_record.mx_cloudflare_3_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/f265f6b3bcbe7f0319a0b3b3eb03bb47"
}

import {
  to = module.cloudflare.cloudflare_dns_record.mx_cloudflare_2_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/6a1aef6e258a14d39c41740bd575bc43"
}

import {
  to = module.cloudflare.cloudflare_dns_record.mx_cloudflare_1_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/385d2ba2314932bd2eb9cbcb72743d43"
}

import {
  to = module.cloudflare.cloudflare_dns_record.dkim_cloudflare_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/3812890a5cc438d1a81e46f68ad7385e"
}

import {
  to = module.cloudflare.cloudflare_dns_record.spf_walnuts_dev
  id = "48b02398c8bc932f4d0b1dba83de196c/4a534f32d60a2508051e16684293119b"
}
