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

run "basic_ip_set_reference_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/example-ip-set/12345678-1234-1234-1234-123456789012"
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
    error_message = "Should have one rule with IP set reference statement"
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
      length(rule.statement) > 0 && rule.statement[0].ip_set_reference_statement != null
    ])
    error_message = "IP set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      rule.statement[0].ip_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/example-ip-set/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "IP set ARN should match expected value"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) == 0
    ])
    error_message = "Should not have forwarded IP config when not specified"
  }
}

run "ip_set_reference_with_forwarded_ip_config" {
  command = plan

  variables {
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "Rule02"
        priority = 5
        action   = "count"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/ipset/trusted-ips/87654321-4321-4321-4321-210987654321"
          ip_set_forwarded_ip_config = {
            fallback_behavior = "NO_MATCH"
            header_name       = "X-Forwarded-For"
            position          = "FIRST"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "trusted_ip_count"
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
      length(rule.statement) > 0 && rule.statement[0].ip_set_reference_statement != null
    ])
    error_message = "IP set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].fallback_behavior == "NO_MATCH"
    ])
    error_message = "Fallback behavior should be NO_MATCH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].header_name == "X-Forwarded-For"
    ])
    error_message = "Header name should be X-Forwarded-For"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].position == "FIRST"
    ])
    error_message = "Position should be FIRST"
  }
}

run "ip_set_reference_with_match_fallback_and_last_position" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "Rule03"
        priority = 15
        action   = "allow"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-west-2:123456789012:regional/ipset/whitelist-ips/11111111-2222-3333-4444-555555555555"
          ip_set_forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Real-IP"
            position          = "LAST"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "whitelist_ip_allow"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].fallback_behavior == "MATCH"
    ])
    error_message = "Fallback behavior should be MATCH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].header_name == "X-Real-IP"
    ])
    error_message = "Header name should be X-Real-IP"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].position == "LAST"
    ])
    error_message = "Position should be LAST"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].allow != null
    ])
    error_message = "Rule action should be allow"
  }
}

run "ip_set_reference_with_captcha_action_cloudflare_header" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "Rule04"
        priority = 20
        action   = "captcha"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:eu-west-1:123456789012:regional/ipset/suspicious-ips/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
          ip_set_forwarded_ip_config = {
            fallback_behavior = "NO_MATCH"
            header_name       = "CF-Connecting-IP"
            position          = "ANY"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "suspicious_ip_captcha"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule04" &&
      strcontains(rule.statement[0].ip_set_reference_statement[0].arn, "suspicious-ips")
    ])
    error_message = "Should reference suspicious IPs IP set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Rule action should be captcha"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].header_name == "CF-Connecting-IP"
    ])
    error_message = "Header name should be CF-Connecting-IP for Cloudflare"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].position == "ANY"
    ])
    error_message = "Position should be ANY"
  }
}

run "ip_set_reference_multiple_rules_different_actions" {
  command = plan

  variables {
    rule = [
      {
        name     = "BlockMaliciousIPs"
        priority = 10
        action   = "block"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/malicious-ips/99999999-8888-7777-6666-555555555555"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "block_malicious_ips"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "CountTrustedIPs"
        priority = 20
        action   = "count"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/trusted-partners/12345678-abcd-efgh-ijkl-123456789012"
          ip_set_forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Forwarded-For"
            position          = "FIRST"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "count_trusted_partners"
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
      rule.name == "BlockMaliciousIPs" && length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "First rule action should be block"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CountTrustedIPs" && length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Second rule action should be count"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BlockMaliciousIPs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      strcontains(rule.statement[0].ip_set_reference_statement[0].arn, "malicious-ips")
    ])
    error_message = "First rule should reference malicious IPs set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CountTrustedIPs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      strcontains(rule.statement[0].ip_set_reference_statement[0].arn, "trusted-partners")
    ])
    error_message = "Second rule should reference trusted partners IP set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BlockMaliciousIPs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) == 0
    ])
    error_message = "First rule should not have forwarded IP config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CountTrustedIPs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      length(rule.statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) == 1
    ])
    error_message = "Second rule should have forwarded IP config"
  }
}

run "ip_set_reference_cloudfront_scope_global_arn" {
  command = plan

  variables {
    name           = "WebACL06"
    scope          = "CLOUDFRONT"
    default_action = "block"
    rule = [
      {
        name     = "GlobalIPSetRule"
        priority = 5
        action   = "count"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/ipset/cdn-bypass-ips/global-12345-67890-abcdef"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "global_ipset_count"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl.this.scope == "CLOUDFRONT"
    error_message = "WebACL scope should be CLOUDFRONT"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      strcontains(rule.statement[0].ip_set_reference_statement[0].arn, ":us-east-1:123456789012:global/")
    ])
    error_message = "Should reference global IP set for CloudFront scope"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].ip_set_reference_statement != null &&
      strcontains(rule.statement[0].ip_set_reference_statement[0].arn, "cdn-bypass-ips")
    ])
    error_message = "Should reference CDN bypass IPs set"
  }
}