# variables.tf
variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "<>"
}

variable "project_name" {
  description = "The name of the CodeBuild project"
  type        = string
  default     = "<>"
}

variable "repository_url" {
  description = "The URL of the repository"
  type        = string
}

variable "repository_source" {
  description = "The source of the repository, e.g. GITHUB, BITBUCKET, CODECOMMIT, GITHUB_ENTERPRISE...."
  type        = string
  default     = "<>"
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "<>"
}

variable "buildspec_file" {
  description = "The path to the buildspec file"
  type        = string
  default     = "buildspec.yml"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "<>"
}

