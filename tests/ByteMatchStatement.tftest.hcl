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
  rule         = []
  resource_arn = []
}

run "test_byte_match_statement_single_header" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        byte_match_statement = {
          field_to_match = {
            single_header = {
              name = "host"
            }
          }
          positional_constraint = "EXACTLY"
          search_string         = "test"
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
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule"
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
      rule.name == "Rule01" ? rule.priority == 10 : false
    ])
    error_message = "Rule priority should be 10"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" ?
      length(rule.action) > 0 && length(rule.action[0].count) > 0 : false
    ])
    error_message = "Rule action should be count"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      rule.statement[0].byte_match_statement[0].search_string == "test" : false
    ])
    error_message = "Search string should match input"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "Rule01" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      rule.statement[0].byte_match_statement[0].positional_constraint == "EXACTLY" : false
    ])
    error_message = "Positional constraint should be EXACTLY"
  }
}

run "test_byte_match_statement_uri_path" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchUriRule"
        priority = 2
        action   = "count"
        byte_match_statement = {
          field_to_match = {
            uri_path = {}
          }
          positional_constraint = "STARTS_WITH"
          search_string         = "/admin"
          text_transformation = [
            {
              priority = 0
              type     = "URL_DECODE"
            },
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ByteMatchUriRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchUriRule"
    ])
    error_message = "Rule name should match input"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchUriRule" ?
      length(rule.action) > 0 && length(rule.action[0].count) > 0 : false
    ])
    error_message = "Rule action should be count"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchUriRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      rule.statement[0].byte_match_statement[0].positional_constraint == "STARTS_WITH" : false
    ])
    error_message = "Positional constraint should be STARTS_WITH"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchUriRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      length(rule.statement[0].byte_match_statement[0].text_transformation) == 2 : false
    ])
    error_message = "Should have two text transformations"
  }
}

run "test_byte_match_statement_query_string" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchQueryRule"
        priority = 3
        action   = "allow"
        byte_match_statement = {
          field_to_match = {
            query_string = {}
          }
          positional_constraint = "CONTAINS"
          search_string         = "debug=true"
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "ByteMatchQueryRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchQueryRule"
    ])
    error_message = "Rule name should match input"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchQueryRule" ?
      length(rule.action) > 0 && length(rule.action[0].allow) > 0 : false
    ])
    error_message = "Rule action should be allow"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchQueryRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      rule.statement[0].byte_match_statement[0].positional_constraint == "CONTAINS" : false
    ])
    error_message = "Positional constraint should be CONTAINS"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchQueryRule" ?
      length(rule.visibility_config) > 0 &&
      rule.visibility_config[0].cloudwatch_metrics_enabled == false : false
    ])
    error_message = "CloudWatch metrics should be disabled for this rule"
  }
}

run "test_byte_match_statement_method" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchMethodRule"
        priority = 4
        action   = "block"
        byte_match_statement = {
          field_to_match = {
            method = {}
          }
          positional_constraint = "EXACTLY"
          search_string         = "PUT"
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ByteMatchMethodRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchMethodRule"
    ])
    error_message = "Rule name should match input"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchMethodRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      rule.statement[0].byte_match_statement[0].search_string == "PUT" : false
    ])
    error_message = "Search string should be PUT"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchMethodRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].byte_match_statement) > 0 &&
      length(rule.statement[0].byte_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].byte_match_statement[0].field_to_match[0].method) > 0 : false
    ])
    error_message = "Field to match should be method"
  }
}