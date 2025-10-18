mock_provider "aws" {}

variables {
  name           = "test-webacl"
  scope          = "REGIONAL"
  default_action = "allow"
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "test-webacl"
    sampled_requests_enabled   = true
  }
  rule         = []
  resource_arn = []
}

run "test_geo_match_statement_basic" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
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
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with geo match statement"
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
      length(rule.statement[0].geo_match_statement) > 0
    ])
    error_message = "Rule should have geo match statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      contains(rule.statement[0].geo_match_statement[0].country_codes, "CN")
    ])
    error_message = "Geo match statement should include CN country code"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      contains(rule.statement[0].geo_match_statement[0].country_codes, "US")
    ])
    error_message = "Geo match statement should include US country code"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action[0].count) > 0
    ])
    error_message = "Rule should have count action"
  }
}

run "test_geo_match_statement_with_forwarded_ip" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        geo_match_statement = {
          country_codes = ["CN", "US"]
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
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].geo_match_statement[0].forwarded_ip_config) > 0
    ])
    error_message = "Geo match statement should have forwarded IP config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH"
    ])
    error_message = "Forwarded IP config should have MATCH fallback behavior"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For"
    ])
    error_message = "Forwarded IP config should have correct header name"
  }
}

run "test_geo_match_statement_block_action" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule02"
        priority = 20
        action   = "block"
        geo_match_statement = {
          country_codes = ["AE"]
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
      rule.name == "Rule02" && rule.priority == 20
    ])
    error_message = "Rule should have correct name and priority for block action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      contains(rule.statement[0].geo_match_statement[0].country_codes, "AE")
    ])
    error_message = "Geo match statement should include AE country code"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action[0].block) > 0
    ])
    error_message = "Rule should have block action"
  }
}

run "test_geo_match_statement_multiple_rules" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        geo_match_statement = {
          country_codes = ["CN", "US"]
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
      },
      {
        name     = "Rule02"
        priority = 20
        action   = "block"
        geo_match_statement = {
          country_codes = ["AE"]
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
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have two rules with geo match statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" && length(rule.statement[0].geo_match_statement[0].forwarded_ip_config) > 0
    ])
    error_message = "First rule should have forwarded IP config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule02" && contains(rule.statement[0].geo_match_statement[0].country_codes, "AE")
    ])
    error_message = "Second rule should target AE country code"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" && length(rule.action[0].count) > 0
    ])
    error_message = "First rule should have count action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule02" && length(rule.action[0].block) > 0
    ])
    error_message = "Second rule should have block action"
  }
}
