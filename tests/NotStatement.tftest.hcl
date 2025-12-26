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

run "test_example_not_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "Rule01"
        priority = 10
        action   = "count"
        not_statement = {
          geo_match_statement = {
            country_codes = ["AF"]
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
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"]) == 1
    error_message = "Expected exactly one rule named 'Rule01'"
  }

  # Test that the rule contains a not_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].not_statement) > 0
    error_message = "Rule should contain a not_statement"
  }

  # Test that the not_statement contains exactly one statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].not_statement[0].statement) == 1
    error_message = "not_statement should contain exactly one nested statement"
  }

  # Test that the nested statement is a geo_match_statement
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].not_statement[0].statement[0].geo_match_statement) > 0
    error_message = "not_statement should contain a geo_match_statement"
  }

  # Test that the geo_match_statement contains the correct country code
  assert {
    condition     = contains([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes, "AF")
    error_message = "geo_match_statement should contain country code 'AF'"
  }

  # Test that only one country code is configured
  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "Rule01"][0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes) == 1
    error_message = "geo_match_statement should contain exactly one country code"
  }
}

run "test_not_statement_with_byte_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotByteMatchRule"
        priority = 20
        action   = "block"
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
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "NotByteMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotByteMatchRule"][0].statement[0].not_statement[0].statement[0].byte_match_statement) > 0
    error_message = "not_statement should contain a byte_match_statement"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotByteMatchRule"][0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "/admin"
    error_message = "byte_match_statement should search for '/admin'"
  }
}

run "test_not_statement_with_geo_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotGeoMatchRule"
        priority = 25
        action   = "allow"
        not_statement = {
          geo_match_statement = {
            country_codes = ["CN", "RU"]
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "NotGeoMatchRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotGeoMatchRule"][0].statement[0].not_statement[0].statement[0].geo_match_statement) > 0
    error_message = "not_statement should contain a geo_match_statement"
  }

  assert {
    condition     = contains([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotGeoMatchRule"][0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes, "CN")
    error_message = "geo_match_statement should contain country code 'CN'"
  }
}

run "test_not_statement_with_ip_set_reference_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotIpSetRule"
        priority = 30
        action   = "block"
        not_statement = {
          ip_set_reference_statement = {
            arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/blocked-ips/12345678-1234-1234-1234-123456789012"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "NotIpSetRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotIpSetRule"][0].statement[0].not_statement[0].statement[0].ip_set_reference_statement) > 0
    error_message = "not_statement should contain an ip_set_reference_statement"
  }

  assert {
    condition     = can(regex("blocked-ips", [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotIpSetRule"][0].statement[0].not_statement[0].statement[0].ip_set_reference_statement[0].arn))
    error_message = "ip_set_reference_statement should reference blocked-ips IP set"
  }
}

run "test_not_statement_with_size_constraint_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotSizeConstraintRule"
        priority = 35
        action   = "count"
        not_statement = {
          size_constraint_statement = {
            comparison_operator = "LT"
            field_to_match = {
              body = {}
            }
            size = 1024
            text_transformation = [
              {
                priority = 0
                type     = "NONE"
              }
            ]
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "NotSizeConstraintRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotSizeConstraintRule"][0].statement[0].not_statement[0].statement[0].size_constraint_statement) > 0
    error_message = "not_statement should contain a size_constraint_statement"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotSizeConstraintRule"][0].statement[0].not_statement[0].statement[0].size_constraint_statement[0].size == 1024
    error_message = "size_constraint_statement should have size limit of 1024"
  }
}

run "test_not_statement_with_sqli_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotSqliMatchRule"
        priority = 40
        action   = "block"
        not_statement = {
          sqli_match_statement = {
            field_to_match = {
              all_query_arguments = {}
            }
            text_transformation = [
              {
                priority = 0
                type     = "URL_DECODE"
              },
              {
                priority = 1
                type     = "HTML_ENTITY_DECODE"
              }
            ]
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "NotSqliMatchRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotSqliMatchRule"][0].statement[0].not_statement[0].statement[0].sqli_match_statement) > 0
    error_message = "not_statement should contain a sqli_match_statement"
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotSqliMatchRule"][0].statement[0].not_statement[0].statement[0].sqli_match_statement[0].text_transformation) == 2
    error_message = "sqli_match_statement should have 2 text transformations"
  }
}

run "test_not_statement_with_xss_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotXssMatchRule"
        priority = 45
        action   = "captcha"
        not_statement = {
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
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "NotXssMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotXssMatchRule"][0].statement[0].not_statement[0].statement[0].xss_match_statement) > 0
    error_message = "not_statement should contain an xss_match_statement"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotXssMatchRule"][0].statement[0].not_statement[0].statement[0].xss_match_statement[0].field_to_match[0].single_query_argument[0].name == "search"
    error_message = "xss_match_statement should target 'search' query parameter"
  }
}

run "test_not_statement_with_regex_pattern_set_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotRegexPatternRule"
        priority = 50
        action   = "block"
        not_statement = {
          regex_pattern_set_reference_statement = {
            arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/safe-patterns/12345678-1234-1234-1234-123456789012"
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
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "NotRegexPatternRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotRegexPatternRule"][0].statement[0].not_statement[0].statement[0].regex_pattern_set_reference_statement) > 0
    error_message = "not_statement should contain a regex_pattern_set_reference_statement"
  }

  assert {
    condition     = can(regex("safe-patterns", [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotRegexPatternRule"][0].statement[0].not_statement[0].statement[0].regex_pattern_set_reference_statement[0].arn))
    error_message = "regex_pattern_set_reference_statement should reference safe-patterns regex set"
  }
}

run "test_not_statement_with_label_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotLabelMatchRule"
        priority = 55
        action   = "allow"
        not_statement = {
          label_match_statement = {
            key   = "awswaf:managed:aws:core-rule-set:GenericRFI_Body"
            scope = "LABEL"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "NotLabelMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotLabelMatchRule"][0].statement[0].not_statement[0].statement[0].label_match_statement) > 0
    error_message = "not_statement should contain a label_match_statement"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotLabelMatchRule"][0].statement[0].not_statement[0].statement[0].label_match_statement[0].key == "awswaf:managed:aws:core-rule-set:GenericRFI_Body"
    error_message = "label_match_statement should match GenericRFI_Body label"
  }
}

run "test_not_statement_with_regex_match_statement" {
  command = plan

  variables {
    rule = [
      {
        name     = "NotRegexMatchRule"
        priority = 60
        action   = "count"
        not_statement = {
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
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "NotRegexMatchRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotRegexMatchRule"][0].statement[0].not_statement[0].statement[0].regex_match_statement) > 0
    error_message = "not_statement should contain a regex_match_statement"
  }

  assert {
    condition     = [for rule in aws_wafv2_web_acl.this.rule : rule if rule.name == "NotRegexMatchRule"][0].statement[0].not_statement[0].statement[0].regex_match_statement[0].regex_string == "^/api/v[0-9]+/"
    error_message = "regex_match_statement should match API versioning pattern"
  }
}


