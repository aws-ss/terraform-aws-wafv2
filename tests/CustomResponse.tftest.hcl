mock_provider "aws" {}

variables {
  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
  rule                          = []
  enabled_web_acl_association   = true
  resource_arn                  = []
  enabled_logging_configuration = false
  tags = {
    Team  = "Security"
    Owner = "Security"
  }
}

run "test_custom_response_body_creation" {
  command = plan

  variables {
    custom_response_body = [
      {
        key          = "CustomResponseBody1"
        content      = "Not authorized1"
        content_type = "TEXT_PLAIN"
      },
      {
        key          = "CustomResponseBody2"
        content      = "Not authorized2"
        content_type = "TEXT_PLAIN"
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.custom_response_body) == 2
    error_message = "Should have two custom response bodies"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.key == "CustomResponseBody1" && body.content_type == "TEXT_PLAIN"
    ])
    error_message = "Should have CustomResponseBody1 custom response body with TEXT_PLAIN content type"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.key == "CustomResponseBody2" && body.content_type == "TEXT_PLAIN"
    ])
    error_message = "Should have CustomResponseBody2 custom response body with TEXT_PLAIN content type"
  }
}

run "test_rule_with_custom_response" {
  command = plan

  variables {
    custom_response_body = [
      {
        key          = "CustomResponseBody1"
        content      = "Not authorized1"
        content_type = "TEXT_PLAIN"
      }
    ]
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        custom_response = {
          response_code = 404
          response_header = [
            {
              name  = "X-Custom-Response-Header01"
              value = "Not authorized"
            },
            {
              name  = "X-Custom-Response-Header02"
              value = "Not authorized"
            }
          ]
        }
        geo_match_statement = {
          country_codes = ["CN", "US"]
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
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01"
    ])
    error_message = "Rule name should match input"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      rule.action[0].block[0].custom_response[0].response_code == 404 : false
    ])
    error_message = "Custom response code should be 404"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      anytrue([
        for header in rule.action[0].block[0].custom_response[0].response_header :
        header.name == "X-Custom-Response-Header01" && header.value == "Not authorized"
      ]) : false
    ])
    error_message = "Should have X-Custom-Response-Header01 header"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.key == "CustomResponseBody1"
    ])
    error_message = "Should have CustomResponseBody1 custom response body"
  }
}

run "test_multiple_rules_with_different_custom_responses" {
  command = plan

  variables {
    custom_response_body = [
      {
        content      = "Rate limit exceeded"
        content_type = "TEXT_PLAIN"
        key          = "rate_limit"
      },
      {
        content      = "Geographic restriction"
        content_type = "TEXT_PLAIN"
        key          = "geo_block"
      }
    ]
    rule = [
      {
        name     = "RateLimitRule"
        priority = 1
        action   = "block"
        custom_response = {
          response_code            = 429
          custom_response_body_key = "rate_limit"
        }
        rate_based_statement = {
          aggregate_key_type    = "IP"
          limit                 = 1000
          evaluation_window_sec = 300
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RateLimitRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "GeoBlockRule"
        priority = 2
        action   = "block"
        custom_response = {
          response_code            = 403
          custom_response_body_key = "geo_block"
        }
        geo_match_statement = {
          country_codes = ["CN", "RU"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "GeoBlockRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have two rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimitRule" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      rule.action[0].block[0].custom_response[0].response_code == 429 : false
    ])
    error_message = "RateLimitRule should have 429 response code"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "GeoBlockRule" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      rule.action[0].block[0].custom_response[0].response_code == 403 : false
    ])
    error_message = "GeoBlockRule should have 403 response code"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.custom_response_body) == 2
    error_message = "Should have two custom response bodies"
  }
}

run "test_custom_response_with_headers" {
  command = plan

  variables {
    custom_response_body = [
      {
        content      = "Request blocked by WAF"
        content_type = "TEXT_PLAIN"
        key          = "waf_block"
      }
    ]
    rule = [
      {
        name     = "CustomHeadersRule"
        priority = 1
        action   = "block"
        custom_response = {
          response_code            = 403
          custom_response_body_key = "waf_block"
          response_header = [
            {
              name  = "X-WAF-Block"
              value = "true"
            },
            {
              name  = "X-Block-Reason"
              value = "security-policy"
            },
            {
              name  = "X-Request-ID"
              value = "12345"
            }
          ]
        }
        byte_match_statement = {
          field_to_match = {
            uri_path = {}
          }
          positional_constraint = "CONTAINS"
          search_string         = "malicious"
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "CustomHeadersRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CustomHeadersRule" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      anytrue([
        for header in rule.action[0].block[0].custom_response[0].response_header :
        header.name == "X-WAF-Block" && header.value == "true"
      ]) : false
    ])
    error_message = "Should have X-WAF-Block header set to true"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CustomHeadersRule" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      anytrue([
        for header in rule.action[0].block[0].custom_response[0].response_header :
        header.name == "X-Block-Reason" && header.value == "security-policy"
      ]) : false
    ])
    error_message = "Should have X-Block-Reason header"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CustomHeadersRule" ?
      length(rule.action) > 0 && length(rule.action[0].block) > 0 &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      anytrue([
        for header in rule.action[0].block[0].custom_response[0].response_header :
        header.name == "X-Request-ID" && header.value == "12345"
      ]) : false
    ])
    error_message = "Should have X-Request-ID header"
  }
}