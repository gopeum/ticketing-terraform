variable "env" {
  type = string
}

variable "app_name" {
  type    = string
  default = "ticketing"
}

variable "cognito_domain_prefix" {
  type = string
}

variable "callback_urls" {
  type    = list(string)
  default = []
}

variable "logout_urls" {
  type    = list(string)
  default = []
}

variable "aws_region" {
  type = string
}