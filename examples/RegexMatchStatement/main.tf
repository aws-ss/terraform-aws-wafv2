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
  default_action = "allow"
  rule = [
    {
      name     = "APIVersionRegexRule"
      priority = 10
      action   = "block"
      regex_match_statement = {
        field_to_match = {
          uri_path = {}
        }
        regex_string = "^/api/v[0-9]+/.*"
        text_transformation = [
          {
            priority = 0
            type     = "LOWERCASE"
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "APIVersionRegexRule"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "JWTTokenRegexRule"
      priority = 20
      action   = "allow"
      regex_match_statement = {
        field_to_match = {
          single_header = {
            name = "authorization"
          }
        }
        regex_string = "^Bearer [A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+$"
        text_transformation = [
          {
            priority = 0
            type     = "NONE"
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "JWTTokenRegexRule"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "SQLInjectionRegexRule"
      priority = 30
      action   = "block"
      regex_match_statement = {
        field_to_match = {
          query_string = {}
        }
        regex_string = ".*(select|union|insert|delete|drop).*"
        text_transformation = [
          {
            priority = 0
            type     = "LOWERCASE"
          },
          {
            priority = 1
            type     = "URL_DECODE"
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "SQLInjectionRegexRule"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "EmailValidationRegexRule"
      priority = 40
      action   = "allow"
      regex_match_statement = {
        field_to_match = {
          single_query_argument = {
            name = "email"
          }
        }
        regex_string = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        text_transformation = [
          {
            priority = 0
            type     = "LOWERCASE"
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "EmailValidationRegexRule"
        sampled_requests_enabled   = true
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
