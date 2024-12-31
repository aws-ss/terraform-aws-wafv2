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
  rule = [

    # Example 1
    #    {
    #      name     = "Rule01"
    #      priority = 10
    #      action   = "block"
    #      rate_based_statement = {
    #        limit                 = 1000
    #        aggregate_key_type    = "FORWARDED_IP"
    #        evaluation_window_sec = 120
    #        forwarded_ip_config = {
    #          fallback_behavior = "MATCH"
    #          header_name       = "X-Forwarded-For"
    #        }
    #      }
    #      visibility_config = {
    #        cloudwatch_metrics_enabled = false
    #        metric_name                = "cloudwatch_metric_name"
    #        sampled_requests_enabled   = false
    #      }
    #    }

    # Example 2
    #    {
    #      name     = "Rule01"
    #      priority = 10
    #      action   = "block"
    #      rate_based_statement = {
    #        limit                 = 100
    #        aggregate_key_type    = "CONSTANT"
    #        evaluation_window_sec = 120
    #        scope_down_statement = {
    #          geo_match_statement = {
    #            country_codes : ["CN"]
    #            forwarded_ip_config = {
    #              fallback_behavior = "MATCH"
    #              header_name       = "X-Forwarded-For"
    #            }
    #          }
    #        }
    #      }
    #      visibility_config = {
    #        cloudwatch_metrics_enabled = false
    #        metric_name                = "cloudwatch_metric_name"
    #        sampled_requests_enabled   = false
    #      }
    #    }

    # Example 3
    {
      name     = "Rule01"
      priority = 10
      action   = "block"
      rate_based_statement = {
        limit              = 100
        aggregate_key_type = "CUSTOM_KEYS"
        forwarded_ip_config = {
          fallback_behavior = "MATCH"
          header_name       = "X-Forwarded-For"
        }
        evaluation_window_sec = 120
        custom_key = [
          {
            header = {
              name = "HEADER01"
              text_transformation = [
                {
                  priority = 10
                  type     = "NONE"
                },
                {
                  priority = 20
                  type     = "LOWERCASE"
                },
              ]
            }
          },
          {
            query_string = {
              text_transformation = [
                {
                  priority = 10
                  type     = "NONE"
                },
                {
                  priority = 20
                  type     = "LOWERCASE"
                }
              ]
            }
          },
          {
            query_argument = {
              name = "QUERY_ARGUMENT01"
              text_transformation = [
                {
                  priority = 10
                  type     = "NONE"
                },
                {
                  priority = 20
                  type     = "LOWERCASE"
                }
              ]
            }
          },
          {
            forwarded_ip = {}
          },
          #          {
          #            http_method = {}
          #          },
          #          {
          #            ip = {}
          #          },
          #          {
          #            label_namespace = {
          #              namespace = ""
          #            }
          #          },
          {
            #            uri_path = {
            #              text_transformation = [
            #                {
            #                  priority = 10
            #                  type     = "NONE"
            #                },
            #                {
            #                  priority = 20
            #                  type     = "LOWERCASE"
            #                }
            #              ]
            #            }
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