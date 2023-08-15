provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../..//"

  enabled_web_acl_association = false
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "TEST"
  scope          = "REGIONAL"
  default_action = "allow"
  rule = [
    {
      name            = "RuleGroup01"
      priority        = 2
      override_action = "count"
      rule_group_reference_statement = {
        arn = ""
        rule_action_override = {
          name          = "Rule01"
          action_to_use = "count"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    },
    {
      name            = "RuleGroup02"
      priority        = 3
      override_action = "none"
      rule_group_reference_statement = {
        arn = ""
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