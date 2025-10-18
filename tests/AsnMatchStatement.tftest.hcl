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

run "basic_asn_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        asn_match_statement = {
          asn_list = ["12345", "12346"]
          forwarded_ip_config = {
            fallback_behavior = "NO_MATCH"
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
    error_message = "Should have one rule with ASN match statement"
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
      length(rule.statement) > 0 && rule.statement[0].asn_match_statement != null
    ])
    error_message = "ASN match statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      toset(rule.statement[0].asn_match_statement[0].asn_list) == toset([12345, 12346])
    ])
    error_message = "ASN list should match expected values"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].asn_match_statement[0].forwarded_ip_config[0].fallback_behavior == "NO_MATCH"
    ])
    error_message = "Fallback behavior should be NO_MATCH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].asn_match_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For"
    ])
    error_message = "Header name should be X-Forwarded-For"
  }
}

run "asn_match_without_forwarded_ip_config" {
  command = plan

  variables {
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "Rule02"
        priority = 5
        action   = "block"
        asn_match_statement = {
          asn_list = ["54321", "98765"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "asn_block_metric"
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
      length(rule.statement) > 0 && rule.statement[0].asn_match_statement != null
    ])
    error_message = "ASN match statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      toset(rule.statement[0].asn_match_statement[0].asn_list) == toset([54321, 98765])
    ])
    error_message = "ASN list should match expected values"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) == 0
    ])
    error_message = "Forwarded IP config should not be present when not specified"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "Rule action should be block"
  }
}

run "asn_match_with_match_fallback_behavior" {
  command = plan

  variables {
    scope          = "REGIONAL"
    default_action = "allow"
    rule = [
      {
        name     = "Rule03"
        priority = 15
        action   = "allow"
        asn_match_statement = {
          asn_list = ["16509", "13335"] # AWS and Cloudflare ASNs
          forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Real-IP"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "aws_cloudflare_asn_allow"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].asn_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH"
    ])
    error_message = "Fallback behavior should be MATCH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].asn_match_statement[0].forwarded_ip_config[0].header_name == "X-Real-IP"
    ])
    error_message = "Header name should be X-Real-IP"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].allow != null
    ])
    error_message = "Rule action should be allow"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      contains(rule.statement[0].asn_match_statement[0].asn_list, 16509)
    ])
    error_message = "ASN list should contain AWS ASN 16509"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      contains(rule.statement[0].asn_match_statement[0].asn_list, 13335)
    ])
    error_message = "ASN list should contain Cloudflare ASN 13335"
  }
}

run "asn_match_single_asn_with_captcha_action" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule04"
        priority = 20
        action   = "captcha"
        asn_match_statement = {
          asn_list = ["12345"]
          forwarded_ip_config = {
            fallback_behavior = "NO_MATCH"
            header_name       = "CF-Connecting-IP"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "suspicious_asn_captcha"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].asn_list) == 1
    ])
    error_message = "ASN list should contain exactly one ASN"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      rule.statement[0].asn_match_statement[0].asn_list[0] == 12345
    ])
    error_message = "Single ASN should be 12345"
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
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].asn_match_statement[0].forwarded_ip_config[0].header_name == "CF-Connecting-IP"
    ])
    error_message = "Header name should be CF-Connecting-IP for Cloudflare"
  }
}

run "asn_match_multiple_rules_different_actions" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "BlockSuspiciousASNs"
        priority = 10
        action   = "block"
        asn_match_statement = {
          asn_list = ["99999", "88888", "77777"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "block_suspicious_asns"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "AllowTrustedASNs"
        priority = 20
        action   = "count"
        asn_match_statement = {
          asn_list = ["16509", "32934"] # AWS and Facebook ASNs
          forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Forwarded-For"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "count_trusted_asns"
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
      rule.name == "BlockSuspiciousASNs" && length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "First rule action should be block"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "AllowTrustedASNs" && length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Second rule action should be count"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BlockSuspiciousASNs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].asn_list) == 3
    ])
    error_message = "First rule should have 3 ASNs"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "AllowTrustedASNs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].asn_list) == 2
    ])
    error_message = "Second rule should have 2 ASNs"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BlockSuspiciousASNs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) == 0
    ])
    error_message = "First rule should not have forwarded IP config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "AllowTrustedASNs" &&
      length(rule.statement) > 0 &&
      rule.statement[0].asn_match_statement != null &&
      length(rule.statement[0].asn_match_statement[0].forwarded_ip_config) == 1
    ])
    error_message = "Second rule should have forwarded IP config"
  }
}
