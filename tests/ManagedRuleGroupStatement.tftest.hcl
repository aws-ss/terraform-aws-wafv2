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

run "test_example_managed_rule" {
  command = plan

  variables {

    rule = [
      {
        name            = "Rule01"
        priority        = 10
        override_action = "count"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
          # Deprecated - excluded_rule = ["NoUserAgent_HEADER", "UserAgent_BadBots_HEADER"]

          rule_action_override = [
            {
              name          = "NoUserAgent_HEADER"
              action_to_use = "captcha"
            },
            {
              name          = "UserAgent_BadBots_HEADER"
              action_to_use = "captcha"
            }
          ]

          scope_down_statement = {
            geo_match_statement = {
              country_codes : ["CN"]
              forwarded_ip_config = {
                fallback_behavior = "MATCH"
                header_name       = "X-Forwarded-For"
              }
            }
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
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with managed rule group statement"
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
      length(rule.override_action) > 0 && rule.override_action[0].count != null
    ])
    error_message = "Rule should have count override action configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].managed_rule_group_statement) > 0
    ])
    error_message = "Managed rule group statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].name == "AWSManagedRulesCommonRuleSet"
    ])
    error_message = "Should use AWSManagedRulesCommonRuleSet"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].vendor_name == "AWS"
    ])
    error_message = "Should have AWS as vendor name"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].rule_action_override) == 2
    ])
    error_message = "Should have two rule action overrides configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].rule_action_override) > 0 &&
      anytrue([
        for override in rule.statement[0].managed_rule_group_statement[0].rule_action_override :
        override.name == "NoUserAgent_HEADER" && length(override.action_to_use) > 0 &&
        override.action_to_use[0].captcha != null
      ])
    ])
    error_message = "NoUserAgent_HEADER should be overridden with captcha action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].rule_action_override) > 0 &&
      anytrue([
        for override in rule.statement[0].managed_rule_group_statement[0].rule_action_override :
        override.name == "UserAgent_BadBots_HEADER" && length(override.action_to_use) > 0 &&
        override.action_to_use[0].captcha != null
      ])
    ])
    error_message = "UserAgent_BadBots_HEADER should be overridden with captcha action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement) > 0
    ])
    error_message = "Should have geo match statement in scope down configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement) > 0 &&
      contains(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement[0].country_codes, "CN")
    ])
    error_message = "Should include China (CN) in country codes for scope down geo matching"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH"
    ])
    error_message = "Should have MATCH fallback behavior for forwarded IP config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement[0].forwarded_ip_config) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For"
    ])
    error_message = "Should use X-Forwarded-For header for forwarded IP config"
  }
}

run "test_managed_rule_without_overrides" {
  command = plan

  variables {
    rule = [
      {
        name     = "BasicManagedRule"
        priority = 5
        action   = "block"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "BasicManagedRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one basic managed rule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].name == "AWSManagedRulesKnownBadInputsRuleSet"
    ])
    error_message = "Should use AWSManagedRulesKnownBadInputsRuleSet"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].rule_action_override) == 0
    ])
    error_message = "Should have no rule action overrides"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) == 0
    ])
    error_message = "Should have no scope down statement"
  }
}

run "test_managed_rule_with_version" {
  command = plan

  variables {
    rule = [
      {
        name     = "VersionedManagedRule"
        priority = 15
        action   = "allow"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesLinuxRuleSet"
          vendor_name = "AWS"
          version     = "1.0"
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "VersionedManagedRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].version == "1.0"
    ])
    error_message = "Should have version 1.0 specified"
  }
}

run "test_managed_rule_with_block_overrides" {
  command = plan

  variables {
    rule = [
      {
        name            = "BlockOverrideRule"
        priority        = 20
        override_action = "none"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"

          rule_action_override = [
            {
              name          = "SQLiExtendedPatterns_QUERYARGUMENTS"
              action_to_use = "block"
            },
            {
              name          = "SQLi_QUERYARGUMENTS"
              action_to_use = "block"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "BlockOverrideRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.override_action) > 0 && rule.override_action[0].none != null
    ])
    error_message = "Rule should have none override action configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      anytrue([
        for override in rule.statement[0].managed_rule_group_statement[0].rule_action_override :
        override.name == "SQLiExtendedPatterns_QUERYARGUMENTS" && length(override.action_to_use) > 0 &&
        override.action_to_use[0].block != null
      ])
    ])
    error_message = "SQLiExtendedPatterns_QUERYARGUMENTS should be overridden with block action"
  }
}

run "test_managed_rule_with_ip_set_scope_down" {
  command = plan

  variables {
    rule = [
      {
        name     = "IPSetScopeDownRule"
        priority = 25
        action   = "count"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"

          scope_down_statement = {
            ip_set_reference_statement = {
              arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/example-ip-set/123456"
              ip_set_forwarded_ip_config = {
                fallback_behavior = "NO_MATCH"
                header_name       = "X-Real-IP"
                position          = "FIRST"
              }
            }
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "IPSetScopeDownRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement) > 0
    ])
    error_message = "Should have IP set reference statement in scope down configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/example-ip-set/123456"
    ])
    error_message = "Should reference correct IP set ARN"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].position == "FIRST"
    ])
    error_message = "Should use FIRST position for IP set forwarded IP config"
  }
}

run "test_managed_rule_with_label_scope_down" {
  command = plan

  variables {
    rule = [
      {
        name     = "LabelScopeDownRule"
        priority = 30
        action   = "challenge"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"

          rule_action_override = [
            {
              name          = "CategoryHttpLibrary"
              action_to_use = "challenge"
            }
          ]

          scope_down_statement = {
            label_match_statement = {
              key   = "awswaf:managed:aws:bot-control:bot:category:monitoring"
              scope = "LABEL"
            }
          }
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "LabelScopeDownRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].label_match_statement) > 0
    ])
    error_message = "Should have label match statement in scope down configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].label_match_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].label_match_statement[0].key == "awswaf:managed:aws:bot-control:bot:category:monitoring"
    ])
    error_message = "Should match correct label key"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].challenge != null
    ])
    error_message = "Rule should have challenge action configured"
  }
}

run "test_managed_rule_with_byte_match_scope_down" {
  command = plan

  variables {
    rule = [
      {
        name     = "ByteMatchScopeDownRule"
        priority = 35
        action   = "captcha"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesUnixRuleSet"
          vendor_name = "AWS"

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
          metric_name                = "ByteMatchScopeDownRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].byte_match_statement) > 0
    ])
    error_message = "Should have byte match statement in scope down configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].byte_match_statement) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0].byte_match_statement[0].search_string == "/api/"
    ])
    error_message = "Should search for /api/ path"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].captcha != null
    ])
    error_message = "Rule should have captcha action configured"
  }
}

run "test_managed_rule_multiple_action_overrides" {
  command = plan

  variables {
    rule = [
      {
        name            = "MultipleOverridesRule"
        priority        = 40
        override_action = "count"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"

          rule_action_override = [
            {
              name          = "NoUserAgent_HEADER"
              action_to_use = "allow"
            },
            {
              name          = "UserAgent_BadBots_HEADER"
              action_to_use = "count"
            },
            {
              name          = "SizeRestrictions_BODY"
              action_to_use = "challenge"
            },
            {
              name          = "EC2MetaDataSSRF_BODY"
              action_to_use = "block"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "MultipleOverridesRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].rule_action_override) == 4
    ])
    error_message = "Should have four rule action overrides configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      anytrue([
        for override in rule.statement[0].managed_rule_group_statement[0].rule_action_override :
        override.name == "NoUserAgent_HEADER" && length(override.action_to_use) > 0 &&
        override.action_to_use[0].allow != null
      ])
    ])
    error_message = "NoUserAgent_HEADER should be overridden with allow action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      anytrue([
        for override in rule.statement[0].managed_rule_group_statement[0].rule_action_override :
        override.name == "SizeRestrictions_BODY" && length(override.action_to_use) > 0 &&
        override.action_to_use[0].challenge != null
      ])
    ])
    error_message = "SizeRestrictions_BODY should be overridden with challenge action"
  }
}

run "test_managed_rule_with_acfp_configs" {
  command = plan

  variables {
    rule = [
      {
        name            = "ACFPConfigRule"
        priority        = 45
        override_action = "count"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesACFPRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs = [
            {
              aws_managed_rules_acfp_rule_set = {
                enable_regex_in_path   = true
                creation_path          = "\\/signup\\/create$"
                registration_page_path = "\\/signup\\/register$"

                request_inspection = {
                  payload_type = "JSON"
                  username_field = {
                    identifier = "/form/username"
                  }
                  password_field = {
                    identifier = "/form/password"
                  }
                  email_field = {
                    identifier = "/form/email"
                  }
                  address_fields = {
                    identifiers = ["/form/street", "/form/city"]
                  }
                  phone_number_fields = {
                    identifiers = ["/form/phone"]
                  }
                }
              }
            }
          ]

          rule_action_override = [
            {
              name          = "UnsupportedCognitoIDP"
              action_to_use = "block"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ACFPConfigRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0
    ])
    error_message = "Should have managed rule group configs configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set) > 0
    ])
    error_message = "Should have ACFP rule set configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set[0].enable_regex_in_path == true
    ])
    error_message = "Should enable regex in path for ACFP rule set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set[0].creation_path == "\\/signup\\/create$"
    ])
    error_message = "Should have correct creation path configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set[0].request_inspection) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_acfp_rule_set[0].request_inspection[0].payload_type == "JSON"
    ])
    error_message = "Should use JSON payload type for request inspection"
  }
}

run "test_managed_rule_with_atp_configs" {
  command = plan

  variables {
    rule = [
      {
        name            = "ATPConfigRule"
        priority        = 50
        override_action = "none"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesATPRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs = [
            {
              aws_managed_rules_atp_rule_set = {
                login_path           = "/auth/login"
                enable_regex_in_path = false
                request_inspection = {
                  payload_type = "FORM_ENCODED"
                  username_field = {
                    identifier = "email"
                  }
                  password_field = {
                    identifier = "password"
                  }
                }
              }
            }
          ]

          rule_action_override = [
            {
              name          = "AttributeCompromisedCredentials"
              action_to_use = "block"
            },
            {
              name          = "AttributeLongSession"
              action_to_use = "challenge"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "ATPConfigRule"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set) > 0
    ])
    error_message = "Should have ATP rule set configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set[0].login_path == "/auth/login"
    ])
    error_message = "Should have correct login path configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set[0].enable_regex_in_path == false
    ])
    error_message = "Should disable regex in path for ATP rule set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set[0].request_inspection) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_atp_rule_set[0].request_inspection[0].payload_type == "FORM_ENCODED"
    ])
    error_message = "Should use FORM_ENCODED payload type for request inspection"
  }
}

run "test_managed_rule_with_bot_control_configs" {
  command = plan

  variables {
    rule = [
      {
        name     = "BotControlConfigRule"
        priority = 55
        action   = "allow"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs = [
            {
              aws_managed_rules_bot_control_rule_set = {
                enable_machine_learning = true
                inspection_level        = "COMMON"
              }
            }
          ]

          rule_action_override = [
            {
              name          = "CategoryAdvertising"
              action_to_use = "count"
            },
            {
              name          = "CategoryHttpLibrary"
              action_to_use = "captcha"
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "BotControlConfigRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_bot_control_rule_set) > 0
    ])
    error_message = "Should have Bot Control rule set configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_bot_control_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_bot_control_rule_set[0].enable_machine_learning == true
    ])
    error_message = "Should enable machine learning for Bot Control rule set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_bot_control_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_bot_control_rule_set[0].inspection_level == "COMMON"
    ])
    error_message = "Should use COMMON inspection level for Bot Control rule set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && rule.action[0].allow != null
    ])
    error_message = "Rule should have allow action configured"
  }
}

run "test_managed_rule_with_anti_ddos_configs" {
  command = plan

  variables {
    rule = [
      {
        name            = "AntiDDoSConfigRule"
        priority        = 60
        override_action = "count"
        managed_rule_group_statement = {
          name        = "AWSManagedRulesAntiDDoSRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs = [
            {
              aws_managed_rules_anti_ddos_rule_set = {
                sensitivity_to_block = "HIGH"
                client_side_action_config = {
                  challenge = {
                    exempt_uri_regular_expression = [
                      {
                        regex_string = "\\/api\\/health$"
                      },
                      {
                        regex_string = "\\/static\\/.*\\.(css|js|png|jpg)$"
                      }
                    ]
                    usage_of_action = "ENABLED"
                    sensitivity     = "MEDIUM"
                  }
                }
              }
            }
          ]
        }
        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "AntiDDoSConfigRule"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set) > 0
    ])
    error_message = "Should have Anti-DDoS rule set configuration"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].sensitivity_to_block == "HIGH"
    ])
    error_message = "Should use HIGH sensitivity to block for Anti-DDoS rule set"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge) > 0
    ])
    error_message = "Should have challenge configuration in client side action config"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].exempt_uri_regular_expression) == 2
    ])
    error_message = "Should have two exempt URI regular expressions configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config) > 0 &&
      length(rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge) > 0 &&
      rule.statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].usage_of_action == "ENABLED"
    ])
    error_message = "Should enable usage of action for challenge configuration"
  }
}
