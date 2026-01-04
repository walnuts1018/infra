terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.29.0"
    }
  }
}

locals {
  tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaakxakb4chexzb2cw33aug5xi4xr4omrzgencimsubo4o5j4bc3nsq"
  user_ocid    = "ocid1.user.oc1..aaaaaaaajtuqlud2276rr2z63sqh35bah7jqp6k3kdjwjuug4vqrgncvfaya"

  region = "ap-osaka-1"
}

variable "private_key" {
  type      = string
  sensitive = true
}

variable "key_fingerprint" {
  type = string
}

provider "oci" {
  tenancy_ocid = local.tenancy_ocid
  user_ocid    = local.user_ocid
  private_key  = var.private_key
  fingerprint  = var.key_fingerprint
  region       = local.region
}
