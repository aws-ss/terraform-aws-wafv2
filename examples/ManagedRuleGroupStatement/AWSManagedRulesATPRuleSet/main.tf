provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../../..//"

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
        name        = "AWSManagedRulesATPRuleSet"
        vendor_name = "AWS"
        # Deprecated - excluded_rule = ["NoUserAgent_HEADER", "UserAgent_BadBots_HEADER"]

        managed_rule_group_configs = [
          {
            aws_managed_rules_atp_rule_set = {
              login_path           = "/web/login"
              enable_regex_in_path = false
              request_inspection = {
                # 'JSON' or 'FORM_ENCODED'
                payload_type = "FORM_ENCODED"
                username_field = {
                  identifier = "username"
                }
                password_field = {
                  identifier = "password"
                }
              }
            }
          }
        ]
        rule_action_override = [
          {
            name          = "AttributeCompromisedCredentials"
            action_to_use = "block"
          },
          {
            name          = "AttributeLongSession"
            action_to_use = "challenge"
          }
        ]

        scope_down_statement = {
          geo_match_statement = {
            country_codes : ["CN"]
            forwarded_ip_config = {
              fallback_behavior = "MATCH"
              header_name       = "X-Forwarded-For"
            }
          }
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesATPRuleSet"
        sampled_requests_enabled   = true
      }
    }
  ]

  challenge_config = 500
  captcha_config   = 500

  token_domains = ["test.com", "test1.com"]

  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
}