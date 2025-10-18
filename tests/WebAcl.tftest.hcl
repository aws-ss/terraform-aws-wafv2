mock_provider "aws" {}

# simplest possible default settings
variables {
  name           = "test-webacl"
  scope          = "REGIONAL"
  default_action = "allow"
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "test-webacl"
    sampled_requests_enabled   = true
  }
  resource_arn = []
  rule         = []
}

# expected result from simple, default settings
run "test_basic_webacl_creation" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.this.name == "test-webacl"
    error_message = "Web ACL name should match the input variable"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.scope == "REGIONAL"
    error_message = "Web ACL scope should be REGIONAL"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.default_action[0].allow) > 0
    error_message = "Default action should be allow"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].cloudwatch_metrics_enabled == true
    error_message = "CloudWatch metrics should be enabled"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].metric_name == "test-webacl"
    error_message = "Metric name should match input"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].sampled_requests_enabled == true
    error_message = "Sampled requests should be enabled"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.captcha_config[0].immunity_time_property[0].immunity_time == 300
    error_message = "CAPTCHA immunity time should use default value of 300"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.challenge_config[0].immunity_time_property[0].immunity_time == 300
    error_message = "Challenge immunity time should use default value of 300"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this) == 0
    error_message = "No logging configuration should be created when disabled"
  }
}

# The following run blocks test different values for simple inputs.
# Some inputs control complex behaviour and are tested in seperate test files.
# These include:
# - association_config
# - custom_response_body
# - rule
# - enabled_web_acl_association
# - resource_arn
# - enabled_logging_configuration
# - log_destination_configs
# - redacted_fields
# - logging_filter

run "test_webacl_with_description" {
  command = plan

  variables {
    description = "Test WAF Web ACL for unit testing"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.description == "Test WAF Web ACL for unit testing"
    error_message = "Web ACL description should match input"
  }
}

run "test_webacl_cloudfront_scope" {
  command = plan

  variables {
    scope = "CLOUDFRONT"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.scope == "CLOUDFRONT"
    error_message = "Web ACL scope should be CLOUDFRONT"
  }
}

run "test_webacl_with_block_default_action" {
  command = plan

  variables {
    default_action = "block"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.default_action[0].block) > 0
    error_message = "Default action should be block"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.default_action[0].allow) == 0
    error_message = "Allow action should not be present when default is block"
  }
}

run "test_webacl_with_custom_response_body" {
  command = plan

  variables {
    custom_response_body = [
      {
        content      = "Access Denied"
        content_type = "TEXT_PLAIN"
        key          = "blocked_request"
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.custom_response_body) == 1
    error_message = "Should have one custom response body"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.key == "blocked_request"
    ])
    error_message = "Custom response body key should match input"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.content == "Access Denied"
    ])
    error_message = "Custom response body content should match input"
  }

  assert {
    condition = anytrue([
      for body in aws_wafv2_web_acl.this.custom_response_body :
      body.content_type == "TEXT_PLAIN"
    ])
    error_message = "Custom response body content type should match input"
  }
}

run "test_captcha_config" {
  command = plan

  variables {
    captcha_config = 600
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.captcha_config) == 1
    error_message = "CAPTCHA config should be present"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.captcha_config[0].immunity_time_property) == 1
    error_message = "CAPTCHA immunity time property should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.captcha_config[0].immunity_time_property[0].immunity_time == 600
    error_message = "CAPTCHA immunity time should match input value"
  }
}

run "test_challenge_config" {
  command = plan

  variables {
    challenge_config = 900
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.challenge_config) == 1
    error_message = "Challenge config should be present"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.challenge_config[0].immunity_time_property) == 1
    error_message = "Challenge immunity time property should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.challenge_config[0].immunity_time_property[0].immunity_time == 900
    error_message = "Challenge immunity time should match input value"
  }
}

run "test_webacl_with_token_domains" {
  command = plan

  variables {
    token_domains = ["example.com", "test.example.com"]
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.token_domains) == 2
    error_message = "Should have two token domains"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl.this.token_domains, "example.com")
    error_message = "Should contain example.com domain"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl.this.token_domains, "test.example.com")
    error_message = "Should contain test.example.com domain"
  }
}

run "test_webacl_with_tags" {
  command = plan

  variables {
    tags = {
      Environment = "test"
      Project     = "wafv2-testing"
    }
  }

  assert {
    condition     = aws_wafv2_web_acl.this.tags["Environment"] == "test"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.tags["Project"] == "wafv2-testing"
    error_message = "Project tag should be set correctly"
  }
}
