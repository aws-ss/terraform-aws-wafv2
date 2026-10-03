provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../..//"

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  rule_json = jsonencode([
    {
      "Name" : "Rule01",
      "Priority" : 10,
      "Statement" : {
        "GeoMatchStatement" : {
          "CountryCodes" : [
            "CN",
            "US"
          ],
          "ForwardedIPConfig" : {
            "HeaderName" : "X-Forwarded-For",
            "FallbackBehavior" : "MATCH"
          }
        }
      },
      "Action" : {
        "Count" : {}
      },
      "VisibilityConfig" : {
        "SampledRequestsEnabled" : false,
        "CloudWatchMetricsEnabled" : false,
        "MetricName" : "cloudwatch_metric_name"
      }
    },
    {
      "Name" : "Rule02",
      "Priority" : 20,
      "Statement" : {
        "GeoMatchStatement" : {
          "CountryCodes" : [
            "AE"
          ]
        }
      },
      "Action" : {
        "Block" : {}
      },
      "VisibilityConfig" : {
        "SampledRequestsEnabled" : false,
        "CloudWatchMetricsEnabled" : false,
        "MetricName" : "cloudwatch_metric_name"
      }
    }
  ])
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
  tags = {
    Team : "Security"
    Owner : "Security"
  }
}