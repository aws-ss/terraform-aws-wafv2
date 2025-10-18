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

run "test_example_or_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        or_statement = {
          statements = [
            {
              not_statement = {
                byte_match_statement = {
                  field_to_match = {
                    uri_path = {}
                  }
                  positional_constraint = "CONTAINS"
                  search_string         = "/admin"
                  text_transformation = [
                    {
                      priority = 0
                      type     = "LOWERCASE"
                    }
                  ]
                }
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "CONTAINS"
                search_string         = "/administrator"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
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

  # Test that the rule exists and has the correct name
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"]) == 1
    error_message = "Expected exactly one rule named 'Rule01'"
  }

  # Test that the rule contains an or_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement) > 0
    error_message = "Rule should contain an or_statement"
  }

  # Test that the or_statement contains exactly 2 statements
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement) == 2
    error_message = "or_statement should contain exactly 2 statements"
  }

  # Test that the first statement in or_statement contains a not_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[0].not_statement) > 0
    error_message = "First statement in or_statement should contain a not_statement"
  }

  # Test that the not_statement contains a byte_match_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0
    error_message = "not_statement should contain a byte_match_statement"
  }

  # Test that the not_statement's byte_match_statement has the correct search string
  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "/admin"
    error_message = "not_statement's byte_match_statement should search for '/admin'"
  }

  # Test that the second statement in or_statement contains a byte_match_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[1].byte_match_statement) > 0
    error_message = "Second statement in or_statement should contain a byte_match_statement"
  }

  # Test that the second byte_match_statement has the correct search string
  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[1].byte_match_statement[0].search_string == "/administrator"
    error_message = "Second byte_match_statement should search for '/administrator'"
  }

  # Test that both byte_match_statements use uri_path field_to_match
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].uri_path) > 0
    error_message = "First byte_match_statement should use uri_path field_to_match"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[1].byte_match_statement[0].field_to_match[0].uri_path) > 0
    error_message = "Second byte_match_statement should use uri_path field_to_match"
  }

  # Test that both byte_match_statements use CONTAINS positional constraint
  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS"
    error_message = "First byte_match_statement should use CONTAINS positional constraint"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].or_statement[0].statement[1].byte_match_statement[0].positional_constraint == "CONTAINS"
    error_message = "Second byte_match_statement should use CONTAINS positional constraint"
  }
}

run "test_or_statement_with_byte_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchOrRule"
        priority = 20
        action   = "block"
        or_statement = {
          statements = [
            {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "STARTS_WITH"
                search_string         = "/api/"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  method = {}
                }
                positional_constraint = "EXACTLY"
                search_string         = "POST"
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ByteMatchOrRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "ByteMatchOrRule"][0].statement[0].or_statement[0].statement) == 2
    error_message = "or_statement should contain exactly 2 byte_match_statements"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "ByteMatchOrRule"][0].statement[0].or_statement[0].statement[0].byte_match_statement) > 0
    error_message = "First statement should be a byte_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "ByteMatchOrRule"][0].statement[0].or_statement[0].statement[1].byte_match_statement) > 0
    error_message = "Second statement should be a byte_match_statement"
  }
}

run "test_or_statement_with_geo_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "GeoMatchOrRule"
        priority = 25
        action   = "block"
        or_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN", "RU"]
              }
            },
            {
              geo_match_statement = {
                country_codes = ["KP", "IR"]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "GeoMatchOrRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "GeoMatchOrRule"][0].statement[0].or_statement[0].statement[0].geo_match_statement) > 0
    error_message = "First statement should be a geo_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "GeoMatchOrRule"][0].statement[0].or_statement[0].statement[1].geo_match_statement) > 0
    error_message = "Second statement should be a geo_match_statement"
  }
}

run "test_or_statement_with_ip_set_reference_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "IpSetOrRule"
        priority = 30
        action   = "allow"
        or_statement = {
          statements = [
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/allowed-ips/12345678-1234-1234-1234-123456789012"
              }
            },
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/trusted-ips/12345678-1234-1234-1234-123456789012"
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "IpSetOrRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "IpSetOrRule"][0].statement[0].or_statement[0].statement[0].ip_set_reference_statement) > 0
    error_message = "First statement should be an ip_set_reference_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "IpSetOrRule"][0].statement[0].or_statement[0].statement[1].ip_set_reference_statement) > 0
    error_message = "Second statement should be an ip_set_reference_statement"
  }
}

run "test_or_statement_with_size_constraint_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "SizeConstraintOrRule"
        priority = 35
        action   = "block"
        or_statement = {
          statements = [
            {
              size_constraint_statement = {
                field_to_match = {
                  body = {}
                }
                comparison_operator = "GT"
                size                = 1024
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            },
            {
              size_constraint_statement = {
                field_to_match = {
                  single_header = {
                    name = "content-length"
                  }
                }
                comparison_operator = "LT"
                size                = 10485760
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SizeConstraintOrRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "SizeConstraintOrRule"][0].statement[0].or_statement[0].statement[0].size_constraint_statement) > 0
    error_message = "First statement should be a size_constraint_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "SizeConstraintOrRule"][0].statement[0].or_statement[0].statement[1].size_constraint_statement) > 0
    error_message = "Second statement should be a size_constraint_statement"
  }
}

run "test_or_statement_with_sqli_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "SqliMatchOrRule"
        priority = 40
        action   = "block"
        or_statement = {
          statements = [
            {
              sqli_match_statement = {
                field_to_match = {
                  body = {}
                }
                text_transformation = [
                  {
                    priority = 1
                    type     = "URL_DECODE"
                  },
                  {
                    priority = 2
                    type     = "HTML_ENTITY_DECODE"
                  }
                ]
              }
            },
            {
              sqli_match_statement = {
                field_to_match = {
                  all_query_arguments = {}
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SqliMatchOrRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "SqliMatchOrRule"][0].statement[0].or_statement[0].statement[0].sqli_match_statement) > 0
    error_message = "First statement should be a sqli_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "SqliMatchOrRule"][0].statement[0].or_statement[0].statement[1].sqli_match_statement) > 0
    error_message = "Second statement should be a sqli_match_statement"
  }
}

run "test_or_statement_with_xss_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "XssMatchOrRule"
        priority = 45
        action   = "block"
        or_statement = {
          statements = [
            {
              xss_match_statement = {
                field_to_match = {
                  single_query_argument = {
                    name = "search"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              xss_match_statement = {
                field_to_match = {
                  body = {}
                }
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
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "XssMatchOrRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "XssMatchOrRule"][0].statement[0].or_statement[0].statement[0].xss_match_statement) > 0
    error_message = "First statement should be an xss_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "XssMatchOrRule"][0].statement[0].or_statement[0].statement[1].xss_match_statement) > 0
    error_message = "Second statement should be an xss_match_statement"
  }
}

run "test_or_statement_with_regex_pattern_set_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexPatternOrRule"
        priority = 50
        action   = "captcha"
        or_statement = {
          statements = [
            {
              regex_pattern_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/malicious-paths/12345678-1234-1234-1234-123456789012"
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
            },
            {
              regex_pattern_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/suspicious-patterns/12345678-1234-1234-1234-123456789012"
                field_to_match = {
                  single_query_argument = {
                    name = "q"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RegexPatternOrRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "RegexPatternOrRule"][0].statement[0].or_statement[0].statement[0].regex_pattern_set_reference_statement) > 0
    error_message = "First statement should be a regex_pattern_set_reference_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "RegexPatternOrRule"][0].statement[0].or_statement[0].statement[1].regex_pattern_set_reference_statement) > 0
    error_message = "Second statement should be a regex_pattern_set_reference_statement"
  }
}

run "test_or_statement_with_label_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "LabelMatchOrRule"
        priority = 55
        action   = "count"
        or_statement = {
          statements = [
            {
              label_match_statement = {
                scope = "LABEL"
                key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body_Anomaly"
              }
            },
            {
              label_match_statement = {
                scope = "LABEL"
                key   = "awswaf:managed:aws:core-rule-set:GenericRFI_Body"
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "LabelMatchOrRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "LabelMatchOrRule"][0].statement[0].or_statement[0].statement[0].label_match_statement) > 0
    error_message = "First statement should be a label_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "LabelMatchOrRule"][0].statement[0].or_statement[0].statement[1].label_match_statement) > 0
    error_message = "Second statement should be a label_match_statement"
  }
}

run "test_or_statement_with_regex_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexMatchOrRule"
        priority = 60
        action   = "captcha"
        or_statement = {
          statements = [
            {
              regex_match_statement = {
                regex_string = "^/api/v[0-9]+/"
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
            },
            {
              regex_match_statement = {
                regex_string = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
                field_to_match = {
                  single_query_argument = {
                    name = "email"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RegexMatchOrRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "RegexMatchOrRule"][0].statement[0].or_statement[0].statement[0].regex_match_statement) > 0
    error_message = "First statement should be a regex_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "RegexMatchOrRule"][0].statement[0].or_statement[0].statement[1].regex_match_statement) > 0
    error_message = "Second statement should be a regex_match_statement"
  }
}

run "test_or_statement_geo_and_ip_set_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "GeoOrIPSetRule"
        priority = 20
        action   = "block"
        or_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN", "RU", "KP"]
              }
            },
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/blocked-ips/12345678-1234-1234-1234-123456789012"
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "GeoOrIPSetRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement) == 2
    ])
    error_message = "Or statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[0].geo_match_statement) > 0
    ])
    error_message = "First statement should be geo_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[1].ip_set_reference_statement) > 0
    ])
    error_message = "Second statement should be ip_set_reference_statement"
  }
}

run "test_or_statement_sqli_xss_byte_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "AttackDetectionRule"
        priority = 30
        action   = "block"
        or_statement = {
          statements = [
            {
              sqli_match_statement = {
                field_to_match = {
                  query_string = {}
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "URL_DECODE"
                  }
                ]
              }
            },
            {
              xss_match_statement = {
                field_to_match = {
                  body = {
                    oversize_handling = "CONTINUE"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "HTML_ENTITY_DECODE"
                  }
                ]
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "CONTAINS"
                search_string         = "/admin"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "AttackDetectionRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement) == 3
    ])
    error_message = "Or statement should have exactly 3 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[0].sqli_match_statement) > 0
    ])
    error_message = "First statement should be sqli_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[1].xss_match_statement) > 0
    ])
    error_message = "Second statement should be xss_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[2].byte_match_statement) > 0
    ])
    error_message = "Third statement should be byte_match_statement"
  }
}

run "test_or_statement_regex_and_size_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexOrSizeRule"
        priority = 40
        action   = "count"
        or_statement = {
          statements = [
            {
              regex_match_statement = {
                regex_string = "(?i)(bot|crawler|spider)"
                field_to_match = {
                  single_header = {
                    name = "user-agent"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              size_constraint_statement = {
                comparison_operator = "GT"
                size                = 8192
                field_to_match = {
                  body = {}
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "NONE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "RegexOrSizeRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement) == 2
    ])
    error_message = "Or statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[0].regex_match_statement) > 0
    ])
    error_message = "First statement should be regex_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[1].size_constraint_statement) > 0
    ])
    error_message = "Second statement should be size_constraint_statement"
  }
}

run "test_or_statement_label_and_regex_pattern_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "LabelOrPatternRule"
        priority = 50
        action   = "allow"
        or_statement = {
          statements = [
            {
              label_match_statement = {
                key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body_Anomaly"
                scope = "LABEL"
              }
            },
            {
              regex_pattern_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/allowed-patterns/12345678-1234-1234-1234-123456789012"
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
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "LabelOrPatternRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement) == 2
    ])
    error_message = "Or statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[0].label_match_statement) > 0
    ])
    error_message = "First statement should be label_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[1].regex_pattern_set_reference_statement) > 0
    ])
    error_message = "Second statement should be regex_pattern_set_reference_statement"
  }
}

run "test_or_statement_comprehensive_threat_detection" {
  command = plan

  variables {
    rule = [
      {
        name     = "ComprehensiveThreatDetection"
        priority = 60
        action   = "block"
        or_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN", "RU", "KP", "IR"]
              }
            },
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/malicious-ips/12345678-1234-1234-1234-123456789012"
              }
            },
            {
              sqli_match_statement = {
                field_to_match = {
                  all_query_arguments = {}
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "URL_DECODE"
                  }
                ]
              }
            },
            {
              regex_match_statement = {
                regex_string = "(?i)(union|select|insert|delete|drop|create|alter)"
                field_to_match = {
                  body = {
                    oversize_handling = "CONTINUE"
                  }
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  single_header = {
                    name = "user-agent"
                  }
                }
                positional_constraint = "CONTAINS"
                search_string         = "sqlmap"
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "ComprehensiveThreatDetection"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement) == 5
    ])
    error_message = "Or statement should have exactly 5 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].or_statement[0].statement[0].geo_match_statement) > 0 &&
      length(rule.statement[0].or_statement[0].statement[1].ip_set_reference_statement) > 0 &&
      length(rule.statement[0].or_statement[0].statement[2].sqli_match_statement) > 0 &&
      length(rule.statement[0].or_statement[0].statement[3].regex_match_statement) > 0 &&
      length(rule.statement[0].or_statement[0].statement[4].byte_match_statement) > 0
    ])
    error_message = "Should have all five statement types in correct order"
  }
}
