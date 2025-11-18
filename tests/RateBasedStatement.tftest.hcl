mock_provider "aws" {}

variables {
  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  resource_arn   = []
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
}

run "basic_rate_based_statement_forwarded_ip" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        rate_based_statement = {
          limit                 = 1000
          aggregate_key_type    = "FORWARDED_IP"
          evaluation_window_sec = 120
          forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Forwarded-For"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "cloudwatch_metric_name"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with rate based statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" && rule.priority == 10
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].rate_based_statement != null
    ])
    error_message = "Rate based statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 1000
    ])
    error_message = "Rate limit should be 1000"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "FORWARDED_IP"
    ])
    error_message = "Aggregate key type should be FORWARDED_IP"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].evaluation_window_sec == 120
    ])
    error_message = "Evaluation window should be 120 seconds"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].rate_based_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH"
    ])
    error_message = "Forwarded IP fallback behavior should be MATCH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].rate_based_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For"
    ])
    error_message = "Forwarded IP header should be X-Forwarded-For"
  }
}

run "rate_based_statement_constant_with_scope_down" {
  command = plan

  variables {
    name           = "WebACL02"
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "Rule02"
        priority = 5
        action   = "captcha"
        rate_based_statement = {
          limit                 = 100
          aggregate_key_type    = "CONSTANT"
          evaluation_window_sec = 300
          scope_down_statement = {
            geo_match_statement = {
              country_codes = ["CN"]
              forwarded_ip_config = {
                fallback_behavior = "MATCH"
                header_name       = "X-Forwarded-For"
              }
            }
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "rate_limit_china"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "CONSTANT"
    ])
    error_message = "Aggregate key type should be CONSTANT"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 100
    ])
    error_message = "Rate limit should be 100"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].evaluation_window_sec == 300
    ])
    error_message = "Evaluation window should be 300 seconds"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].scope_down_statement) > 0 &&
      rule.statement[0].rate_based_statement[0].scope_down_statement[0].geo_match_statement != null
    ])
    error_message = "Should have geo match scope down statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Rule action should be captcha"
  }
}

run "rate_based_statement_ip_aggregate_type" {
  command = plan

  variables {
    name           = "WebACL03"
    scope          = "REGIONAL"
    default_action = "allow"
    rule = [
      {
        name     = "Rule03"
        priority = 15
        action   = "count"
        rate_based_statement = {
          limit                 = 500
          aggregate_key_type    = "IP"
          evaluation_window_sec = 60
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "rate_limit_by_ip"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "IP"
    ])
    error_message = "Aggregate key type should be IP"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 500
    ])
    error_message = "Rate limit should be 500"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].evaluation_window_sec == 60
    ])
    error_message = "Evaluation window should be 60 seconds"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].forwarded_ip_config) == 0
    ])
    error_message = "Should not have forwarded IP config for IP aggregate type"
  }
}

run "rate_based_statement_custom_keys_simple" {
  command = plan

  variables {
    name           = "WebACL04"
    scope          = "REGIONAL"
    default_action = "allow"
    rule = [
      {
        name     = "Rule04"
        priority = 20
        action   = "block"
        rate_based_statement = {
          limit                 = 200
          aggregate_key_type    = "CUSTOM_KEYS"
          evaluation_window_sec = 120
          custom_key = [
            {
              header = {
                name = "User-Agent"
                text_transformation = [
                  {
                    priority = 10
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              forwarded_ip = {}
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "custom_key_rate_limit"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "CUSTOM_KEYS"
    ])
    error_message = "Aggregate key type should be CUSTOM_KEYS"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].custom_key) == 2
    ])
    error_message = "Should have 2 custom keys"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 200
    ])
    error_message = "Rate limit should be 200"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "Rule action should be block"
  }
}

run "rate_based_statement_multiple_rules_different_types" {
  command = plan

  variables {
    name           = "WebACL05"
    scope          = "REGIONAL"
    default_action = "allow"
    rule = [
      {
        name     = "RateLimit_IP"
        priority = 10
        action   = "block"
        rate_based_statement = {
          limit                 = 1000
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "rate_limit_by_ip"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RateLimit_ForwardedIP"
        priority = 20
        action   = "captcha"
        rate_based_statement = {
          limit                 = 500
          aggregate_key_type    = "FORWARDED_IP"
          evaluation_window_sec = 120
          forwarded_ip_config = {
            fallback_behavior = "NO_MATCH"
            header_name       = "CF-Connecting-IP"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "rate_limit_forwarded_ip"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have exactly 2 rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_IP" &&
      length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "First rule action should be block"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_ForwardedIP" &&
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Second rule action should be captcha"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_IP" &&
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "IP"
    ])
    error_message = "First rule should use IP aggregate type"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_ForwardedIP" &&
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].aggregate_key_type == "FORWARDED_IP"
    ])
    error_message = "Second rule should use FORWARDED_IP aggregate type"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_IP" &&
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 1000
    ])
    error_message = "First rule limit should be 1000"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimit_ForwardedIP" &&
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 500
    ])
    error_message = "Second rule limit should be 500"
  }
}

run "rate_based_statement_with_comprehensive_custom_keys" {
  command = plan

  variables {
    name           = "WebACL06"
    scope          = "REGIONAL"
    default_action = "block"
    rule = [
      {
        name     = "ComplexCustomKeyRule"
        priority = 5
        action   = "count"
        rate_based_statement = {
          limit                 = 150
          aggregate_key_type    = "CUSTOM_KEYS"
          evaluation_window_sec = 300
          custom_key = [
            {
              header = {
                name = "Authorization"
                text_transformation = [
                  {
                    priority = 1
                    type     = "NONE"
                  },
                  {
                    priority = 2
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              query_string = {
                text_transformation = [
                  {
                    priority = 1
                    type     = "URL_DECODE"
                  }
                ]
              }
            },
            {
              query_argument = {
                name = "api_key"
                text_transformation = [
                  {
                    priority = 1
                    type     = "NONE"
                  }
                ]
              }
            },
            {
              forwarded_ip = {}
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "complex_custom_keys"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      length(rule.statement[0].rate_based_statement[0].custom_key) == 4
    ])
    error_message = "Should have 4 custom keys (header, query_string, query_argument, forwarded_ip)"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].evaluation_window_sec == 300
    ])
    error_message = "Evaluation window should be 240 seconds"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].rate_based_statement != null &&
      rule.statement[0].rate_based_statement[0].limit == 150
    ])
    error_message = "Rate limit should be 150"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Rule action should be count"
  }
}