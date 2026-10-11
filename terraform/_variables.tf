variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "b2_application_key" {
  type      = string
  sensitive = true
}

variable "zitadel_jwt_profile_json" {
  type      = string
  sensitive = true
}

variable "oci_private_key" {
  type      = string
  sensitive = true
}

variable "zitadel_google_idp_client_secret" {
  type        = string
  sensitive   = true
  description = "Google IDP OAuth2 Client Secret for ZITADEL"
}

// https://netbird.walnuts.dev/team/user?id=418e3381-31bb-4f63-be81-43d00fc69532&service_user=true で作る
// TODO: netbirdのPATは30〜365日で期限切れになるので困ってる
variable "netbird_management_token" {
  type        = string
  sensitive   = true
  description = "NetBird Management API admin PAT used by Terraform"
}

variable "onepassword_vault" {
  type        = string
  description = "UUID of the 1Password vault that External Secrets reads from"
}

variable "onepassword_service_account_token" {
  type        = string
  sensitive   = true
  description = "1Password service account token with access to the External Secrets vault"
}

variable "gemini_gcp_enabled" {
  type        = bool
  default     = false
  description = "Set true only after Google Cloud billing and Terraform authentication prerequisites are reviewed"
}

variable "gemini_free_project_id" {
  type        = string
  default     = "walnuts-horse-gemini-free"
  description = "New Google Cloud project ID for Gemini free-tier requests"
}

variable "gemini_free_project_number" {
  type        = string
  default     = "471988777845"
  description = "Project number of the imported Horse Gemini free project"
}

variable "gemini_paid_project_id" {
  type        = string
  default     = "walnuts-horse-gemini-paid"
  description = "New Google Cloud project ID for paid Gemini requests"
}

variable "gemini_paid_project_number" {
  type        = string
  default     = "912318903625"
  description = "Project number of the imported Horse Gemini paid project"
}

variable "gemini_paid_billing_account_id" {
  type        = string
  default     = ""
  description = "Cloud Billing account ID linked to the paid Gemini project"
}

variable "gemini_organization_id" {
  type        = string
  default     = ""
  description = "Optional Google Cloud organization ID; leave empty for a standalone project"
}

# variable "zitadel_github_idp_client_secret" {
#   type        = string
#   sensitive   = true
#   description = "GitHub IDP OAuth2 Client Secret for ZITADEL"
# }
