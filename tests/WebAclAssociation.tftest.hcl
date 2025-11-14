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
  association_config            = null
  enabled_web_acl_association   = false
  resource_arn                  = []
  enabled_logging_configuration = false
}

run "test_webacl_association_disabled" {
  command = plan

  variables {
    enabled_web_acl_association = false
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.this) == 0
    error_message = "No web ACL associations should be created when disabled"
  }
}

run "test_webacl_association_enabled" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_web_acl_association = true
    resource_arn                = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer/1234567890123456"]
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.this) == 1
    error_message = "One web ACL association should be created when enabled"
  }

  assert {
    condition = anytrue([
      for assoc in aws_wafv2_web_acl_association.this :
      assoc.resource_arn == "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer/1234567890123456"
    ])
    error_message = "Web ACL association should have the correct resource ARN"
  }

  assert {
    condition = anytrue([
      for assoc in aws_wafv2_web_acl_association.this :
      assoc.web_acl_arn == "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "Web ACL association should have the correct web ACL ARN"
  }

  assert {
    condition = alltrue([
      for assoc in aws_wafv2_web_acl_association.this :
      assoc.web_acl_arn != null && assoc.resource_arn != null
    ])
    error_message = "Web ACL association should have both web_acl_arn and resource_arn defined"
  }
}

run "test_webacl_multiple_associations" {
  command = apply

  override_resource {
    target = aws_wafv2_web_acl.this
    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    }
  }

  variables {
    enabled_web_acl_association = true
    resource_arn = [
      "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer-1/1234567890123456",
      "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer-2/1234567890123457"
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.this) == 2
    error_message = "Two web ACL associations should be created for two resource ARNs"
  }

  assert {
    condition = contains([
      for assoc in aws_wafv2_web_acl_association.this : assoc.resource_arn
    ], "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer-1/1234567890123456")
    error_message = "First load balancer ARN should be associated"
  }

  assert {
    condition = contains([
      for assoc in aws_wafv2_web_acl_association.this : assoc.resource_arn
    ], "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer-2/1234567890123457")
    error_message = "Second load balancer ARN should be associated"
  }

  assert {
    condition = alltrue([
      for assoc in aws_wafv2_web_acl_association.this :
      assoc.web_acl_arn == "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-webacl/12345678-1234-1234-1234-123456789012"
    ])
    error_message = "All associations should reference the same web ACL ARN"
  }
}

run "test_association_config_empty" {
  command = plan

  variables {
    association_config = {}
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config) == 1
    error_message = "Association config should be present when provided"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body) == 0
    error_message = "No request body config should be present with empty association_config"
  }
}

run "test_association_config_api_gateway" {
  command = plan

  variables {
    association_config = {
      request_body = {
        api_gateway = {
          default_size_inspection_limit = "KB_16"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config) == 1
    error_message = "Association config should be present"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body) == 1
    error_message = "Request body config should be present"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].api_gateway) == 1
    error_message = "API Gateway config should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].api_gateway[0].default_size_inspection_limit == "KB_16"
    error_message = "API Gateway default size inspection limit should match input"
  }
}

run "test_association_config_app_runner" {
  command = plan

  variables {
    association_config = {
      request_body = {
        app_runner_service = {
          default_size_inspection_limit = "KB_32"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].app_runner_service) == 1
    error_message = "App Runner service config should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].app_runner_service[0].default_size_inspection_limit == "KB_32"
    error_message = "App Runner default size inspection limit should match input"
  }
}

run "test_association_config_cognito" {
  command = plan

  variables {
    association_config = {
      request_body = {
        cognito_user_pool = {
          default_size_inspection_limit = "KB_64"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].cognito_user_pool) == 1
    error_message = "Cognito User Pool config should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].cognito_user_pool[0].default_size_inspection_limit == "KB_64"
    error_message = "Cognito default size inspection limit should match input"
  }
}

run "test_association_config_verified_access" {
  command = plan

  variables {
    association_config = {
      request_body = {
        verified_access_instance = {
          default_size_inspection_limit = "KB_16"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].verified_access_instance) == 1
    error_message = "Verified Access Instance config should be present"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].verified_access_instance[0].default_size_inspection_limit == "KB_16"
    error_message = "Verified Access default size inspection limit should match input"
  }
}

run "test_association_config_multiple_services" {
  command = plan

  variables {
    association_config = {
      request_body = {
        api_gateway = {
          default_size_inspection_limit = "KB_16"
        }
        cognito_user_pool = {
          default_size_inspection_limit = "KB_32"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].api_gateway) == 1
    error_message = "API Gateway config should be present in multi-service config"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config[0].request_body[0].cognito_user_pool) == 1
    error_message = "Cognito User Pool config should be present in multi-service config"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].api_gateway[0].default_size_inspection_limit == "KB_16"
    error_message = "API Gateway limit should be correct in multi-service config"
  }

  assert {
    condition     = aws_wafv2_web_acl.this.association_config[0].request_body[0].cognito_user_pool[0].default_size_inspection_limit == "KB_32"
    error_message = "Cognito limit should be correct in multi-service config"
  }
}

run "test_association_config_null" {
  command = plan

  variables {
    association_config = null
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.association_config) == 0
    error_message = "No association config should be present when null"
  }
}