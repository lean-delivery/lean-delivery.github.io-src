variable "tf_state_s3_bucket" {
  description = "Name of S3 bucket to store tfstate files"
  default     = ""
}

variable "tf_state_dynamodb_table" {
  description = "Name of DynamoDB table to store tfstate checksum and locking"
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  default     = "project"
}

variable "environment" {
  description = "environment name"
  default     = "env"
}