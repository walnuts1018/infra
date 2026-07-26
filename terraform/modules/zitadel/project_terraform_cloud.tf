resource "zitadel_project" "terraform_cloud" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Terraform Cloud"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "terraform_cloud_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.terraform_cloud.id
  role_key     = "terraform_cloud_user"
  display_name = "Terraform Cloud User"
}

resource "zitadel_user_grant" "walnuts_terraform_cloud_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.terraform_cloud.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.terraform_cloud_user.role_key]
}

resource "zitadel_application_saml" "terraform_cloud_app" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.terraform_cloud.id
  name       = "Terraform Cloud"

  metadata_xml = <<-EOT
    <?xml version="1.0"?>
    <md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="https://app.terraform.io/sso/saml/samlconf-pHh5rrHntezixv1C3oDgRzMuGc8rmF/metadata">
        <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol urn:oasis:names:tc:SAML:1.1:protocol">
            <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
            <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://app.terraform.io/sso/saml/samlconf-pHh5rrHntezixv1C3oDgRzMuGc8rmF/acs" index="0"/>
        </md:SPSSODescriptor>
    </md:EntityDescriptor>
  EOT
}

output "terraform_cloud_saml_metadata_url" {
  value = "https://auth.walnuts.dev/saml/v2/metadata"
}
