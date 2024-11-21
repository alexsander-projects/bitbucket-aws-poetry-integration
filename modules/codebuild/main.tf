# modules/codebuild/main.tf

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "main" {
  name                 = var.ecr_repo_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}",
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = ["arn:aws:s3:::codepipeline-${var.region}-*"]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = ["arn:aws:codebuild:${var.region}:${var.account_id}:report-group/${var.project_name}-*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "arn:aws:ecr:${var.region}:${var.account_id}:repository/${var.ecr_repo_name}"
      }
    ]
  })
}


resource "aws_codebuild_project" "project" {
  name          = var.project_name
  description   = "Builds a Python app with Poetry managed dependencies and pushes to ECR"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}"
    }
  }

  source {
    type            = var.repository_source
    location        = var.repository_url
    git_clone_depth = 1
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
}

resource "aws_codebuild_source_credential" "source_credential" {
  # this one is for GitHub
  depends_on = [aws_codebuild_project.project]
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = var.server_type
  token       = var.auth_source_token
}

# resource "aws_codebuild_source_credential" "source_credential" {
#   # this one is for Bitbucket
#   depends_on = [aws_codebuild_project.project]
#   auth_type   = "PERSONAL_ACCESS_TOKEN"
#   server_type = var.server_type
#   token       = var.auth_source_token
#   user_name   = "test-user"
# }

resource "aws_codebuild_webhook" "example" {
  depends_on = [aws_codebuild_source_credential.source_credential]
  project_name = var.project_name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "^refs/tags/.*$"
    }
  }
}