output "cf_id" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_id}"
  description = "ID of AWS CloudFront distribution"
}

output "cf_arn" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_arn}"
  description = "ARN of AWS CloudFront distribution"
}

output "cf_status" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_status}"
  description = "Current status of the distribution"
}

output "cf_domain_name" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_domain_name}"
  description = "Domain name corresponding to the distribution"
}

output "cf_etag" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_etag}"
  description = "Current version of the distribution's information"
}

output "cf_hosted_zone_id" {
  value       = "${module.tf-module-aws-s3-cf-acm.cf_hosted_zone_id}"
  description = "CloudFront Route 53 zone ID"
}

output "s3_bucket" {
  value       = "${module.tf-module-aws-s3-cf-acm.s3_bucket}"
  description = "Name of S3 bucket"
}

output "s3_bucket_domain_name" {
  value       = "${module.tf-module-aws-s3-cf-acm.s3_bucket_domain_name}"
  description = "Domain of S3 bucket"
}
