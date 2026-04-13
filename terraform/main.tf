terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "ticketing-tfstate-prod-302174038725"
    key    = "prod/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform-lock" #동시 실행 방지
    encrypt = true #동시 실행 방지
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
     tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "network" {
  source           = "./modules/network"
  env              = var.env
  aws_region       = var.aws_region
  eks_cluster_name = var.eks_cluster_name
}

module "s3" {
  source      = "./modules/s3"
  env         = var.env
  aws_account = data.aws_caller_identity.current.account_id
}

module "waf" {
  source = "./modules/waf"
  env    = var.env

  providers = {
    aws = aws.us_east_1
  }
}

module "cloudfront" {
  source               = "./modules/cloudfront"
  env                  = var.env
  frontend_bucket_id   = module.s3.frontend_bucket_id
  frontend_bucket_arn  = module.s3.frontend_bucket_arn
  frontend_domain      = module.s3.frontend_bucket_regional_domain
  waf_acl_arn          = module.waf.waf_acl_arn
  alb_dns_name         = var.alb_dns_name

  depends_on = [module.waf]
}

module "cognito" {
  source                = "./modules/cognito"
  env                   = var.env
  app_name              = var.app_name
  cognito_domain_prefix = var.cognito_domain_prefix
  aws_region            = var.aws_region

  callback_urls = module.cloudfront.cloudfront_domain != "" ? [
    "https://${module.cloudfront.cloudfront_domain}/callback"
  ] : []

  logout_urls = module.cloudfront.cloudfront_domain != "" ? [
    "https://${module.cloudfront.cloudfront_domain}/logout"
  ] : []
}

module "sqs" {
  source = "./modules/sqs"
  env    = var.env
}

module "elasticache" {
  source            = "./modules/elasticache"
  env               = var.env
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = module.network.redis_sg_id

  depends_on = [module.network]
}

module "rds" {
  source            = "./modules/rds"
  env               = var.env
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = module.network.rds_sg_id
  db_password       = var.db_password

  depends_on = [module.network]
}

module "eks" {
  source            = "./modules/eks"
  env               = var.env
  aws_region        = var.aws_region
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.eks_sg_id
  cluster_name      = var.eks_cluster_name

  depends_on = [module.network]
}

module "monitoring" {
  source            = "./modules/monitoring"
  env               = var.env
  subnet_id         = module.network.public_subnet_ids[0]
  security_group_id = module.network.monitoring_sg_id
  key_name          = var.key_name

  depends_on = [module.network]
}

module "cicd" {
  source          = "./modules/cicd"
  env             = var.env
  aws_region      = var.aws_region
  github_repo     = var.github_repo
}