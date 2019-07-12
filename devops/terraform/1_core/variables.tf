variable "namespace" {
  description = "Namespace (forming bucket name)"
  type        = "string"
}

variable "stage" {
  description = "Stage of environment (e.g. `dev` or `prod`) (forming bucket name)"
  type        = "string"
  default     = "dev"
}

variable "name" {
  description = "Name of static content (forming bucket name)"
  type        = "string"
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone to contain this record (or specify parent_zone_id)"
  type        = "string"
}

variable "domain" {
  description = "A domain name for which certificate will be created"
  type        = "string"
}

variable "alternative_domains" {
  description = "Domian name alternatives for ACM certificate"
  type        = "list"
  default     = []
}

variable "acm_tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "region" {
  description = "Namespace (forming bucket name)"
  type        = "string"
  default     = "eu-central-1"
}
