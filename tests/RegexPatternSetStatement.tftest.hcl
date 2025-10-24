mock_provider "aws" {}

variables {
  resource_arn   = []
  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
}

run "test_regex_pattern_set_reference_basic" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "block"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            single_header = {
              name = "user-agent"
            }
          }
          arn = "arn:aws:wafv2:ap-northeast-2:362252864672:regional/regexpatternset/test/8356a9ba-8236-459d-8684-3b5a01091cb7"
          text_transformation = [
            {
              priority = 10
              type     = "LOWERCASE"
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
    error_message = "Should have one rule with regex pattern set reference statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
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
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].text_transformation) == 1
    ])
    error_message = "Text transformation should be configured"
  }
}

run "test_regex_pattern_set_uri_path" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "BlockMaliciousPaths"
        priority = 20
        action   = "block"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            uri_path = {}
          }
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/malicious-paths/12345678-1234-1234-1234-123456789012"
          text_transformation = [
            {
              priority = 1
              type     = "URL_DECODE"
            },
            {
              priority = 2
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "MaliciousPathsRule"
          sampled_requests_enabled   = true
        }
      }
    ]
    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "WebACLURIPath"
      sampled_requests_enabled   = true
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].text_transformation) == 2
    ])
    error_message = "Should have two text transformations"
  }
}

run "test_regex_pattern_set_query_string" {
  command = plan

  variables {
    scope          = "CLOUDFRONT"
    default_action = "allow"
    rule = [
      {
        name     = "SQLInjectionDetection"
        priority = 30
        action   = "block"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            query_string = {}
          }
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/regexpatternset/sql-injection-patterns/87654321-4321-4321-4321-210987654321"
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
          metric_name                = "SQLInjectionRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl.this.scope == "CLOUDFRONT"
    error_message = "Scope should be CLOUDFRONT for global regex pattern set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].query_string) > 0
    ])
    error_message = "Query string field should be configured"
  }
}

run "test_regex_pattern_set_request_body" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "PayloadValidation"
        priority = 15
        action   = "count"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            body = {}
          }
          arn = "arn:aws:wafv2:eu-west-1:123456789012:regional/regexpatternset/payload-patterns/abcdef12-3456-7890-abcd-ef1234567890"
          text_transformation = [
            {
              priority = 5
              type     = "COMPRESS_WHITE_SPACE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "PayloadValidationRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].body) > 0
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

run "test_regex_pattern_set_headers_inspection" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "SuspiciousHeadersRule"
        priority = 25
        action   = "block"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            headers = {
              match_scope       = "ALL"
              oversize_handling = "CONTINUE"
              match_pattern = {
                all = {}
              }
            }
          }
          arn = "arn:aws:wafv2:us-west-2:123456789012:regional/regexpatternset/suspicious-headers/fedcba09-8765-4321-0987-65432109876"
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            },
            {
              priority = 2
              type     = "NORMALIZE_PATH"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SuspiciousHeadersMetric"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].headers) > 0
    ])
    error_message = "Headers field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].text_transformation) == 2
    ])
    error_message = "Should have two text transformations"
  }
}

run "test_regex_pattern_set_cookies_inspection" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "CookieValidationRule"
        priority = 40
        action   = "block"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            cookies = {
              match_scope       = "KEY"
              oversize_handling = "MATCH"
              match_pattern = {
                included_cookies = ["sessionid", "csrf_token", "auth_key"]
              }
            }
          }
          arn = "arn:aws:wafv2:ap-southeast-1:123456789012:regional/regexpatternset/cookie-validation/11111111-2222-3333-4444-555555555555"
          text_transformation = [
            {
              priority = 10
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "CookieValidationMetric"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].cookies) > 0
    ])
    error_message = "Cookies field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookieValidationRule" && rule.priority == 40
    ])
    error_message = "Rule should have correct name and priority"
  }
}

run "test_regex_pattern_set_multiple_transformations" {
  command = plan

  variables {
    default_action = "allow"
    rule = [
      {
        name     = "ComprehensiveValidation"
        priority = 50
        action   = "allow"
        regex_pattern_set_reference_statement = {
          field_to_match = {
            single_query_argument = {
              name = "search"
            }
          }
          arn = "arn:aws:wafv2:ca-central-1:123456789012:regional/regexpatternset/search-validation/99999999-8888-7777-6666-555555555555"
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
          metric_name                = "ComprehensiveValidationMetric"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].regex_pattern_set_reference_statement != null
    ])
    error_message = "Regex pattern set reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].single_query_argument) > 0
    ])
    error_message = "Single query argument field should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].regex_pattern_set_reference_statement != null &&
      length(rule.statement[0].regex_pattern_set_reference_statement[0].text_transformation) == 4
    ])
    error_message = "Should have four text transformations"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ComprehensiveValidation" && rule.priority == 50
    ])
    error_message = "Rule should have correct name and priority"
  }
}