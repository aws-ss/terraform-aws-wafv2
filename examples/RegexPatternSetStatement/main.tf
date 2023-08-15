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
      action   = "block"
      regex_pattern_set_reference_statement = {
        field_to_match = {
          single_header = {
            name = "user-agent"
          }
        }
        arn = "arn:aws:wafv2:ap-northeast-2:362252864672:regional/regexpatternset/test/8356a9ba-8236-459d-8684-3b5a01091cb7"
        text_transformation = [
          {
            priority = 10
            type     = "LOWERCASE"
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