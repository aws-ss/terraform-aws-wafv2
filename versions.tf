terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
  }

  provider_meta "aws" {
    user_agent = ["github.com/aws-ss/terraform-aws-wafv2"]
  }
}
