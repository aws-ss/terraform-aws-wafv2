provider "aws" {
  region = "ap-northeast-2"
}

module "logging_configuration" {
  source = "../../modules/logging-configuration//"

  log_destination_configs = ""
  resource_arn            = ""
  redacted_fields = {
    uri_path = {}
  }
  logging_filter = {
    default_behavior = "DROP"
    filter = [
      {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        condition = [
          {
            action_condition = { action = "ALLOW" }
          },
          {
            action_condition = { action = "BLOCK" }
          }
        ]
      },
      {
        behavior    = "DROP"
        requirement = "MEETS_ALL"
        condition = [
          {
            action_condition = { action = "ALLOW" }
          }
        ]
      }
    ]
  }
}