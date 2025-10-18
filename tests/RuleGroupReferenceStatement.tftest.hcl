mock_provider "aws" {}

variables {
  resource_arn   = []
  name           = "WebACL01"
  scope          = "CLOUDFRONT"
  default_action = "allow"
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "WebACL01"
    sampled_requests_enabled   = true
  }
}

run "basic_rule_group_reference" {
  command = plan

  variables {
    rule = [
      {
        name     = "RuleGroup01"
        priority = 2

        override_action = "count"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/ExampleRuleGroup/a1b2c3d4-5678-90ab-cdef-EXAMPLE11111"

          rule_action_override = {
            name          = "Rule01"
            action_to_use = "count"
          }
        }

        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "RuleGroup01"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with rule group reference statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RuleGroup01" && rule.priority == 2
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.override_action) > 0 && length(rule.override_action[0].count) > 0
    ])
    error_message = "Rule should have override action count configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0
    ])
    error_message = "Rule group reference statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      rule.statement[0].rule_group_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/ExampleRuleGroup/a1b2c3d4-5678-90ab-cdef-EXAMPLE11111"
    ])
    error_message = "Rule group reference ARN should be properly configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) > 0 &&
      rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].name == "Rule01"
    ])
    error_message = "Rule action override name should be properly configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].action_to_use) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].action_to_use[0].count) > 0
    ])
    error_message = "Rule action override should use count action"
  }
}

run "rule_group_reference_without_override" {
  command = plan

  variables {
    rule = [
      {
        name     = "RuleGroup02"
        priority = 3

        override_action = "none"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/ExampleRuleGroup/b2c3d4e5-6789-01bc-def0-EXAMPLE22222"
        }

        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "RuleGroup02"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RuleGroup02" && rule.priority == 3
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.override_action) > 0 && length(rule.override_action[0].none) > 0
    ])
    error_message = "Rule should have override action none configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      rule.statement[0].rule_group_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/ExampleRuleGroup/b2c3d4e5-6789-01bc-def0-EXAMPLE22222"
    ])
    error_message = "Rule group reference ARN should be properly configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) == 0
    ])
    error_message = "Should not have rule action override when not specified"
  }
}

run "rule_group_reference_with_block_override" {
  command = plan

  variables {
    rule = [
      {
        name     = "RuleGroupBlock"
        priority = 5

        override_action = "count"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/BlockRuleGroup/d4e5f6a7-89ab-23de-f012-EXAMPLE44444"

          rule_action_override = {
            name          = "BlockRule"
            action_to_use = "block"
          }
        }

        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "RuleGroupBlock"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "RuleGroupBlock" && rule.priority == 5
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) > 0 &&
      rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].name == "BlockRule"
    ])
    error_message = "Rule action override name should be BlockRule"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].action_to_use) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].action_to_use[0].block) > 0
    ])
    error_message = "Rule action override should use block action"
  }
}

run "multiple_rule_groups" {
  command = plan

  variables {
    rule = [
      {
        name     = "PrimaryRuleGroup"
        priority = 1

        override_action = "count"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/PrimaryGroup/f6a7b8c9-abcd-45f0-1234-EXAMPLE66666"

          rule_action_override = {
            name          = "PrimaryRule"
            action_to_use = "allow"
          }
        }

        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "PrimaryRuleGroup"
          sampled_requests_enabled   = true
        }
      },
      {
        name     = "SecondaryRuleGroup"
        priority = 2

        override_action = "none"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:123456789012:global/rulegroup/SecondaryGroup/a7b8c9d0-bcde-56f1-2345-EXAMPLE77777"
        }

        visibility_config = {
          cloudwatch_metrics_enabled = false
          metric_name                = "SecondaryRuleGroup"
          sampled_requests_enabled   = false
        }
      }
    ]
  }

  assert {
    condition     = length([for rule in aws_wafv2_web_acl.this.rule : rule if length(rule.statement) > 0 && length(rule.statement[0].rule_group_reference_statement) > 0]) == 2
    error_message = "Should have exactly 2 rule group reference statements"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "PrimaryRuleGroup" && rule.priority == 1
    ])
    error_message = "Primary rule group should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "SecondaryRuleGroup" && rule.priority == 2
    ])
    error_message = "Secondary rule group should have correct name and priority"
  }
}

run "aws_managed_rule_group_reference" {
  command = plan

  variables {
    rule = [
      {
        name     = "AWSManagedRulesCommonRuleSet"
        priority = 1

        override_action = "none"

        rule_group_reference_statement = {
          arn = "arn:aws:wafv2:us-east-1:aws:global/rulegroup/AWSManagedRulesCommonRuleSet/1.0"

          rule_action_override = {
            name          = "GenericRFI_BODY"
            action_to_use = "count"
          }
        }

        visibility_config = {
          cloudwatch_metrics_enabled = true
          metric_name                = "AWSManagedRulesCommonRuleSet"
          sampled_requests_enabled   = true
        }
      }
    ]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      strcontains(rule.statement[0].rule_group_reference_statement[0].arn, "aws:global")
    ])
    error_message = "AWS managed rule group ARN should contain 'aws:global'"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement) > 0 &&
      length(rule.statement[0].rule_group_reference_statement[0].rule_action_override) > 0 &&
      rule.statement[0].rule_group_reference_statement[0].rule_action_override[0].name == "GenericRFI_BODY"
    ])
    error_message = "AWS managed rule override should target specific rule name"
  }
}