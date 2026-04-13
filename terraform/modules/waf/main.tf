resource "aws_wafv2_web_acl" "main" {
  name        = "${var.env}-ticketing-waf"
  scope       = "CLOUDFRONT"
  description = "Ticketing system WAF"

  default_action {
    allow {}
  }

  # AWS 공통 보안 규칙
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env}-CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rate Limit (IP 기준)
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000   # ⚠️ 기존 100 → 너무 빡셈 (실서비스 터짐)
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env}-RateLimit"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection 방어
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.env}-SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.env}-TicketingWAF"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.env}-ticketing-waf"
    Environment = var.env
  }
}