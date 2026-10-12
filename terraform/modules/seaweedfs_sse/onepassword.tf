resource "random_id" "kek" {
  byte_length = 32

  lifecycle {
    prevent_destroy = true
  }
}

resource "onepassword_item" "sse" {
  vault    = var.vault
  title    = "seaweedfs-sse"
  category = "login"

  section_map = {
    terraform = {
      field_map = {
        "seaweedfs-sse-kek" = { type = "CONCEALED", value = sensitive(random_id.kek.hex) }
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
