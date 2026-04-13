# ECR (멀티 서비스 대응)

locals {
ecr_repos = [
"event-svc",
"reserv-svc",
"worker-svc",
"frontend"
]
}

resource "aws_ecr_repository" "repos" {
for_each = toset(local.ecr_repos)

name                 = "ticketing/${each.key}"
image_tag_mutability = "MUTABLE"
force_delete         = true

image_scanning_configuration {
scan_on_push = true
}

tags = {
Name        = "ecr-${each.key}"
Environment = var.env
}
}

# AWS Account 정보

data "aws_caller_identity" "current" {}

# GitHub OIDC Provider (이미 있으면 data로 가져옴)

data "aws_iam_openid_connect_provider" "github" {
url = "https://token.actions.githubusercontent.com"
}

# GitHub Actions IAM Role

resource "aws_iam_role" "github_actions" {
name = "ticketing-${var.env}-github-actions-role"

assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [{
Effect = "Allow"
Principal = {
Federated = data.aws_iam_openid_connect_provider.github.arn
}
Action = "sts:AssumeRoleWithWebIdentity"
Condition = {
StringLike = {
"token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
}
StringEquals = {
"token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
}
}
}]
})
}

# GitHub Actions Policy (확장형)

resource "aws_iam_role_policy" "github_actions" {
name = "github-actions-policy"
role = aws_iam_role.github_actions.id

policy = jsonencode({
Version = "2012-10-17"
Statement = [

  # ECR Push
  {
    Effect = "Allow"
    Action = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    Resource = "*"
  },

  # SSM (추후 사용 대비)
  {
    Effect = "Allow"
    Action = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    Resource = "*"
  },

  # CloudFront (프론트 배포용)
  {
    Effect = "Allow"
    Action = [
      "cloudfront:CreateInvalidation"
    ]
    Resource = "*"
  }
]

})
}
