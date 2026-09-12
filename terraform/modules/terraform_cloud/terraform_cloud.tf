variable "seaweedfs_biscuit_terraform_access_key" {
  type      = string
  sensitive = true
}

variable "seaweedfs_biscuit_terraform_secret_key" {
  type      = string
  sensitive = true
}

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
    "terraform/*.tf",
    "terraform/modules/aws/**",
    "terraform/modules/b2/**",
    "terraform/modules/cloudflare/**",
    "terraform/modules/netbird/**",
    "terraform/modules/onepassword/**",
    "terraform/modules/terraform_cloud/**",
    "terraform/modules/zitadel/**",
  ]
  working_directory = "terraform"

  vcs_repo {
    github_app_installation_id = "ghain-otUXZF8BAGagh2Vn"
    identifier                 = "walnuts1018/infra"
    ingress_submodules         = false
  }
}

resource "tfe_workspace" "seaweedfs_default" {
  organization = tfe_organization.walnuts_dev.name
  project_id   = tfe_project.default.id
  name         = "seaweedfs-default"

  allow_destroy_plan            = true
  auto_apply                    = true
  auto_apply_run_trigger        = true
  file_triggers_enabled         = true
  queue_all_runs                = false
  speculative_enabled           = true
  structured_run_output_enabled = true
  terraform_version             = "~>1.15.0"
  trigger_patterns = [
    "terraform/workspaces/seaweedfs-default/**",
    "terraform/modules/seaweedfs-default/**",
    "k8s/apps/seaweedfs-default/_configs/desired-state.json",
  ]
  working_directory = "terraform/workspaces/seaweedfs-default"

  vcs_repo {
    github_app_installation_id = "ghain-otUXZF8BAGagh2Vn"
    identifier                 = "walnuts1018/infra"
    ingress_submodules         = false
  }
}

resource "tfe_workspace" "seaweedfs_biscuit" {
  organization = tfe_organization.walnuts_dev.name
  project_id   = tfe_project.default.id
  name         = "seaweedfs-biscuit"

  allow_destroy_plan            = true
  auto_apply                    = true
  auto_apply_run_trigger        = true
  file_triggers_enabled         = true
  queue_all_runs                = false
  speculative_enabled           = true
  structured_run_output_enabled = true
  terraform_version             = "~>1.15.0"
  trigger_patterns = [
    "terraform/workspaces/seaweedfs-biscuit/**",
    "terraform/modules/seaweedfs-biscuit/**",
  ]
  working_directory = "terraform/workspaces/seaweedfs-biscuit"

  vcs_repo {
    github_app_installation_id = "ghain-otUXZF8BAGagh2Vn"
    identifier                 = "walnuts1018/infra"
    ingress_submodules         = false
  }
}

resource "tfe_workspace_settings" "infra" {
  workspace_id        = tfe_workspace.infra.id
  execution_mode      = "remote"
  global_remote_state = false
}

resource "tfe_workspace_settings" "seaweedfs_default" {
  workspace_id        = tfe_workspace.seaweedfs_default.id
  execution_mode      = "agent"
  agent_pool_id       = tfe_agent_pool.home.id
  global_remote_state = false

  depends_on = [tfe_agent_pool_allowed_workspaces.home]
}

resource "tfe_workspace_settings" "seaweedfs_biscuit" {
  workspace_id        = tfe_workspace.seaweedfs_biscuit.id
  execution_mode      = "agent"
  agent_pool_id       = tfe_agent_pool.home.id
  global_remote_state = false

  depends_on = [tfe_agent_pool_allowed_workspaces.home]
}

resource "tfe_variable_set" "aws_iam" {
  organization = tfe_organization.walnuts_dev.name
  name         = "AWS IAM"
  description  = "AWS IAM credentials for the infra workspace"
  global       = false
  priority     = false
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
  description  = "SeaweedFS STS workload identity for the default workspace"
  global       = false
  priority     = false
}

resource "tfe_workspace_variable_set" "seaweedfs_sts" {
  workspace_id    = tfe_workspace.seaweedfs_default.id
  variable_set_id = tfe_variable_set.seaweedfs_sts.id
}

resource "tfe_variable" "seaweedfs_workload_identity_audience" {
  variable_set_id = tfe_variable_set.seaweedfs_sts.id
  key             = "TFC_WORKLOAD_IDENTITY_AUDIENCE_SEAWEEDFS"
  value           = "aws.workload.identity"
  category        = "env"
  hcl             = false
}

resource "tfe_variable" "seaweedfs_biscuit_terraform_access_key" {
  workspace_id = tfe_workspace.seaweedfs_biscuit.id
  key          = "seaweedfs_biscuit_terraform_access_key"
  value        = var.seaweedfs_biscuit_terraform_access_key
  category     = "terraform"
  hcl          = false
  sensitive    = true
}

resource "tfe_variable" "seaweedfs_biscuit_terraform_secret_key" {
  workspace_id = tfe_workspace.seaweedfs_biscuit.id
  key          = "seaweedfs_biscuit_terraform_secret_key"
  value        = var.seaweedfs_biscuit_terraform_secret_key
  category     = "terraform"
  hcl          = false
  sensitive    = true
}

resource "tfe_agent_pool" "home" {
  organization        = tfe_organization.walnuts_dev.name
  name                = "home"
  organization_scoped = false
}

resource "tfe_agent_pool_allowed_workspaces" "home" {
  agent_pool_id = tfe_agent_pool.home.id
  allowed_workspace_ids = [
    tfe_workspace.seaweedfs_default.id,
    tfe_workspace.seaweedfs_biscuit.id,
  ]
}

resource "tfe_agent_token" "home" {
  agent_pool_id = tfe_agent_pool.home.id
  description   = "berry Terraform Cloud Agent"
}

resource "tfe_run_trigger" "seaweedfs_default" {
  workspace_id  = tfe_workspace.seaweedfs_default.id
  sourceable_id = tfe_workspace.infra.id
}

resource "tfe_run_trigger" "seaweedfs_biscuit" {
  workspace_id  = tfe_workspace.seaweedfs_biscuit.id
  sourceable_id = tfe_workspace.infra.id
}

resource "tfe_workspace_run" "seaweedfs_default_initial" {
  workspace_id = tfe_workspace.seaweedfs_default.id

  apply {
    manual_confirm = false
    wait_for_run   = false
    message        = "Initial SeaweedFS default state migration run"
  }

  depends_on = [
    tfe_agent_pool_allowed_workspaces.home,
    tfe_agent_token.home,
    tfe_workspace_settings.seaweedfs_default,
    tfe_workspace_variable_set.seaweedfs_sts,
  ]
}

resource "tfe_workspace_run" "seaweedfs_biscuit_initial" {
  workspace_id = tfe_workspace.seaweedfs_biscuit.id

  apply {
    manual_confirm = false
    wait_for_run   = false
    message        = "Initial SeaweedFS biscuit state migration run"
  }

  depends_on = [
    tfe_variable.seaweedfs_biscuit_terraform_access_key,
    tfe_variable.seaweedfs_biscuit_terraform_secret_key,
    tfe_agent_pool_allowed_workspaces.home,
    tfe_agent_token.home,
    tfe_workspace_settings.seaweedfs_biscuit,
  ]
}
