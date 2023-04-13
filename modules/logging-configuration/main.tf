resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [var.log_destination_configs]
  resource_arn            = var.resource_arn

  dynamic "redacted_fields" {
    for_each = var.redacted_fields == null ? [] : [var.redacted_fields]
    content {
      dynamic "single_header" {
        for_each = lookup(redacted_fields.value, "single_header", null) == null ? [] : [lookup(redacted_fields.value, "single_header")]
        content {
          name = lower(lookup(single_header.value, "name"))
        }
      }

      dynamic "method" {
        for_each = lookup(redacted_fields.value, "method", null) == null ? [] : [lookup(redacted_fields.value, "method")]
        content {}
      }

      dynamic "query_string" {
        for_each = lookup(redacted_fields.value, "query_string", null) == null ? [] : [lookup(redacted_fields.value, "query_string")]
        content {}
      }

      dynamic "uri_path" {
        for_each = lookup(redacted_fields.value, "uri_path", null) == null ? [] : [lookup(redacted_fields.value, "uri_path")]
        content {}
      }
    }
  }

  dynamic "logging_filter" {
    for_each = var.logging_filter == null ? [] : [var.logging_filter]
    content {
      default_behavior = lookup(logging_filter.value, "default_behavior")

      dynamic "filter" {
        for_each = lookup(logging_filter.value, "filter")
        iterator = filter
        content {
          behavior    = lookup(filter.value, "behavior")
          requirement = lookup(filter.value, "requirement")

          dynamic "condition" {
            for_each = lookup(filter.value, "condition")
            content {
              dynamic "action_condition" {
                for_each = lookup(condition.value, "action_condition", null) == null ? {} : lookup(condition.value, "action_condition")
                iterator = action_condition
                content {
                  action = action_condition.value
                }
              }

              dynamic "label_name_condition" {
                for_each = lookup(condition.value, "label_name_condition", null) == null ? {} : lookup(condition.value, "label_name_condition")
                iterator = label_name_condition
                content {
                  label_name = label_name_condition.value
                }
              }
            }
          }
        }
      }
    }
  }
}