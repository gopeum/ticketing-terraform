variable "env" {
description = "배포 환경 (dev, prod)"
type        = string
}

variable "aws_region" {
description = "AWS 리전"
type        = string
}

variable "app_name" {
description = "애플리케이션 이름"
type        = string
}

# SSM 전환 전까지만 사용 (추후 제거 가능)

variable "db_password" {
description = "RDS 마스터 비밀번호 (SSM 전환 예정)"
type        = string
sensitive   = true
}

variable "key_name" {
description = "EC2 모니터링 서버 SSH 키페어 이름"
type        = string
}

variable "github_repo" {
description = "GitHub 리포지토리 (owner/repo)"
type        = string
}

variable "eks_cluster_name" {
description = "EKS 클러스터 이름"
type        = string
}

variable "alb_dns_name" {
description = "ALB DNS (초기엔 수동, 이후 자동화 가능)"
type        = string
default     = ""
}

variable "cognito_domain_prefix" {
description = "Cognito 호스티드 UI 도메인 접두사 (전역 유일)"
type        = string
}
