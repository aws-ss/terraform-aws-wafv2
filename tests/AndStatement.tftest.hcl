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

run "test_example_and_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        and_statement = {
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

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have exactly one rule configured"
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
      length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Rule should have count action configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0
    ])
    error_message = "Rule should have and_statement configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "And statement should have exactly 2 child statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement) > 0
    ])
    error_message = "First statement should be a not_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "/admin"
    ])
    error_message = "First statement should be NOT byte_match for '/admin'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].search_string == "/administrator"
    ])
    error_message = "Second statement should be byte_match for '/administrator'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS"
    ])
    error_message = "NOT statement should use CONTAINS positional constraint"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].positional_constraint == "CONTAINS"
    ])
    error_message = "Direct byte match statement should use CONTAINS positional constraint"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match) > 0 &&
      rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].uri_path != null
    ])
    error_message = "NOT statement should match on uri_path"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].field_to_match) > 0 &&
      rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].field_to_match[0].uri_path != null
    ])
    error_message = "Direct byte match statement should match on uri_path"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation) == 1 &&
      anytrue([
        for transformation in rule.statement[0].and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation :
        transformation.type == "LOWERCASE"
      ])
    ])
    error_message = "NOT statement should have LOWERCASE text transformation"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].text_transformation) == 1 &&
      anytrue([
        for transformation in rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].text_transformation :
        transformation.type == "LOWERCASE"
      ])
    ])
    error_message = "Direct byte match statement should have LOWERCASE text transformation"
  }
}

run "test_and_statement_with_byte_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchAndRule"
        priority = 20
        action   = "block"
        and_statement = {
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
          metric_name                = "ByteMatchAndRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 byte_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "/api/"
    ])
    error_message = "First statement should be byte_match for '/api/'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].byte_match_statement[0].search_string == "POST"
    ])
    error_message = "Second statement should be byte_match for 'POST'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].block != null
    ])
    error_message = "Rule should have block action configured"
  }
}

run "test_and_statement_with_geo_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "GeoMatchAndRule"
        priority = 25
        action   = "block"
        and_statement = {
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
          metric_name                = "GeoMatchAndRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "GeoMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 geo_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].geo_match_statement) > 0 &&
      contains(rule.statement[0].and_statement[0].statement[0].geo_match_statement[0].country_codes, "CN") &&
      contains(rule.statement[0].and_statement[0].statement[0].geo_match_statement[0].country_codes, "RU")
    ])
    error_message = "First statement should be geo_match for CN and RU"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].geo_match_statement) > 0 &&
      contains(rule.statement[0].and_statement[0].statement[1].geo_match_statement[0].country_codes, "KP") &&
      contains(rule.statement[0].and_statement[0].statement[1].geo_match_statement[0].country_codes, "IR")
    ])
    error_message = "Second statement should be geo_match for KP and IR"
  }
}

run "test_and_statement_with_ip_set_reference_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "IpSetAndRule"
        priority = 30
        action   = "allow"
        and_statement = {
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
          metric_name                = "IpSetAndRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "IpSetAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 ip_set_reference statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].ip_set_reference_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].ip_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/allowed-ips/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "First statement should be ip_set_reference for allowed-ips"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].ip_set_reference_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].ip_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/trusted-ips/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "Second statement should be ip_set_reference for trusted-ips"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].allow != null
    ])
    error_message = "Rule should have allow action configured"
  }
}

run "test_and_statement_with_size_constraint_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "SizeConstraintAndRule"
        priority = 35
        action   = "block"
        and_statement = {
          statements = [
            {
              size_constraint_statement = {
                field_to_match = {
                  body = {
                    oversize_handling = "CONTINUE"
                  }
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
          metric_name                = "SizeConstraintAndRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SizeConstraintAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 size_constraint statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].size_constraint_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].size_constraint_statement[0].comparison_operator == "GT" &&
      rule.statement[0].and_statement[0].statement[0].size_constraint_statement[0].size == 1024
    ])
    error_message = "First statement should be size_constraint with GT 1024"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].size_constraint_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].size_constraint_statement[0].comparison_operator == "LT" &&
      rule.statement[0].and_statement[0].statement[1].size_constraint_statement[0].size == 10485760
    ])
    error_message = "Second statement should be size_constraint with LT 10485760"
  }
}

run "test_and_statement_with_sqli_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "SqliMatchAndRule"
        priority = 40
        action   = "block"
        and_statement = {
          statements = [
            {
              sqli_match_statement = {
                field_to_match = {
                  body = {
                    oversize_handling = "CONTINUE"
                  }
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
                sensitivity_level = "HIGH"
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
                sensitivity_level = "LOW"
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SqliMatchAndRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SqliMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 sqli_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].sqli_match_statement) > 0
    ])
    error_message = "First statement should be sqli_match statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].sqli_match_statement) > 0
    ])
    error_message = "Second statement should be sqli_match statement"
  }
}

run "test_and_statement_with_xss_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "XssMatchAndRule"
        priority = 45
        action   = "block"
        and_statement = {
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
                  body = {
                    oversize_handling = "CONTINUE"
                  }
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
          metric_name                = "XssMatchAndRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "XssMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 xss_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].xss_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].xss_match_statement[0].field_to_match) > 0 &&
      rule.statement[0].and_statement[0].statement[0].xss_match_statement[0].field_to_match[0].single_query_argument[0].name == "search"
    ])
    error_message = "First statement should be xss_match on query argument 'search'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].xss_match_statement) > 0
    ])
    error_message = "Second statement should be xss_match statement"
  }
}

run "test_and_statement_with_regex_pattern_set_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexPatternAndRule"
        priority = 50
        action   = "captcha"
        and_statement = {
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
          metric_name                = "RegexPatternAndRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexPatternAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 regex_pattern_set_reference statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].regex_pattern_set_reference_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].regex_pattern_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/malicious-paths/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "First statement should be regex_pattern_set_reference for malicious-paths"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].regex_pattern_set_reference_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].regex_pattern_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/suspicious-patterns/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "Second statement should be regex_pattern_set_reference for suspicious-patterns"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Rule should have captcha action configured"
  }
}

run "test_and_statement_with_label_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "LabelMatchAndRule"
        priority = 55
        action   = "count"
        and_statement = {
          statements = [
            {
              label_match_statement = {
                key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body_Anomaly"
                scope = "LABEL"
              }
            },
            {
              label_match_statement = {
                key   = "awswaf:managed:aws:core-rule-set:GenericRFI_Body"
                scope = "LABEL"
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "LabelMatchAndRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "LabelMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 label_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].label_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].label_match_statement[0].key == "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body_Anomaly"
    ])
    error_message = "First statement should be label_match for SizeRestrictions_Body_Anomaly"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].label_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].label_match_statement[0].key == "awswaf:managed:aws:core-rule-set:GenericRFI_Body"
    ])
    error_message = "Second statement should be label_match for GenericRFI_Body"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].count != null
    ])
    error_message = "Rule should have count action configured"
  }
}

run "test_and_statement_with_regex_match_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "RegexMatchAndRule"
        priority = 60
        action   = "captcha"
        and_statement = {
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
          metric_name                = "RegexMatchAndRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexMatchAndRule" &&
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "Should have 2 regex_match statements in and_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].regex_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[0].regex_match_statement[0].regex_string == "^/api/v[0-9]+/"
    ])
    error_message = "First statement should be regex_match for API version pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].regex_match_statement) > 0 &&
      rule.statement[0].and_statement[0].statement[1].regex_match_statement[0].regex_string == "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    ])
    error_message = "Second statement should be regex_match for email pattern"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 1 &&
      length(rule.statement[0].and_statement[0].statement[0].regex_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[0].regex_match_statement[0].field_to_match) > 0 &&
      rule.statement[0].and_statement[0].statement[0].regex_match_statement[0].field_to_match[0].uri_path != null
    ])
    error_message = "First statement should match on uri_path"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].and_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement) >= 2 &&
      length(rule.statement[0].and_statement[0].statement[1].regex_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[1].regex_match_statement[0].field_to_match) > 0 &&
      rule.statement[0].and_statement[0].statement[1].regex_match_statement[0].field_to_match[0].single_query_argument[0].name == "email"
    ])
    error_message = "Second statement should match on query argument 'email'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Rule should have captcha action configured"
  }
}

run "test_and_statement_geo_and_byte_match_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "GeoAndByteMatchRule"
        priority = 10
        action   = "block"
        and_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN", "RU", "KP"]
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "STARTS_WITH"
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
          metric_name                = "GeoAndByteMatchRule"
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
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "And statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[0].geo_match_statement) > 0
    ])
    error_message = "First statement should be geo_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0
    ])
    error_message = "Second statement should be byte_match_statement"
  }
}

run "test_and_statement_sqli_xss_size_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "SecurityTripleCheckRule"
        priority = 20
        action   = "block"
        and_statement = {
          statements = [
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
              xss_match_statement = {
                field_to_match = {
                  body = {}
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
          metric_name                = "SecurityTripleCheckRule"
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
      length(rule.statement[0].and_statement[0].statement) == 3
    ])
    error_message = "And statement should have exactly 3 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[0].sqli_match_statement) > 0
    ])
    error_message = "First statement should be sqli_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[1].xss_match_statement) > 0
    ])
    error_message = "Second statement should be xss_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[2].size_constraint_statement) > 0
    ])
    error_message = "Third statement should be size_constraint_statement"
  }
}

run "test_and_statement_ip_set_and_regex_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "IPAndRegexRule"
        priority = 30
        action   = "count"
        and_statement = {
          statements = [
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/suspicious-ips/12345678-1234-1234-1234-123456789012"
              }
            },
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
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "IPAndRegexRule"
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
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "And statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[0].ip_set_reference_statement) > 0
    ])
    error_message = "First statement should be ip_set_reference_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[1].regex_match_statement) > 0
    ])
    error_message = "Second statement should be regex_match_statement"
  }
}

run "test_and_statement_label_and_regex_pattern_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "LabelAndPatternRule"
        priority = 40
        action   = "allow"
        and_statement = {
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
          metric_name                = "LabelAndPatternRule"
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
      length(rule.statement[0].and_statement[0].statement) == 2
    ])
    error_message = "And statement should have exactly 2 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[0].label_match_statement) > 0
    ])
    error_message = "First statement should be label_match_statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[1].regex_pattern_set_reference_statement) > 0
    ])
    error_message = "Second statement should be regex_pattern_set_reference_statement"
  }
}

run "test_and_statement_comprehensive_security_combination" {
  command = plan

  variables {
    rule = [
      {
        name     = "ComprehensiveSecurityRule"
        priority = 50
        action   = "block"
        and_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN", "RU"]
              }
            },
            {
              byte_match_statement = {
                field_to_match = {
                  uri_path = {}
                }
                positional_constraint = "CONTAINS"
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
              size_constraint_statement = {
                comparison_operator = "GT"
                size                = 1024
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
          metric_name                = "ComprehensiveSecurityRule"
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
      length(rule.statement[0].and_statement[0].statement) == 4
    ])
    error_message = "And statement should have exactly 4 sub-statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement[0].and_statement[0].statement[0].geo_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[1].byte_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[2].sqli_match_statement) > 0 &&
      length(rule.statement[0].and_statement[0].statement[3].size_constraint_statement) > 0
    ])
    error_message = "Should have all four statement types in correct order"
  }
}
