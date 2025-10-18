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

run "basic_label_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        label_match_statement = {
          key   = "awswaf:managed:aws:bot-control:signal:automated_browser"
          scope = "LABEL"
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
    error_message = "Should have one rule with label match statement"
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
      length(rule.statement) > 0 && rule.statement[0].label_match_statement != null
    ])
    error_message = "Label match statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].label_match_statement != null &&
      rule.statement[0].label_match_statement[0].key == "awswaf:managed:aws:bot-control:signal:automated_browser"
    ])
    error_message = "Label key should match expected bot control signal"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].label_match_statement != null &&
      rule.statement[0].label_match_statement[0].scope == "LABEL"
    ])
    error_message = "Label scope should be LABEL"
  }
}

run "label_match_namespace_scope" {
  command = plan

  variables {
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "Rule02"
        priority = 5
        action   = "count"
        label_match_statement = {
          key   = "awswaf:managed:aws:core-rule-set:"
          scope = "NAMESPACE"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "core_rule_set_namespace"
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
      length(rule.statement) > 0 && rule.statement[0].label_match_statement != null
    ])
    error_message = "Label match statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].label_match_statement != null &&
      rule.statement[0].label_match_statement[0].scope == "NAMESPACE"
    ])
    error_message = "Label scope should be NAMESPACE"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].label_match_statement != null &&
      strcontains(rule.statement[0].label_match_statement[0].key, "core-rule-set")
    ])
    error_message = "Should reference core rule set namespace"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Rule action should be count"
  }
}
