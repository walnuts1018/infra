locals {
  tfc_organization_name = "walnuts-dev"
  tfc_project_name      = "*"
  tfc_workspace_name    = "*"
}

resource "aws_iam_openid_connect_provider" "tfc" {
  url             = "https://app.terraform.io"
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = ["06b25927c42a721631c1efd9431e648fa62e1e39"]
}

resource "aws_iam_role" "terraform_cloud_admin" {
  name = "terraform-cloud-admin"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::412381771768:oidc-provider/app.terraform.io"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "app.terraform.io:aud" : "aws.workload.identity"
          },
          "StringLike" : {
            "app.terraform.io:sub" : [
              "organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:${local.tfc_workspace_name}:run_phase:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_cloud_admin_policy" {
  role       = aws_iam_role.terraform_cloud_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
