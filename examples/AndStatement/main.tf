provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../..//"

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "count"
      and_statement = {
        statements = [
          {
            not_statement = {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "CONTAINS"
                search_string         = "/admin"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            }
          },
          {
            byte_match_statement = {
              field_to_match = {
                uri_path = {}
              }
              positional_constraint = "CONTAINS"
              search_string         = "/administrator"
              text_transformation = [
                {
                  priority = 0
                  type     = "LOWERCASE"
                }
              ]
            }
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    }
  ]
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
  tags = {
    Team : "Security"
    Owner : "Security"
  }
}