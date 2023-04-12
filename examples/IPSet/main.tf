provider "aws" {
  region = "ap-northeast-2"
}

module "ipset01" {
  source = "../../modules/ip-set//"

  name               = "IPSet01"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = [
    "1.1.1.1/32"
  ]
  tags = {
    Team : "Security"
    Owner : "Security"
  }
}