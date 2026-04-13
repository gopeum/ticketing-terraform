output "cloudfront_domain" {
  description = "CloudFront 접속 도메인"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_id" {
  description = "CloudFront Distribution ID (캐시 무효화용)"
  value       = aws_cloudfront_distribution.main.id
}

output "frontend_bucket_id" {
  description = "S3 Bucket Name (프론트 업로드용)"
  value       = var.frontend_bucket_id
}

output "frontend_origin_domain" {
  description = "S3 Origin Domain"
  value       = var.frontend_domain
}