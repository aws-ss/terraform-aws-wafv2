provider "aws" {
  region = "ap-northeast-2"
}

module "rule_group" {
  source = "../../modules/rule-group//"

  name     = "RuleGroup01"
  scope    = "REGIONAL"
  capacity = 100
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "block"
      size_constraint_statement = {
        field_to_match = {
          single_header = {
            name = "host"
          }
        }
        comparison_operator = "EQ"
        size                = 0
        text_transformation = [
          {
            priority = 20
            type     = "NONE"
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
    Team  = "Security"
    Owner = "Security"
  }
}