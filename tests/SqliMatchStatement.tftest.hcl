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

# Test 1: Basic URI path SQL injection detection (matching the example)
run "sqli_match_uri_path_basic" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_uri_path"
      priority = 10
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          uri_path = {}
        }
        text_transformation = [{
          priority = 10
          type     = "NONE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_uri_path"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with sqli match statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_uri_path" && rule.priority == 10
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 2: Query string SQL injection detection with URL decode
run "sqli_match_query_string_url_decode" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_query_string"
      priority = 15
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          query_string = {}
        }
        text_transformation = [{
          priority = 1
          type     = "URL_DECODE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_query_string"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 1
    error_message = "Should have one rule with sqli match statement"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_query_string" && rule.priority == 15
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && rule.statement[0].sqli_match_statement != null
    ])
    error_message = "SQLI match statement should be configured"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].sqli_match_statement != null &&
      length(rule.statement[0].sqli_match_statement[0].field_to_match) > 0 &&
      length(rule.statement[0].sqli_match_statement[0].field_to_match[0].query_string) > 0
    ])
    error_message = "SQLI match statement should target query string"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 &&
      rule.statement[0].sqli_match_statement != null &&
      length(rule.statement[0].sqli_match_statement[0].text_transformation) > 0 &&
      anytrue([
        for transform in rule.statement[0].sqli_match_statement[0].text_transformation :
        transform.type == "URL_DECODE"
      ])
    ])
    error_message = "Should use URL_DECODE text transformation"
  }
}

# Test 3: Request body SQL injection detection with HTML entity decode
run "sqli_match_body_html_entity_decode" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_body"
      priority = 30
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          body = {}
        }
        text_transformation = [{
          priority = 10
          type     = "HTML_ENTITY_DECODE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_body"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_body" && rule.priority == 30
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 4: All query arguments SQL injection detection with lowercase
run "sqli_match_all_query_arguments_lowercase" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_all_query_args"
      priority = 40
      action   = "count"

      sqli_match_statement = {
        field_to_match = {
          all_query_arguments = {}
        }
        text_transformation = [{
          priority = 10
          type     = "LOWERCASE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_all_query_args"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_all_query_args" && rule.priority == 40
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) > 0 && length(rule.action[0].count) > 0
    ])
    error_message = "Rule should have count action"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 5: Single header SQL injection detection
run "sqli_match_single_header" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_user_agent_header"
      priority = 50
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          single_header = {
            name = "user-agent"
          }
        }
        text_transformation = [{
          priority = 10
          type     = "COMPRESS_WHITE_SPACE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_user_agent_header"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_user_agent_header" && rule.priority == 50
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 6: Single query argument SQL injection detection
run "sqli_match_single_query_argument" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_search_param"
      priority = 60
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          single_query_argument = {
            name = "search"
          }
        }
        text_transformation = [{
          priority = 10
          type     = "URL_DECODE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_search_param"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_search_param" && rule.priority == 60
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 7: Cookie-based SQL injection detection
run "sqli_match_cookies_all" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_cookies"
      priority = 70
      action   = "block"

      sqli_match_statement = {
        field_to_match = {
          cookies = {
            match_scope       = "ALL"
            oversize_handling = "MATCH"
            match_pattern = {
              all = {}
            }
          }
        }
        text_transformation = [{
          priority = 10
          type     = "URL_DECODE"
        }]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_cookies"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_cookies" && rule.priority == 70
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}

# Test 8: Multiple text transformations for comprehensive SQL injection detection
run "sqli_match_multiple_transformations" {
  command = plan

  variables {
    rule = [{
      name     = "sqli_match_comprehensive"
      priority = 80
      action   = "block"

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
          },
          {
            priority = 3
            type     = "COMPRESS_WHITE_SPACE"
          }
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli_match_comprehensive"
        sampled_requests_enabled   = true
      }
    }]
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      rule.name == "sqli_match_comprehensive" && rule.priority == 80
    ])
    error_message = "Rule should have correct name and priority"
  }

  assert {
    condition = anytrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.statement) > 0 && length(rule.statement[0].sqli_match_statement) > 0
    ])
    error_message = "SQL injection match statement should be configured"
  }
}