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
run "test_size_constraint_statement_basic" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            single_header = {
              name = "host"
            }
          }
          comparison_operator = "EQ"
          size                = 0
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
    error_message = "Should have one rule with size constraint statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
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
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].text_transformation) == 1
    ])
    error_message = "Text transformation should be configured"
  }
}

run "test_size_constraint_statement_uri_path_large" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "BlockLargeURIs"
        priority = 20
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            uri_path = {}
          }
          comparison_operator = "GT"
          size                = 2048
          text_transformation = [
            {
              priority = 1
              type     = "URL_DECODE"
            },
            {
              priority = 2
              type     = "NORMALIZE_PATH"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "LargeURIRule"
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
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].text_transformation) == 2
    ])
    error_message = "Should have two text transformations"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].uri_path) > 0
    ])
    error_message = "URI path field should be configured"
  }
}

run "test_size_constraint_statement_query_string_limit" {
  command = plan

  variables {
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "LimitQueryStringSize"
        priority = 30
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            query_string = {}
          }
          comparison_operator = "GE"
          size                = 1024
          text_transformation = [
            {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            },
            {
              priority = 2
              type     = "URL_DECODE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "QueryStringSizeRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl.this.scope == "CLOUDFRONT"
    error_message = "Scope should be CLOUDFRONT"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].query_string) > 0
    ])
    error_message = "Query string field should be configured"
  }
}

run "test_size_constraint_statement_request_body_small" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "BlockSmallPayloads"
        priority = 15
        action   = "count"
        size_constraint_statement = {
          field_to_match = {
            body = {}
          }
          comparison_operator = "LT"
          size                = 10
          text_transformation = [
            {
              priority = 5
              type     = "COMPRESS_WHITE_SPACE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SmallPayloadRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].body) > 0
    ])
    error_message = "Request body field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.action != null && length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Rule action should be count for monitoring"
  }
}

run "test_size_constraint_statement_headers_not_equal" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "HeadersSizeValidation"
        priority = 25
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            headers = {
              match_scope       = "ALL"
              oversize_handling = "CONTINUE"
              match_pattern = {
                all = {}
              }
            }
          }
          comparison_operator = "NE"
          size                = 100
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "HeadersSizeMetric"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].headers) > 0
    ])
    error_message = "Headers field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeadersSizeValidation" && rule.priority == 25
    ])
    error_message = "Rule should have correct name and priority"
  }
}

run "test_size_constraint_statement_cookies_less_equal" {
  command = plan

  variables {
    scope          = "REGIONAL"
    default_action = "allow"
    rule = [
      {
        name     = "CookiesSizeValidation"
        priority = 40
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            cookies = {
              match_scope       = "KEY"
              oversize_handling = "MATCH"
              match_pattern = {
                included_cookies = ["sessionid", "csrf_token"]
              }
            }
          }
          comparison_operator = "LE"
          size                = 256
          text_transformation = [
            {
              priority = 10
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "CookiesSizeMetric"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].cookies) > 0
    ])
    error_message = "Cookies field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookiesSizeValidation" && rule.priority == 40
    ])
    error_message = "Rule should have correct name and priority"
  }
}

run "test_size_constraint_statement_all_operators" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "SingleQueryArgumentSize"
        priority = 50
        action   = "allow"
        size_constraint_statement = {
          field_to_match = {
            single_query_argument = {
              name = "search"
            }
          }
          comparison_operator = "GT"
          size                = 0
          text_transformation = [
            {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            },
            {
              priority = 2
              type     = "URL_DECODE"
            },
            {
              priority = 3
              type     = "COMPRESS_WHITE_SPACE"
            },
            {
              priority = 4
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SingleQueryArgSizeMetric"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].single_query_argument) > 0
    ])
    error_message = "Single query argument field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].text_transformation) == 4
    ])
    error_message = "Should have four text transformations"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SingleQueryArgumentSize" && rule.priority == 50
    ])
    error_message = "Rule should have correct name and priority"
  }
}

run "test_size_constraint_statement_method_zero" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "HTTPMethodSizeCheck"
        priority = 60
        action   = "block"
        size_constraint_statement = {
          field_to_match = {
            method = {}
          }
          comparison_operator = "EQ"
          size                = 0
          text_transformation = [
            {
              priority = 1
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "HTTPMethodSizeMetric"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].size_constraint_statement != null
    ])
    error_message = "Size constraint statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].size_constraint_statement[0].field_to_match[0].method) > 0
    ])
    error_message = "Method field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HTTPMethodSizeCheck" && rule.priority == 60
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].size_constraint_statement != null &&
      length(rule.statement[0].size_constraint_statement[0].text_transformation) == 1
    ])
    error_message = "Should have one text transformation with NONE type"
  }
}