resource "zitadel_project" "aws" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "AWS"
  project_role_assertion = false
}

resource "zitadel_application_saml" "aws_iam_identity_center" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.aws.id
  name       = "IAM Identity Center"

  metadata_xml = <<-EOT
    <?xml version="1.0" encoding="UTF-8"?><md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="https://ap-northeast-1.signin.aws.amazon.com/platform/saml/d-9567b34c60"><md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"><md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat><md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://ap-northeast-1.signin.aws.amazon.com/platform/saml/acs/4e52542de036a8ac-0bbb-4d87-a526-9cd6da8148bd" index="0" isDefault="true"/></md:SPSSODescriptor></md:EntityDescriptor>
  EOT
}
