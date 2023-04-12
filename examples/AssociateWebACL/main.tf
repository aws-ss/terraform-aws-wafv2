provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../../modules/web-acl-association//"

  resource_arn = ""
  web_acl_arn  = ""
}