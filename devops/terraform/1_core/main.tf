terraform {
  required_version = "~> 0.11.10"

  backend "s3" {
    key = "core.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
  profile =  "ldi"
}

module "tf-module-aws-s3-cf-acm" {
  source = "github.com/lean-delivery/tf-module-aws-s3-cf-acm?ref=develop"

  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  name                         = "${var.name}"
  aliases                      = "${concat(list(var.domain), var.alternative_domains)}"
  parent_zone_name             = "${var.hosted_zone_name}"
  domain                       = "${var.domain}"
  alternative_domains          = "${var.alternative_domains}"
  acm_tags                     = "${var.acm_tags}"

}

