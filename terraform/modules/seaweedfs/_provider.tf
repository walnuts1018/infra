terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

data "external" "workload_identity_token" {
  program = ["sh", "-c", "printf '{\"token\":\"%s\"}' \"$TFC_WORKLOAD_IDENTITY_TOKEN_SEAWEEDFS\""]
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    s3  = "https://seaweedfs.walnuts.dev"
    sts = "https://seaweedfs.walnuts.dev"
  }

  assume_role_with_web_identity {
    # SeaweedFSのroleArn形式(arn:aws:iam::role/<name>)はaccount-idフィールドを完全に省略しているためAWS provider側のARN検証でエラーになる
    # account-idフィールドを空文字で明示したこちらの形式はSeaweedFS側でも有効なロールARNとして解釈されるので、こちらを使う
    role_arn           = "arn:aws:iam:::role/TerraformCloud"
    web_identity_token = data.external.workload_identity_token.result.token
    session_name       = "terraform-cloud"
  }
}
