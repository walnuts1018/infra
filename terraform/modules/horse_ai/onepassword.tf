resource "onepassword_item" "horse_ai" {
  vault    = var.vault
  title    = "horse-ai"
  category = "login"

  section_map = {
    terraform = {
      field_map = {
        "horse-gemini-free-api-key"    = { type = "CONCEALED", value = var.gemini_free_api_key }
        "horse-gemini-paid-api-key"    = { type = "CONCEALED", value = var.gemini_paid_api_key }
        "horse-gemini-free-project-id" = { type = "STRING", value = var.gemini_free_project_id }
        "horse-gemini-paid-project-id" = { type = "STRING", value = var.gemini_paid_project_id }
      }
    }
  }
}
