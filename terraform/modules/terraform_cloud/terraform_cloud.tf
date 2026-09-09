resource "tfe_organization" "walnuts_dev" {
  name  = "walnuts-dev"
  email = "r.juglans.1018@gmail.com"

  aggregated_commit_status_enabled                        = true
  allow_force_delete_workspaces                           = false
  assessments_enforced                                    = false
  max_ttl_enabled                                         = false
  send_passing_statuses_for_untriggered_speculative_plans = false
  speculative_plan_management_enabled                     = true
  stacks_enabled                                          = false
  user_tokens_enabled                                     = true
}

resource "tfe_project" "default" {
  organization = tfe_organization.walnuts_dev.name
  name         = "Default Project"
}

resource "tfe_organization_default_settings" "walnuts_dev" {
  organization           = tfe_organization.walnuts_dev.name
  default_execution_mode = "remote"
}

resource "tfe_workspace" "infra" {
  organization = tfe_organization.walnuts_dev.name
  project_id   = tfe_project.default.id
  name         = "infra"

  allow_destroy_plan            = true
  auto_apply                    = true
  auto_apply_run_trigger        = true
  file_triggers_enabled         = true
  queue_all_runs                = false
  speculative_enabled           = true
  structured_run_output_enabled = true
  terraform_version             = "~>1.15.0"
  trigger_patterns = [
    "k8s/apps/seaweedfs-default/_configs/desired-state.json",
    "terraform/*",
    "terraform/**/*",
  ]
  working_directory = "terraform"

  vcs_repo {
    github_app_installation_id = "ghain-otUXZF8BAGagh2Vn"
    identifier                 = "walnuts1018/infra"
    ingress_submodules         = false
  }
}

resource "tfe_workspace_settings" "infra" {
  workspace_id        = tfe_workspace.infra.id
  global_remote_state = false
}

resource "tfe_variable_set" "aws_iam" {
  organization = tfe_organization.walnuts_dev.name
  name         = "AWS IAM"
  description  = ""
  global       = false
  priority     = false
}

resource "tfe_project_variable_set" "aws_iam" {
  project_id      = tfe_project.default.id
  variable_set_id = tfe_variable_set.aws_iam.id
}

resource "tfe_workspace_variable_set" "aws_iam" {
  workspace_id    = tfe_workspace.infra.id
  variable_set_id = tfe_variable_set.aws_iam.id
}

resource "tfe_variable" "aws_provider_auth" {
  variable_set_id = tfe_variable_set.aws_iam.id
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  hcl             = false
}

resource "tfe_variable" "aws_run_role_arn" {
  variable_set_id = tfe_variable_set.aws_iam.id
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = "arn:aws:iam::412381771768:role/terraform-cloud-admin"
  category        = "env"
  hcl             = false
}

resource "tfe_variable_set" "seaweedfs_sts" {
  organization = tfe_organization.walnuts_dev.name
  name         = "SeaweedFS STS"
  description  = ""
  global       = false
  priority     = false
}

resource "tfe_project_variable_set" "seaweedfs_sts" {
  project_id      = tfe_project.default.id
  variable_set_id = tfe_variable_set.seaweedfs_sts.id
}

resource "tfe_workspace_variable_set" "seaweedfs_sts" {
  workspace_id    = tfe_workspace.infra.id
  variable_set_id = tfe_variable_set.seaweedfs_sts.id
}

resource "tfe_variable" "seaweedfs_workload_identity_audience" {
  variable_set_id = tfe_variable_set.seaweedfs_sts.id
  key             = "TFC_WORKLOAD_IDENTITY_AUDIENCE_SEAWEEDFS"
  value           = "aws.workload.identity"
  category        = "env"
  hcl             = false
}
