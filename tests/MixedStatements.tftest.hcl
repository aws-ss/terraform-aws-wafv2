mock_provider "aws" {}

variables {
  name           = "MixedStatementsWebACL"
  scope          = "REGIONAL"
  default_action = "allow"
  resource_arn   = []
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "MixedStatementsWebACL"
    sampled_requests_enabled   = true
  }
}

run "test_mixed_basic_detection_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "GeoBlockRule"
        priority = 10
        action   = "block"
        geo_match_statement = {
          country_codes = ["CN", "RU", "KP"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "GeoBlockRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "SQLInjectionRule"
        priority = 20
        action   = "block"
        sqli_match_statement = {
          field_to_match = {
            all_query_arguments = {}
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
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SQLInjectionRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "XSSRule"
        priority = 30
        action   = "block"
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
              type     = "NORMALIZE_PATH"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "XSSRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "SizeConstraintRule"
        priority = 40
        action   = "count"
        size_constraint_statement = {
          field_to_match = {
            body = {}
          }
          comparison_operator = "GT"
          size                = 8192
          text_transformation = [
            {
              priority = 1
              type     = "NONE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SizeConstraintRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 4
    error_message = "Should have four different basic detection statement rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "GeoBlockRule" && length(rule.statement[0].geo_match_statement) > 0
    ])
    error_message = "Should have geo match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SQLInjectionRule" && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "Should have SQLI match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "XSSRule" && length(rule.statement[0].xss_match_statement) > 0
    ])
    error_message = "Should have XSS match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SizeConstraintRule" && length(rule.statement[0].size_constraint_statement) > 0
    ])
    error_message = "Should have size constraint statement rule"
  }
}

run "test_mixed_pattern_matching_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchRule"
        priority = 10
        action   = "block"
        byte_match_statement = {
          search_string = "malicious"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
          positional_constraint = "CONTAINS"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ByteMatchRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RegexMatchRule"
        priority = 20
        action   = "block"
        regex_match_statement = {
          field_to_match = {
            single_header = {
              name = "user-agent"
            }
          }
          regex_string = "(?i)(bot|crawler|spider|scraper)"
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RegexMatchRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RegexPatternSetRule"
        priority = 30
        action   = "count"
        regex_pattern_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/malicious-patterns/12345678-1234-1234-1234-123456789012"
          field_to_match = {
            headers = {
              match_scope       = "ALL"
              oversize_handling = "CONTINUE"
              match_pattern = {
                all = {}
              }
            }
          }
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RegexPatternSetRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 3
    error_message = "Should have three pattern matching rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchRule" && length(rule.statement[0].byte_match_statement) > 0
    ])
    error_message = "Should have byte match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexMatchRule" && length(rule.statement[0].regex_match_statement) > 0
    ])
    error_message = "Should have regex match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RegexPatternSetRule" && length(rule.statement[0].regex_pattern_set_reference_statement) > 0
    ])
    error_message = "Should have regex pattern set reference statement rule"
  }
}

run "test_mixed_reference_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "IPSetRule"
        priority = 10
        action   = "block"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/blocked-ips/12345678-1234-1234-1234-123456789012"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "IPSetRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RuleGroupRule"
        priority = 20
        action   = "count"
        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/rulegroup/custom-rules/12345678-1234-1234-1234-123456789012"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RuleGroupRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "LabelMatchRule"
        priority = 30
        action   = "allow"
        label_match_statement = {
          key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body_Anomaly"
          scope = "LABEL"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "LabelMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 3
    error_message = "Should have three reference statement rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "IPSetRule" && length(rule.statement[0].ip_set_reference_statement) > 0
    ])
    error_message = "Should have IP set reference statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RuleGroupRule" && length(rule.statement[0].rule_group_reference_statement) > 0
    ])
    error_message = "Should have rule group reference statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "LabelMatchRule" && length(rule.statement[0].label_match_statement) > 0
    ])
    error_message = "Should have label match statement rule"
  }
}

run "test_mixed_managed_and_rate_statements" {
  command = plan

  variables {
    rule = [
      {
        name            = "AWSManagedRulesCommonRuleSet"
        priority        = 10
        override_action = "none"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
          version     = "Version_1.0"
          rule_action_override = [
            {
              name          = "SizeRestrictions_BODY"
              action_to_use = "count"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "AWSManagedRulesCommonRuleSet"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RateLimitRule"
        priority = 20
        action   = "block"
        rate_based_statement = {
          limit                 = 2000
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
          scope_down_statement = {
            byte_match_statement = {
              field_to_match = {
                uri_path = {}
              }
              positional_constraint = "STARTS_WITH"
              search_string         = "/api/"
              text_transformation = [
                {
                  priority = 1
                  type     = "LOWERCASE"
                }
              ]
            }
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RateLimitRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have two rules - managed and rate-based"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "AWSManagedRulesCommonRuleSet" && length(rule.statement[0].managed_rule_group_statement) > 0
    ])
    error_message = "Should have managed rule group statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimitRule" && length(rule.statement[0].rate_based_statement) > 0
    ])
    error_message = "Should have rate based statement rule"
  }
}

run "test_mixed_network_statements" {
  command = plan

  variables {
    rule = [
      {
        name     = "ASNBasedRule"
        priority = 10
        action   = "count"
        asn_match_statement = {
          asn_list = [64496, 64497, 64498]
          forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Forwarded-For"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ASNBasedRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "GeoWithForwardedIP"
        priority = 20
        action   = "block"
        geo_match_statement = {
          country_codes = ["CN", "RU"]
          forwarded_ip_config = {
            fallback_behavior = "MATCH"
            header_name       = "X-Forwarded-For"
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "GeoWithForwardedIP"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have two network-based rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ASNBasedRule" && length(rule.statement[0].asn_match_statement) > 0
    ])
    error_message = "Should have ASN match statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "GeoWithForwardedIP" && length(rule.statement[0].geo_match_statement) > 0
    ])
    error_message = "Should have geo match statement with forwarded IP config"
  }
}

run "test_mixed_with_custom_responses" {
  command = plan

  variables {
    custom_response_body = [
      {
        key          = "TooManyRequestsBody"
        content      = "Rate limit exceeded. Please try again later."
        content_type = "TEXT_PLAIN"
      },
      {
        key          = "BlockedCountryBody"
        content      = "Access from your location is not permitted."
        content_type = "TEXT_PLAIN"
      }
    ]

    rule = [
      {
        name     = "RateLimitWithCustomResponse"
        priority = 10
        action   = "block"
        custom_response = {
          response_code            = 429
          custom_response_body_key = "TooManyRequestsBody"
          response_header = [
            {
              name  = "Retry-After"
              value = "300"
            }
          ]
        }
        rate_based_statement = {
          limit                 = 100
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RateLimitWithCustomResponse"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "GeoBlockWithCustomResponse"
        priority = 20
        action   = "block"
        custom_response = {
          response_code            = 403
          custom_response_body_key = "BlockedCountryBody"
          response_header = [
            {
              name  = "X-Blocked-Reason"
              value = "Geographic restriction"
            }
          ]
        }
        geo_match_statement = {
          country_codes = ["CN", "KP", "IR"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "GeoBlockWithCustomResponse"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 2
    error_message = "Should have two rules with custom responses"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.custom_response_body) == 2
    error_message = "Should have two custom response bodies"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimitWithCustomResponse" &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      rule.action[0].block[0].custom_response[0].response_code == 429
    ])
    error_message = "Rate limit rule should have custom response with 429 status"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "GeoBlockWithCustomResponse" &&
      length(rule.action[0].block[0].custom_response) > 0 &&
      rule.action[0].block[0].custom_response[0].response_code == 403
    ])
    error_message = "Geo block rule should have custom response with 403 status"
  }
}

run "test_mixed_and_statement_with_basic_rules" {
  command = plan

  variables {
    rule = [
      {
        name     = "ComplexAndRule"
        priority = 10
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
          cloudwatch_metrics_enabled = true
          metric_name                = "ComplexAndRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "SimpleGeoRule"
        priority = 20
        action   = "block"
        geo_match_statement = {
          country_codes = ["KP", "IR"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SimpleGeoRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "SimpleSQLIRule"
        priority = 30
        action   = "count"
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
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "SimpleSQLIRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 3
    error_message = "Should have exactly 3 rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ComplexAndRule" && length(rule.statement[0].and_statement) > 0
    ])
    error_message = "Should have and_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SimpleGeoRule" && length(rule.statement[0].geo_match_statement) > 0
    ])
    error_message = "Should have simple geo_match_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SimpleSQLIRule" && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "Should have simple sqli_match_statement rule"
  }
}

run "test_mixed_or_statement_with_basic_rules" {
  command = plan

  variables {
    rule = [
      {
        name     = "ThreatDetectionOrRule"
        priority = 10
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
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ThreatDetectionOrRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RateLimitRule"
        priority = 20
        action   = "block"
        rate_based_statement = {
          limit                 = 1000
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RateLimitRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "ByteMatchRule"
        priority = 30
        action   = "count"
        byte_match_statement = {
          search_string = "malicious"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
          positional_constraint = "CONTAINS"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ByteMatchRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 3
    error_message = "Should have exactly 3 rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ThreatDetectionOrRule" && length(rule.statement[0].or_statement) > 0
    ])
    error_message = "Should have or_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimitRule" && length(rule.statement[0].rate_based_statement) > 0
    ])
    error_message = "Should have rate_based_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ByteMatchRule" && length(rule.statement[0].byte_match_statement) > 0
    ])
    error_message = "Should have byte_match_statement rule"
  }
}

run "test_mixed_and_or_statements_with_managed_rules" {
  command = plan

  variables {
    rule = [
      {
        name     = "LogicalAndRule"
        priority = 10
        action   = "block"
        and_statement = {
          statements = [
            {
              geo_match_statement = {
                country_codes = ["CN"]
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
          cloudwatch_metrics_enabled = true
          metric_name                = "LogicalAndRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "LogicalOrRule"
        priority = 20
        action   = "count"
        or_statement = {
          statements = [
            {
              ip_set_reference_statement = {
                arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/suspicious-ips/12345678-1234-1234-1234-123456789012"
              }
            },
            {
              regex_match_statement = {
                regex_string = "(?i)(bot|crawler)"
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
          cloudwatch_metrics_enabled = true
          metric_name                = "LogicalOrRule"
          sampled_requests_enabled   = true
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
      rule.name == "LogicalAndRule" && length(rule.statement[0].and_statement) > 0
    ])
    error_message = "Should have and_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "LogicalOrRule" && length(rule.statement[0].or_statement) > 0
    ])
    error_message = "Should have or_statement rule"
  }
}

run "test_mixed_comprehensive_rule_types" {
  command = plan

  variables {
    rule = [
      {
        name     = "BasicGeoBlock"
        priority = 10
        action   = "block"
        geo_match_statement = {
          country_codes = ["KP", "IR"]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "BasicGeoBlock"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "ComplexAndRule"
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
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ComplexAndRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "ThreatOrRule"
        priority = 30
        action   = "count"
        or_statement = {
          statements = [
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
              regex_match_statement = {
                regex_string = "(?i)(union|select|insert|delete)"
                field_to_match = {
                  query_string = {}
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
          metric_name                = "ThreatOrRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "RateLimitRule"
        priority = 40
        action   = "block"
        rate_based_statement = {
          limit                 = 2000
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RateLimitRule"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "IPSetRule"
        priority = 50
        action   = "allow"
        ip_set_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/trusted-ips/12345678-1234-1234-1234-123456789012"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "IPSetRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 5
    error_message = "Should have exactly 5 rules"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "BasicGeoBlock" && length(rule.statement[0].geo_match_statement) > 0
    ])
    error_message = "Should have basic geo_match_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ComplexAndRule" && length(rule.statement[0].and_statement) > 0
    ])
    error_message = "Should have and_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "ThreatOrRule" && length(rule.statement[0].or_statement) > 0
    ])
    error_message = "Should have or_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RateLimitRule" && length(rule.statement[0].rate_based_statement) > 0
    ])
    error_message = "Should have rate_based_statement rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "IPSetRule" && length(rule.statement[0].ip_set_reference_statement) > 0
    ])
    error_message = "Should have ip_set_reference_statement rule"
  }
}