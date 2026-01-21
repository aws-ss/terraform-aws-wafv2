provider "aws" {
  region = "ap-northeast-2"
}

module "logging_configuration" {
  source = "../..//"

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = true
  log_destination_configs       = []
  redacted_fields = [
    {
      uri_path = {}
    },
    {
      method = {}
    },
    {
      single_header = {
        name = "authorization"
      }
    },
    {
      single_header = {
        name = "host"
      }
    },
  ]
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

  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "count"
      geo_match_statement = {
        country_codes : ["CN", "US"]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "Rule02"
      priority = 20
      action   = "block"
      geo_match_statement = {
        country_codes : ["AE"]
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