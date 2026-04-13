variable "env" {
  type = string
}

variable "frontend_bucket_id" {
  type = string
}

variable "frontend_bucket_arn" {
  type = string
}

variable "frontend_domain" {
  type = string
}

variable "waf_acl_arn" {
  type = string
}

variable "alb_dns_name" {
  description = "ALB DNS name (없으면 API origin 생성 안함)"
  type        = string
  default     = ""
}