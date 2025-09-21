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
        name        = "AWSManagedRulesAntiDDoSRuleSet"
        vendor_name = "AWS"
        # Deprecated - excluded_rule = ["NoUserAgent_HEADER", "UserAgent_BadBots_HEADER"]

        managed_rule_group_configs = [
          {
            aws_managed_rules_anti_ddos_rule_set = {
              sensitivity_to_block = "LOW"
              client_side_action_config = {
                challenge = {
                  exempt_uri_regular_expression = [
                    {
                      regex_string = "\\/api\\/|\\.(acc|avi|css|gif|ico|jpe?g|js|json|mp[34]|ogg|otf|pdf|png|tiff?|ttf|webm|webp|woff2?|xml)$"
                    },
                    {
                      regex_string = "\\/test\\/|\\.(acc|avi|css|gif|ico|jpe?g|js|json|mp[34]|ogg|otf|pdf|png|tiff?|ttf|webm|webp|woff2?|xml)$"
                    }
                  ]
                  usage_of_action = "DISABLED"
                  sensitivity     = "LOW"

                }
              }
            }
          }
        ]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesACFPRuleSet"
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