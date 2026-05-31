resource "zitadel_project" "terraform_cloud" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Terraform Cloud"
  project_role_assertion = true
}

resource "zitadel_application_saml" "terraform_cloud_app" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.terraform_cloud.id
  name       = "Terraform Cloud"

  metadata_xml = <<-EOT
    <?xml version="1.0"?>
    <md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="https://app.terraform.io/sso/saml/samlconf-pHh5rrHntezixv1C3oDgRzMuGc8rmF/metadata">
        <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol urn:oasis:names:tc:SAML:1.1:protocol">
            <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://app.terraform.io/sso/saml/samlconf-pHh5rrHntezixv1C3oDgRzMuGc8rmF/acs" index="0"/>
        </md:SPSSODescriptor>
    </md:EntityDescriptor>
  EOT
}
