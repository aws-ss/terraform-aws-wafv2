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
      name            = "Rule01"
      priority        = 10
      override_action = "count"
      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        # Deprecated - excluded_rule = ["NoUserAgent_HEADER", "UserAgent_BadBots_HEADER"]

        rule_action_override = [
          {
            name          = "NoUserAgent_HEADER"
            action_to_use = "captcha"
          },
          {
            name          = "UserAgent_BadBots_HEADER"
            action_to_use = "captcha"
          }
        ]

        scope_down_statement = {
          geo_match_statement = {
            country_codes : ["CN"]
          }
        }
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