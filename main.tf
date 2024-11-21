# main.tf
data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region
}

module "codebuild" {
  source = "./modules/codebuild"

  project_name      = var.project_name
  repository_url    = var.repository_url
  region            = var.aws_region
  account_id        = var.aws_account_id
  ecr_repo_name     = var.ecr_repo_name
  buildspec_file    = var.buildspec_file
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}