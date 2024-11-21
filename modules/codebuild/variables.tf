# modules/codebuild/variables.tf
variable "project_name" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether images should be scanned on push"
  type        = bool
  default     = true
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}

variable "buildspec_file" {
  type    = string
  default = "buildspec.yml"
}

variable "auth_source_token" {
  description = "The GitHub personal access token"
  type        = string
  default     = "<>"
}

variable "server_type" {
    description = "The type of server to deploy, e.g. GITHUB, BITBUCKET, CODECOMMIT, GITHUB_ENTERPRISE...."
    type        = string
    default     = "<>"
}

variable "repository_source" {
    description = "The source of the repository, e.g. GITHUB, BITBUCKET, CODECOMMIT, GITHUB_ENTERPRISE...."
    type        = string
    default     = "<>"
}