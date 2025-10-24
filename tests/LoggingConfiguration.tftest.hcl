mock_provider "aws" {}

variables {
  name           = "test-webacl"
  scope          = "REGIONAL"
  default_action = "allow"
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "test-webacl"
    sampled_requests_enabled   = true
  }
  rule                          = []
  resource_arn                  = []
  enabled_logging_configuration = false
  log_destination_configs       = null
  redacted_fields               = null
  logging_filter                = null
}

run "test_logging_disabled" {
  command = plan

  variables {
    enabled_logging_configuration = false
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this) == 0
    error_message = "No logging configuration should be created when disabled"
  }
}

run "test_logging_enabled_basic" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-test"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this) == 1
    error_message = "One logging configuration should be created when enabled"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl_logging_configuration.this[0].log_destination_configs, "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-test")
    error_message = "Log destination config should contain the correct Firehose ARN"
  }

  assert {
    condition     = aws_wafv2_web_acl_logging_configuration.this[0].resource_arn == "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    error_message = "Resource ARN should match the web ACL ARN"
  }
}

run "test_logging_with_cloudwatch_logs" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-test"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl_logging_configuration.this[0].log_destination_configs, "arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-test")
    error_message = "Log destination config should contain the correct CloudWatch Logs ARN"
  }
}

run "test_logging_with_s3_bucket" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:s3:::aws-waf-logs-test-bucket"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl_logging_configuration.this[0].log_destination_configs, "arn:aws:s3:::aws-waf-logs-test-bucket")
    error_message = "Log destination config should contain the correct S3 bucket ARN"
  }
}

run "test_logging_with_redacted_fields" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-test"
    redacted_fields = [
      {
        uri_path = {}
      },
      {
        method = {}
      },
      {
        single_header = {
          name = "authorization"
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this[0].redacted_fields) == 3
    error_message = "Should have three redacted fields"
  }

  assert {
    condition = anytrue([
      for field in aws_wafv2_web_acl_logging_configuration.this[0].redacted_fields :
      length(field.uri_path) > 0
    ])
    error_message = "Should have uri_path redacted field"
  }

  assert {
    condition = anytrue([
      for field in aws_wafv2_web_acl_logging_configuration.this[0].redacted_fields :
      length(field.method) > 0
    ])
    error_message = "Should have method redacted field"
  }

  assert {
    condition = anytrue([
      for field in aws_wafv2_web_acl_logging_configuration.this[0].redacted_fields :
      length(field.single_header) > 0 ? field.single_header[0].name == "authorization" : false
    ])
    error_message = "Should have authorization header redacted field"
  }
}

run "test_logging_with_filter" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-test"
    logging_filter = {
      default_behavior = "DROP"
      filter = [
        {
          behavior    = "KEEP"
          requirement = "MEETS_ANY"
          condition = [
            {
              action_condition = { action = "ALLOW" }
            },
            {
              action_condition = { action = "BLOCK" }
            }
          ]
        }
      ]
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this[0].logging_filter) == 1
    error_message = "Should have one logging filter"
  }

  assert {
    condition     = aws_wafv2_web_acl_logging_configuration.this[0].logging_filter[0].default_behavior == "DROP"
    error_message = "Default behavior should be DROP"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this[0].logging_filter[0].filter) == 1
    error_message = "Should have one filter rule"
  }

  assert {
    condition = anytrue([
      for filter in aws_wafv2_web_acl_logging_configuration.this[0].logging_filter[0].filter :
      filter.behavior == "KEEP"
    ])
    error_message = "Filter behavior should be KEEP"
  }

  assert {
    condition = anytrue([
      for filter in aws_wafv2_web_acl_logging_configuration.this[0].logging_filter[0].filter :
      filter.requirement == "MEETS_ANY"
    ])
    error_message = "Filter requirement should be MEETS_ANY"
  }
}

run "test_logging_comprehensive" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_logging_configuration = true
    log_destination_configs       = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-comprehensive"
    redacted_fields = [
      {
        single_header = {
          name = "host"
        }
      },
      {
        query_string = {}
      }
    ]
    logging_filter = {
      default_behavior = "KEEP"
      filter = [
        {
          behavior    = "DROP"
          requirement = "MEETS_ALL"
          condition = [
            {
              action_condition = { action = "COUNT" }
            }
          ]
        }
      ]
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this) == 1
    error_message = "Should have comprehensive logging configuration"
  }

  assert {
    condition     = contains(aws_wafv2_web_acl_logging_configuration.this[0].log_destination_configs, "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-comprehensive")
    error_message = "Should have correct comprehensive log destination"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_logging_configuration.this[0].redacted_fields) == 2
    error_message = "Should have two redacted fields in comprehensive test"
  }

  assert {
    condition     = aws_wafv2_web_acl_logging_configuration.this[0].logging_filter[0].default_behavior == "KEEP"
    error_message = "Comprehensive test should have KEEP default behavior"
  }
}