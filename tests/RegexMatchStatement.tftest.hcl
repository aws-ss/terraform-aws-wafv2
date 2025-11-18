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
  rule                          = []
  enabled_web_acl_association   = true
  enabled_logging_configuration = false
  tags = {
    Team  = "Security"
    Owner = "Security"
  }
}

mock_provider "aws" {}

run "test_regex_match_statement_uri_path" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexMatchRule"
        priority = 1
        action   = "block"
        regex_match_statement = {
          regex_string = "^/api/v[0-9]+/.*"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RegexMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexMatchRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "^/api/v[0-9]+/.*" : false
    ])
    error_message = "Should have regex pattern '^/api/v[0-9]+/.*'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexMatchRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].uri_path) > 0 : false
    ])
    error_message = "Should match against uri_path"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexMatchRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      anytrue([
        for transform in rule.statement[0].regex_match_statement[0].text_transformation :
        transform.priority == 0 && transform.type == "LOWERCASE"
      ]) : false
    ])
    error_message = "Should have LOWERCASE text transformation with priority 0"
  }
}

run "test_regex_match_statement_single_header" {
  command = plan

  variables {
    rule = [
      {
        name     = "HeaderRegexRule"
        priority = 1
        action   = "allow"
        regex_match_statement = {
          regex_string = "^Bearer [A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+$"
          field_to_match = {
            single_header = {
              name = "authorization"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "HeaderRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeaderRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "^Bearer [A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+\\.[A-Za-z0-9\\-_]+$" : false
    ])
    error_message = "Should have JWT Bearer token regex pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeaderRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].single_header) > 0 &&
      rule.statement[0].regex_match_statement[0].field_to_match[0].single_header[0].name == "authorization" : false
    ])
    error_message = "Should match against authorization header"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeaderRegexRule" ?
      length(rule.action) > 0 && length(rule.action[0].allow) > 0 : false
    ])
    error_message = "Should have allow action"
  }
}

run "test_regex_match_statement_query_string" {
  command = plan

  variables {
    rule = [
      {
        name     = "QueryStringRegexRule"
        priority = 1
        action   = "block"
        regex_match_statement = {
          regex_string = ".*(select|union|insert|delete|drop).*"
          field_to_match = {
            query_string = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            },
            {
              priority = 1
              type     = "URL_DECODE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "QueryStringRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "QueryStringRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == ".*(select|union|insert|delete|drop).*" : false
    ])
    error_message = "Should have SQL injection detection regex pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "QueryStringRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].query_string) > 0 : false
    ])
    error_message = "Should match against query_string"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "QueryStringRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].text_transformation) == 2 : false
    ])
    error_message = "Should have exactly 2 text transformations"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "QueryStringRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      anytrue([
        for transform in rule.statement[0].regex_match_statement[0].text_transformation :
        transform.priority == 1 && transform.type == "URL_DECODE"
      ]) : false
    ])
    error_message = "Should have URL_DECODE text transformation with priority 1"
  }
}

run "test_regex_match_statement_cookies" {
  command = plan

  variables {
    rule = [
      {
        name     = "CookieRegexRule"
        priority = 1
        action   = "count"
        regex_match_statement = {
          regex_string = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
          field_to_match = {
            cookies = {
              match_pattern = {
                included_cookies = ["session_id", "tracking_id"]
              }
              match_scope       = "VALUE"
              oversize_handling = "CONTINUE"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "CookieRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookieRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$" : false
    ])
    error_message = "Should have UUID regex pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookieRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].cookies) > 0 &&
      rule.statement[0].regex_match_statement[0].field_to_match[0].cookies[0].match_scope == "VALUE" : false
    ])
    error_message = "Should match against cookie values"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookieRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].cookies) > 0 &&
      contains(rule.statement[0].regex_match_statement[0].field_to_match[0].cookies[0].match_pattern[0].included_cookies, "session_id") : false
    ])
    error_message = "Should include session_id cookie in match pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "CookieRegexRule" ?
      length(rule.action) > 0 && length(rule.action[0].count) > 0 : false
    ])
    error_message = "Should have count action"
  }
}

run "test_regex_match_statement_headers" {
  command = plan

  variables {
    rule = [
      {
        name     = "HeadersRegexRule"
        priority = 1
        action   = "block"
        regex_match_statement = {
          regex_string = ".*(script|javascript|vbscript|onload|onerror).*"
          field_to_match = {
            headers = {
              match_pattern = {
                excluded_headers = ["authorization", "cookie"]
              }
              match_scope       = "VALUE"
              oversize_handling = "MATCH"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            },
            {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "HeadersRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeadersRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == ".*(script|javascript|vbscript|onload|onerror).*" : false
    ])
    error_message = "Should have XSS detection regex pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeadersRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].headers) > 0 &&
      rule.statement[0].regex_match_statement[0].field_to_match[0].headers[0].oversize_handling == "MATCH" : false
    ])
    error_message = "Should have MATCH oversize handling"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeadersRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].headers) > 0 &&
      contains(rule.statement[0].regex_match_statement[0].field_to_match[0].headers[0].match_pattern[0].excluded_headers, "authorization") : false
    ])
    error_message = "Should exclude authorization header from matching"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "HeadersRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      anytrue([
        for transform in rule.statement[0].regex_match_statement[0].text_transformation :
        transform.priority == 1 && transform.type == "HTML_ENTITY_DECODE"
      ]) : false
    ])
    error_message = "Should have HTML_ENTITY_DECODE text transformation"
  }
}

run "test_regex_match_statement_body" {
  command = plan

  variables {
    rule = [
      {
        name     = "BodyRegexRule"
        priority = 1
        action   = "block"
        regex_match_statement = {
          regex_string = "\\b(4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})\\b"
          field_to_match = {
            body = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "COMPRESS_WHITE_SPACE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "BodyRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BodyRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "\\b(4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})\\b" : false
    ])
    error_message = "Should have credit card number detection regex pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BodyRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].body) > 0 : false
    ])
    error_message = "Should match against request body"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BodyRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      anytrue([
        for transform in rule.statement[0].regex_match_statement[0].text_transformation :
        transform.type == "COMPRESS_WHITE_SPACE"
      ]) : false
    ])
    error_message = "Should have COMPRESS_WHITE_SPACE text transformation"
  }
}

run "test_regex_match_statement_multiple_rules" {
  command = plan

  variables {
    rule = [
      {
        name     = "EmailRegexRule"
        priority = 1
        action   = "allow"
        regex_match_statement = {
          regex_string = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
          field_to_match = {
            single_query_argument = {
              name = "email"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "EmailRegexRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "IPRegexRule"
        priority = 2
        action   = "block"
        regex_match_statement = {
          regex_string = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
          field_to_match = {
            all_query_arguments = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "IPRegexRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have exactly two rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "EmailRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$" : false
    ])
    error_message = "EmailRegexRule should have email validation regex"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "IPRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      rule.statement[0].regex_match_statement[0].regex_string == "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$" : false
    ])
    error_message = "IPRegexRule should have IPv4 validation regex"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "EmailRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].single_query_argument) > 0 &&
      rule.statement[0].regex_match_statement[0].field_to_match[0].single_query_argument[0].name == "email" : false
    ])
    error_message = "EmailRegexRule should match against email query parameter"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "IPRegexRule" ?
      length(rule.statement) > 0 && length(rule.statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].regex_match_statement[0].field_to_match[0].all_query_arguments) > 0 : false
    ])
    error_message = "IPRegexRule should match against all query arguments"
  }
}

