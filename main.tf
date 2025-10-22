resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope
  tags        = var.tags

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "association_config" {
    for_each = var.association_config == null ? [] : [var.association_config]
    content {
      dynamic "request_body" {
        for_each = lookup(association_config.value, "request_body", null) == null ? [] : [lookup(association_config.value, "request_body")]
        content {
          dynamic "api_gateway" {
            for_each = lookup(request_body.value, "api_gateway", null) == null ? [] : [1]
            content {
              default_size_inspection_limit = request_body.value.api_gateway.default_size_inspection_limit
            }
          }

          dynamic "app_runner_service" {
            for_each = lookup(request_body.value, "app_runner_service", null) == null ? [] : [1]
            content {
              default_size_inspection_limit = request_body.value.app_runner_service.default_size_inspection_limit
            }
          }

          dynamic "cognito_user_pool" {
            for_each = lookup(request_body.value, "cognito_user_pool", null) == null ? [] : [1]
            content {
              default_size_inspection_limit = request_body.value.cognito_user_pool.default_size_inspection_limit
            }
          }

          dynamic "verified_access_instance" {
            for_each = lookup(request_body.value, "verified_access_instance", null) == null ? [] : [1]
            content {
              default_size_inspection_limit = request_body.value.verified_access_instance.default_size_inspection_limit
            }
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rule
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      dynamic "action" {
        for_each = lookup(rule.value, "action", null) == null ? [] : [lookup(rule.value, "action")]
        content {
          dynamic "allow" {
            for_each = action.value == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = action.value == "block" ? [1] : []
            content {
              dynamic "custom_response" {
                for_each = lookup(rule.value, "custom_response", null) == null ? [] : [lookup(rule.value, "custom_response")]
                content {
                  custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                  response_code            = lookup(custom_response.value, "response_code", 403)

                  dynamic "response_header" {
                    for_each = lookup(custom_response.value, "response_header", [])
                    iterator = response_header

                    content {
                      name  = response_header.value.name
                      value = response_header.value.value
                    }
                  }
                }
              }
            }
          }
          dynamic "count" {
            for_each = action.value == "count" ? [1] : []
            content {}
          }
          dynamic "captcha" {
            for_each = action.value == "captcha" ? [1] : []
            content {}
          }
          dynamic "challenge" {
            for_each = action.value == "challenge" ? [1] : []
            content {}
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", null) == null ? [] : [lookup(rule.value, "rule_label")]
        content {
          name = lookup(rule_label.value, "name")
        }
      }

      dynamic "override_action" {
        for_each = lookup(rule.value, "override_action", null) == null ? [] : [lookup(rule.value, "override_action")]
        content {
          dynamic "count" {
            for_each = override_action.value == "count" ? [1] : []
            content {}
          }
          dynamic "none" {
            for_each = override_action.value == "none" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = lookup(rule.value, "managed_rule_group_statement", null) == null ? [] : [lookup(rule.value, "managed_rule_group_statement")]
          content {
            name        = lookup(managed_rule_group_statement.value, "name")
            vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", "AWS")
            version     = lookup(managed_rule_group_statement.value, "version", null)

            dynamic "managed_rule_group_configs" {
              for_each = lookup(managed_rule_group_statement.value, "managed_rule_group_configs", null) == null ? [] : lookup(managed_rule_group_statement.value, "managed_rule_group_configs")
              content {
                dynamic "aws_managed_rules_acfp_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_acfp_rule_set", null) == null ? [] : [lookup(managed_rule_group_configs.value, "aws_managed_rules_acfp_rule_set")]
                  content {
                    creation_path          = lookup(aws_managed_rules_acfp_rule_set.value, "creation_path")
                    enable_regex_in_path   = lookup(aws_managed_rules_acfp_rule_set.value, "enable_regex_in_path", false)
                    registration_page_path = lookup(aws_managed_rules_acfp_rule_set.value, "registration_page_path")

                    dynamic "request_inspection" {
                      for_each = lookup(aws_managed_rules_acfp_rule_set.value, "request_inspection") == null ? [] : [lookup(aws_managed_rules_acfp_rule_set.value, "request_inspection")]
                      content {
                        payload_type = lookup(request_inspection.value, "payload_type", "JSON")

                        dynamic "address_fields" {
                          for_each = lookup(request_inspection.value, "address_fields", null) == null ? [] : [lookup(request_inspection.value, "address_fields")]

                          content {
                            identifiers = lookup(address_fields.value, "identifiers")
                          }
                        }
                        dynamic "email_field" {
                          for_each = lookup(request_inspection.value, "email_field", null) == null ? [] : [lookup(request_inspection.value, "email_field")]
                          content {
                            identifier = lookup(email_field.value, "identifier")
                          }
                        }
                        dynamic "password_field" {
                          for_each = lookup(request_inspection.value, "password_field", null) == null ? [] : [lookup(request_inspection.value, "password_field")]
                          content {
                            identifier = lookup(password_field.value, "identifier")
                          }
                        }
                        dynamic "phone_number_fields" {
                          for_each = lookup(request_inspection.value, "phone_number_fields", null) == null ? [] : [lookup(request_inspection.value, "phone_number_fields")]

                          content {
                            identifiers = lookup(phone_number_fields.value, "identifiers")
                          }
                        }
                        dynamic "username_field" {
                          for_each = lookup(request_inspection.value, "username_field", null) == null ? [] : [lookup(request_inspection.value, "username_field")]
                          content {
                            identifier = lookup(username_field.value, "identifier")
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "aws_managed_rules_atp_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_atp_rule_set", null) == null ? [] : [lookup(managed_rule_group_configs.value, "aws_managed_rules_atp_rule_set")]
                  content {
                    enable_regex_in_path = lookup(aws_managed_rules_atp_rule_set.value, "enable_regex_in_path", false)
                    login_path           = lookup(aws_managed_rules_atp_rule_set.value, "login_path")

                    dynamic "request_inspection" {
                      for_each = lookup(aws_managed_rules_atp_rule_set.value, "request_inspection") == null ? [] : [lookup(aws_managed_rules_atp_rule_set.value, "request_inspection")]
                      content {
                        payload_type = lookup(request_inspection.value, "payload_type", "JSON")

                        dynamic "password_field" {
                          for_each = lookup(request_inspection.value, "password_field", null) == null ? [] : [lookup(request_inspection.value, "password_field")]
                          content {
                            identifier = lookup(password_field.value, "identifier")
                          }
                        }
                        dynamic "username_field" {
                          for_each = lookup(request_inspection.value, "username_field", null) == null ? [] : [lookup(request_inspection.value, "username_field")]
                          content {
                            identifier = lookup(username_field.value, "identifier")
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "aws_managed_rules_bot_control_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_bot_control_rule_set", null) == null ? [] : [lookup(managed_rule_group_configs.value, "aws_managed_rules_bot_control_rule_set")]
                  content {
                    enable_machine_learning = lookup(aws_managed_rules_bot_control_rule_set.value, "enable_machine_learning", true)
                    inspection_level        = upper(lookup(aws_managed_rules_bot_control_rule_set.value, "inspection_level", "COMMON"))
                  }
                }

                dynamic "aws_managed_rules_anti_ddos_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_anti_ddos_rule_set", null) == null ? [] : [lookup(managed_rule_group_configs.value, "aws_managed_rules_anti_ddos_rule_set")]
                  content {
                    sensitivity_to_block = upper(lookup(aws_managed_rules_anti_ddos_rule_set.value, "sensitivity_to_block", "LOW"))

                    dynamic "client_side_action_config" {
                      for_each = lookup(aws_managed_rules_anti_ddos_rule_set.value, "client_side_action_config") == null ? [] : [lookup(aws_managed_rules_anti_ddos_rule_set.value, "client_side_action_config")]
                      content {
                        dynamic "challenge" {
                          for_each = lookup(client_side_action_config.value, "challenge", null) == null ? [] : [lookup(client_side_action_config.value, "challenge")]
                          content {
                            sensitivity     = upper(lookup(challenge.value, "sensitivity", "HIGH"))
                            usage_of_action = upper(lookup(challenge.value, "usage_of_action"))

                            dynamic "exempt_uri_regular_expression" {
                              for_each = lookup(challenge.value, "exempt_uri_regular_expression", null) == null ? [] : lookup(challenge.value, "exempt_uri_regular_expression")
                              iterator = exempt_uri_regular_expression

                              content {
                                regex_string = lookup(exempt_uri_regular_expression.value, "regex_string")
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_override", null) == null ? [] : lookup(managed_rule_group_statement.value, "rule_action_override")
              content {
                name = lookup(rule_action_override.value, "name")

                dynamic "action_to_use" {
                  for_each = lookup(rule_action_override.value, "action_to_use", null) == null ? [] : [lookup(rule_action_override.value, "action_to_use")]
                  content {
                    dynamic "allow" {
                      for_each = action_to_use.value == "allow" ? [1] : []
                      content {}
                    }
                    dynamic "block" {
                      for_each = action_to_use.value == "block" ? [1] : []
                      content {}
                    }
                    dynamic "captcha" {
                      for_each = action_to_use.value == "captcha" ? [1] : []
                      content {}
                    }
                    dynamic "count" {
                      for_each = action_to_use.value == "count" ? [1] : []
                      content {}
                    }
                    dynamic "challenge" {
                      for_each = action_to_use.value == "challenge" ? [1] : []
                      content {}
                    }
                  }
                }
              }
            }

            dynamic "scope_down_statement" {
              for_each = lookup(managed_rule_group_statement.value, "scope_down_statement", null) == null ? [] : [lookup(managed_rule_group_statement.value, "scope_down_statement")]
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = lookup(scope_down_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(scope_down_statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")

                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                      }
                    }
                  }
                }

                dynamic "geo_match_statement" {
                  for_each = lookup(scope_down_statement.value, "geo_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")

                    dynamic "forwarded_ip_config" {
                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = lookup(scope_down_statement.value, "label_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "label_match_statement")]
                  content {
                    key   = lookup(label_match_statement.value, "key")
                    scope = lookup(label_match_statement.value, "scope")
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = lookup(scope_down_statement.value, "byte_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "byte_match_statement")]
                  content {
                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")

                    dynamic "field_to_match" {
                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(byte_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(scope_down_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(scope_down_statement.value, "size_constraint_statement")]
                  content {
                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")

                    dynamic "field_to_match" {
                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(scope_down_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(scope_down_statement.value, "xss_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(xss_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(scope_down_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(scope_down_statement.value, "regex_pattern_set_reference_statement")]
                  content {
                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_match_statement" {
                  for_each = lookup(scope_down_statement.value, "regex_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "regex_match_statement")]
                  content {
                    regex_string = lookup(regex_match_statement.value, "regex_string")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "and_statement" {
                  for_each = lookup(scope_down_statement.value, "and_statement", null) == null ? [] : [lookup(scope_down_statement.value, "and_statement")]
                  content {
                    dynamic "statement" {
                      for_each = lookup(and_statement.value, "statements")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")

                            dynamic "forwarded_ip_config" {
                              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")

                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                position          = lookup(ip_set_forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        dynamic "label_match_statement" {
                          for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        dynamic "byte_match_statement" {
                          for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                          content {
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")

                            dynamic "field_to_match" {
                              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(byte_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")

                            dynamic "field_to_match" {
                              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(size_constraint_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(sqli_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(xss_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_match_statement" {
                          for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                          content {
                            regex_string = lookup(regex_match_statement.value, "regex_string")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "not_statement" {
                          for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                          content {
                            statement {
                              dynamic "geo_match_statement" {
                                for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                                content {
                                  country_codes = lookup(geo_match_statement.value, "country_codes")

                                  dynamic "forwarded_ip_config" {
                                    for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                                    content {
                                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                                    }
                                  }
                                }
                              }

                              dynamic "ip_set_reference_statement" {
                                for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                                content {
                                  arn = lookup(ip_set_reference_statement.value, "arn")

                                  dynamic "ip_set_forwarded_ip_config" {
                                    for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                                    content {
                                      fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                      position          = lookup(ip_set_forwarded_ip_config.value, "position")
                                    }
                                  }
                                }
                              }

                              dynamic "label_match_statement" {
                                for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                                content {
                                  key   = lookup(label_match_statement.value, "key")
                                  scope = lookup(label_match_statement.value, "scope")
                                }
                              }

                              dynamic "byte_match_statement" {
                                for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                                content {
                                  positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                  search_string         = lookup(byte_match_statement.value, "search_string")

                                  dynamic "field_to_match" {
                                    for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(byte_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "size_constraint_statement" {
                                for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                                content {
                                  comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                  size                = lookup(size_constraint_statement.value, "size")

                                  dynamic "field_to_match" {
                                    for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(size_constraint_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "sqli_match_statement" {
                                for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(sqli_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "xss_match_statement" {
                                for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(xss_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "regex_pattern_set_reference_statement" {
                                for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                                content {
                                  arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                                  dynamic "field_to_match" {
                                    for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "regex_match_statement" {
                                for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                                content {
                                  regex_string = lookup(regex_match_statement.value, "regex_string")

                                  dynamic "field_to_match" {
                                    for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(regex_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "or_statement" {
                  for_each = lookup(scope_down_statement.value, "or_statement", null) == null ? [] : [lookup(scope_down_statement.value, "or_statement")]
                  content {
                    dynamic "statement" {
                      for_each = lookup(or_statement.value, "statements")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")

                            dynamic "forwarded_ip_config" {
                              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")

                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                position          = lookup(ip_set_forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        dynamic "label_match_statement" {
                          for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        dynamic "byte_match_statement" {
                          for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                          content {
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")

                            dynamic "field_to_match" {
                              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(byte_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")

                            dynamic "field_to_match" {
                              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(size_constraint_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(sqli_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(xss_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_match_statement" {
                          for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                          content {
                            regex_string = lookup(regex_match_statement.value, "regex_string")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "not_statement" {
                          for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                          content {
                            statement {
                              dynamic "geo_match_statement" {
                                for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                                content {
                                  country_codes = lookup(geo_match_statement.value, "country_codes")

                                  dynamic "forwarded_ip_config" {
                                    for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                                    content {
                                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                                    }
                                  }
                                }
                              }

                              dynamic "ip_set_reference_statement" {
                                for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                                content {
                                  arn = lookup(ip_set_reference_statement.value, "arn")

                                  dynamic "ip_set_forwarded_ip_config" {
                                    for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                                    content {
                                      fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                      position          = lookup(ip_set_forwarded_ip_config.value, "position")
                                    }
                                  }
                                }
                              }

                              dynamic "label_match_statement" {
                                for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                                content {
                                  key   = lookup(label_match_statement.value, "key")
                                  scope = lookup(label_match_statement.value, "scope")
                                }
                              }

                              dynamic "byte_match_statement" {
                                for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                                content {
                                  positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                  search_string         = lookup(byte_match_statement.value, "search_string")

                                  dynamic "field_to_match" {
                                    for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(byte_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "size_constraint_statement" {
                                for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                                content {
                                  comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                  size                = lookup(size_constraint_statement.value, "size")

                                  dynamic "field_to_match" {
                                    for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(size_constraint_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "sqli_match_statement" {
                                for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(sqli_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "xss_match_statement" {
                                for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(xss_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "regex_pattern_set_reference_statement" {
                                for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                                content {
                                  arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                                  dynamic "field_to_match" {
                                    for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }

                              dynamic "regex_match_statement" {
                                for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                                content {
                                  regex_string = lookup(regex_match_statement.value, "regex_string")

                                  dynamic "field_to_match" {
                                    for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                                    content {
                                      dynamic "all_query_arguments" {
                                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }

                                      dynamic "body" {
                                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }

                                      dynamic "method" {
                                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }

                                      dynamic "query_string" {
                                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }

                                      dynamic "single_header" {
                                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lookup(single_header.value, "name")
                                        }
                                      }

                                      dynamic "single_query_argument" {
                                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                        content {
                                          name = lookup(single_query_argument.value, "name")
                                        }
                                      }

                                      dynamic "uri_path" {
                                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }

                                      dynamic "cookies" {
                                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = lookup(cookies.value, "match_scope")
                                          oversize_handling = lookup(cookies.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }

                                      dynamic "headers" {
                                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                          lookup(field_to_match.value, "headers")
                                        ]
                                        content {
                                          match_scope       = lookup(headers.value, "match_scope")
                                          oversize_handling = lookup(headers.value, "oversize_handling")

                                          dynamic "match_pattern" {
                                            for_each = [lookup(headers.value, "match_pattern")]
                                            content {
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                              dynamic "all" {
                                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                content {}
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  dynamic "text_transformation" {
                                    for_each = lookup(regex_match_statement.value, "text_transformation")
                                    content {
                                      priority = lookup(text_transformation.value, "priority")
                                      type     = lookup(text_transformation.value, "type")
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = lookup(scope_down_statement.value, "not_statement", null) == null ? [] : [lookup(scope_down_statement.value, "not_statement")]
                  content {
                    statement {
                      dynamic "geo_match_statement" {
                        for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                        content {
                          country_codes = lookup(geo_match_statement.value, "country_codes")

                          dynamic "forwarded_ip_config" {
                            for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(forwarded_ip_config.value, "header_name")
                            }
                          }
                        }
                      }

                      dynamic "ip_set_reference_statement" {
                        for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                        content {
                          arn = lookup(ip_set_reference_statement.value, "arn")

                          dynamic "ip_set_forwarded_ip_config" {
                            for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                              position          = lookup(ip_set_forwarded_ip_config.value, "position")
                            }
                          }
                        }
                      }

                      dynamic "label_match_statement" {
                        for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                        content {
                          key   = lookup(label_match_statement.value, "key")
                          scope = lookup(label_match_statement.value, "scope")
                        }
                      }

                      dynamic "byte_match_statement" {
                        for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                        content {
                          positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                          search_string         = lookup(byte_match_statement.value, "search_string")

                          dynamic "field_to_match" {
                            for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(byte_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "size_constraint_statement" {
                        for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                        content {
                          comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                          size                = lookup(size_constraint_statement.value, "size")

                          dynamic "field_to_match" {
                            for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(size_constraint_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "sqli_match_statement" {
                        for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(sqli_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "xss_match_statement" {
                        for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(xss_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_pattern_set_reference_statement" {
                        for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                        content {
                          arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_match_statement" {
                        for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                        content {
                          regex_string = lookup(regex_match_statement.value, "regex_string")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "asn_match_statement" {
          for_each = lookup(rule.value, "asn_match_statement", null) == null ? [] : [lookup(rule.value, "asn_match_statement")]
          content {
            asn_list = lookup(asn_match_statement.value, "asn_list")

            dynamic "forwarded_ip_config" {
              for_each = lookup(asn_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(asn_match_statement.value, "forwarded_ip_config")]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = lookup(rule.value, "ip_set_reference_statement", null) == null ? [] : [lookup(rule.value, "ip_set_reference_statement")]
          content {
            arn = lookup(ip_set_reference_statement.value, "arn")

            dynamic "ip_set_forwarded_ip_config" {
              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
              content {
                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                position          = lookup(ip_set_forwarded_ip_config.value, "position")
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = lookup(rule.value, "geo_match_statement", null) == null ? [] : [lookup(rule.value, "geo_match_statement")]
          content {
            country_codes = lookup(geo_match_statement.value, "country_codes")

            dynamic "forwarded_ip_config" {
              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = lookup(rule.value, "label_match_statement", null) == null ? [] : [lookup(rule.value, "label_match_statement")]
          content {
            key   = lookup(label_match_statement.value, "key")
            scope = lookup(label_match_statement.value, "scope")
          }
        }

        dynamic "byte_match_statement" {
          for_each = lookup(rule.value, "byte_match_statement", null) == null ? [] : [lookup(rule.value, "byte_match_statement")]
          content {
            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
            search_string         = lookup(byte_match_statement.value, "search_string")

            dynamic "field_to_match" {
              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [lookup(field_to_match.value, "headers")]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(byte_match_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "size_constraint_statement" {
          for_each = lookup(rule.value, "size_constraint_statement", null) == null ? [] : [lookup(rule.value, "size_constraint_statement")]
          content {
            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
            size                = lookup(size_constraint_statement.value, "size")

            dynamic "field_to_match" {
              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                    lookup(field_to_match.value, "headers")
                  ]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(size_constraint_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "sqli_match_statement" {
          for_each = lookup(rule.value, "sqli_match_statement", null) == null ? [] : [lookup(rule.value, "sqli_match_statement")]
          content {
            dynamic "field_to_match" {
              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                    lookup(field_to_match.value, "headers")
                  ]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(sqli_match_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "xss_match_statement" {
          for_each = lookup(rule.value, "xss_match_statement", null) == null ? [] : [lookup(rule.value, "xss_match_statement")]
          content {
            dynamic "field_to_match" {
              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                    lookup(field_to_match.value, "headers")
                  ]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(xss_match_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = lookup(rule.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(rule.value, "regex_pattern_set_reference_statement")]
          content {
            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

            dynamic "field_to_match" {
              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                    lookup(field_to_match.value, "headers")
                  ]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "regex_match_statement" {
          for_each = lookup(rule.value, "regex_match_statement", null) == null ? [] : [lookup(rule.value, "regex_match_statement")]
          content {
            regex_string = lookup(regex_match_statement.value, "regex_string")

            dynamic "field_to_match" {
              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
              content {
                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }

                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }

                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }

                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }

                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                  content {
                    name = lookup(single_query_argument.value, "name")
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }

                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                  content {
                    match_scope       = lookup(cookies.value, "match_scope")
                    oversize_handling = lookup(cookies.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(cookies.value, "match_pattern")]
                      content {
                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }

                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                    lookup(field_to_match.value, "headers")
                  ]
                  content {
                    match_scope       = lookup(headers.value, "match_scope")
                    oversize_handling = lookup(headers.value, "oversize_handling")

                    dynamic "match_pattern" {
                      for_each = [lookup(headers.value, "match_pattern")]
                      content {
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                          content {}
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = lookup(regex_match_statement.value, "text_transformation")
              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }

        dynamic "and_statement" {
          for_each = lookup(rule.value, "and_statement", null) == null ? [] : [lookup(rule.value, "and_statement")]
          content {
            dynamic "statement" {
              for_each = lookup(and_statement.value, "statements")
              content {
                dynamic "geo_match_statement" {
                  for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")

                    dynamic "forwarded_ip_config" {
                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                      }
                    }
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")

                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                  content {
                    key   = lookup(label_match_statement.value, "key")
                    scope = lookup(label_match_statement.value, "scope")
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                  content {
                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")

                    dynamic "field_to_match" {
                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(byte_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                  content {
                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")

                    dynamic "field_to_match" {
                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(xss_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                  content {
                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_match_statement" {
                  for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                  content {
                    regex_string = lookup(regex_match_statement.value, "regex_string")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                  content {
                    statement {
                      dynamic "geo_match_statement" {
                        for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                        content {
                          country_codes = lookup(geo_match_statement.value, "country_codes")

                          dynamic "forwarded_ip_config" {
                            for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(forwarded_ip_config.value, "header_name")
                            }
                          }
                        }
                      }

                      dynamic "ip_set_reference_statement" {
                        for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                        content {
                          arn = lookup(ip_set_reference_statement.value, "arn")

                          dynamic "ip_set_forwarded_ip_config" {
                            for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                              position          = lookup(ip_set_forwarded_ip_config.value, "position")
                            }
                          }
                        }
                      }

                      dynamic "label_match_statement" {
                        for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                        content {
                          key   = lookup(label_match_statement.value, "key")
                          scope = lookup(label_match_statement.value, "scope")
                        }
                      }

                      dynamic "byte_match_statement" {
                        for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                        content {
                          positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                          search_string         = lookup(byte_match_statement.value, "search_string")

                          dynamic "field_to_match" {
                            for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(byte_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "size_constraint_statement" {
                        for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                        content {
                          comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                          size                = lookup(size_constraint_statement.value, "size")

                          dynamic "field_to_match" {
                            for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(size_constraint_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "sqli_match_statement" {
                        for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(sqli_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "xss_match_statement" {
                        for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(xss_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_pattern_set_reference_statement" {
                        for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                        content {
                          arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_match_statement" {
                        for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                        content {
                          regex_string = lookup(regex_match_statement.value, "regex_string")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = lookup(rule.value, "or_statement", null) == null ? [] : [lookup(rule.value, "or_statement")]
          content {
            dynamic "statement" {
              for_each = lookup(or_statement.value, "statements")
              content {
                dynamic "geo_match_statement" {
                  for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")

                    dynamic "forwarded_ip_config" {
                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                      }
                    }
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")

                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                  content {
                    key   = lookup(label_match_statement.value, "key")
                    scope = lookup(label_match_statement.value, "scope")
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                  content {
                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")

                    dynamic "field_to_match" {
                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(byte_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                  content {
                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")

                    dynamic "field_to_match" {
                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(xss_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                  content {
                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_match_statement" {
                  for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                  content {
                    regex_string = lookup(regex_match_statement.value, "regex_string")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                  content {
                    statement {
                      dynamic "geo_match_statement" {
                        for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                        content {
                          country_codes = lookup(geo_match_statement.value, "country_codes")

                          dynamic "forwarded_ip_config" {
                            for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(forwarded_ip_config.value, "header_name")
                            }
                          }
                        }
                      }

                      dynamic "ip_set_reference_statement" {
                        for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                        content {
                          arn = lookup(ip_set_reference_statement.value, "arn")

                          dynamic "ip_set_forwarded_ip_config" {
                            for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                            content {
                              fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                              position          = lookup(ip_set_forwarded_ip_config.value, "position")
                            }
                          }
                        }
                      }

                      dynamic "label_match_statement" {
                        for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                        content {
                          key   = lookup(label_match_statement.value, "key")
                          scope = lookup(label_match_statement.value, "scope")
                        }
                      }

                      dynamic "byte_match_statement" {
                        for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                        content {
                          positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                          search_string         = lookup(byte_match_statement.value, "search_string")

                          dynamic "field_to_match" {
                            for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(byte_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "size_constraint_statement" {
                        for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                        content {
                          comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                          size                = lookup(size_constraint_statement.value, "size")

                          dynamic "field_to_match" {
                            for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(size_constraint_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "sqli_match_statement" {
                        for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(sqli_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "xss_match_statement" {
                        for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                        content {
                          dynamic "field_to_match" {
                            for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(xss_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_pattern_set_reference_statement" {
                        for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                        content {
                          arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }

                      dynamic "regex_match_statement" {
                        for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                        content {
                          regex_string = lookup(regex_match_statement.value, "regex_string")

                          dynamic "field_to_match" {
                            for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                            content {
                              dynamic "all_query_arguments" {
                                for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }

                              dynamic "body" {
                                for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }

                              dynamic "method" {
                                for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }

                              dynamic "query_string" {
                                for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }

                              dynamic "single_header" {
                                for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lookup(single_header.value, "name")
                                }
                              }

                              dynamic "single_query_argument" {
                                for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                content {
                                  name = lookup(single_query_argument.value, "name")
                                }
                              }

                              dynamic "uri_path" {
                                for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }

                              dynamic "cookies" {
                                for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = lookup(cookies.value, "match_scope")
                                  oversize_handling = lookup(cookies.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }

                              dynamic "headers" {
                                for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                  lookup(field_to_match.value, "headers")
                                ]
                                content {
                                  match_scope       = lookup(headers.value, "match_scope")
                                  oversize_handling = lookup(headers.value, "oversize_handling")

                                  dynamic "match_pattern" {
                                    for_each = [lookup(headers.value, "match_pattern")]
                                    content {
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                      dynamic "all" {
                                        for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                        content {}
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                          dynamic "text_transformation" {
                            for_each = lookup(regex_match_statement.value, "text_transformation")
                            content {
                              priority = lookup(text_transformation.value, "priority")
                              type     = lookup(text_transformation.value, "type")
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "not_statement" {
          for_each = lookup(rule.value, "not_statement", null) == null ? [] : [lookup(rule.value, "not_statement")]
          content {
            statement {
              dynamic "geo_match_statement" {
                for_each = lookup(not_statement.value, "geo_match_statement", null) == null ? [] : [lookup(not_statement.value, "geo_match_statement")]
                content {
                  country_codes = lookup(geo_match_statement.value, "country_codes")

                  dynamic "forwarded_ip_config" {
                    for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                    content {
                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                    }
                  }
                }
              }

              dynamic "ip_set_reference_statement" {
                for_each = lookup(not_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "ip_set_reference_statement")]
                content {
                  arn = lookup(ip_set_reference_statement.value, "arn")

                  dynamic "ip_set_forwarded_ip_config" {
                    for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                    content {
                      fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                      header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                      position          = lookup(ip_set_forwarded_ip_config.value, "position")
                    }
                  }
                }
              }

              dynamic "label_match_statement" {
                for_each = lookup(not_statement.value, "label_match_statement", null) == null ? [] : [lookup(not_statement.value, "label_match_statement")]
                content {
                  key   = lookup(label_match_statement.value, "key")
                  scope = lookup(label_match_statement.value, "scope")
                }
              }

              dynamic "byte_match_statement" {
                for_each = lookup(not_statement.value, "byte_match_statement", null) == null ? [] : [lookup(not_statement.value, "byte_match_statement")]
                content {
                  positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                  search_string         = lookup(byte_match_statement.value, "search_string")

                  dynamic "field_to_match" {
                    for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(byte_match_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }

              dynamic "size_constraint_statement" {
                for_each = lookup(not_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(not_statement.value, "size_constraint_statement")]
                content {
                  comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                  size                = lookup(size_constraint_statement.value, "size")

                  dynamic "field_to_match" {
                    for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(size_constraint_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }

              dynamic "sqli_match_statement" {
                for_each = lookup(not_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(not_statement.value, "sqli_match_statement")]
                content {
                  dynamic "field_to_match" {
                    for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(sqli_match_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }

              dynamic "xss_match_statement" {
                for_each = lookup(not_statement.value, "xss_match_statement", null) == null ? [] : [lookup(not_statement.value, "xss_match_statement")]
                content {
                  dynamic "field_to_match" {
                    for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(xss_match_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }

              dynamic "regex_pattern_set_reference_statement" {
                for_each = lookup(not_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(not_statement.value, "regex_pattern_set_reference_statement")]
                content {
                  arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                  dynamic "field_to_match" {
                    for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }

              dynamic "regex_match_statement" {
                for_each = lookup(not_statement.value, "regex_match_statement", null) == null ? [] : [lookup(not_statement.value, "regex_match_statement")]
                content {
                  regex_string = lookup(regex_match_statement.value, "regex_string")

                  dynamic "field_to_match" {
                    for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                    content {
                      dynamic "all_query_arguments" {
                        for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                        content {}
                      }

                      dynamic "body" {
                        for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                        content {}
                      }

                      dynamic "method" {
                        for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                        content {}
                      }

                      dynamic "query_string" {
                        for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                        content {}
                      }

                      dynamic "single_header" {
                        for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                        content {
                          name = lookup(single_header.value, "name")
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                        content {
                          name = lookup(single_query_argument.value, "name")
                        }
                      }

                      dynamic "uri_path" {
                        for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                        content {}
                      }

                      dynamic "cookies" {
                        for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                        content {
                          match_scope       = lookup(cookies.value, "match_scope")
                          oversize_handling = lookup(cookies.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(cookies.value, "match_pattern")]
                            content {
                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }

                      dynamic "headers" {
                        for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                          lookup(field_to_match.value, "headers")
                        ]
                        content {
                          match_scope       = lookup(headers.value, "match_scope")
                          oversize_handling = lookup(headers.value, "oversize_handling")

                          dynamic "match_pattern" {
                            for_each = [lookup(headers.value, "match_pattern")]
                            content {
                              included_headers = lookup(match_pattern.value, "included_headers", null)
                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                              dynamic "all" {
                                for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                content {}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "text_transformation" {
                    for_each = lookup(regex_match_statement.value, "text_transformation")
                    content {
                      priority = lookup(text_transformation.value, "priority")
                      type     = lookup(text_transformation.value, "type")
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = lookup(rule.value, "rate_based_statement", null) == null ? [] : [lookup(rule.value, "rate_based_statement")]
          content {
            aggregate_key_type    = lookup(rate_based_statement.value, "aggregate_key_type")
            limit                 = lookup(rate_based_statement.value, "limit")
            evaluation_window_sec = lookup(rate_based_statement.value, "evaluation_window_sec")

            dynamic "forwarded_ip_config" {
              for_each = lookup(rate_based_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(rate_based_statement.value, "forwarded_ip_config")]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }
            dynamic "custom_key" {
              for_each = lookup(rate_based_statement.value, "custom_key", [])
              iterator = custom_key

              content {
                dynamic "cookie" {
                  for_each = lookup(custom_key.value, "cookie", null) == null ? [] : [lookup(custom_key.value, "cookie")]

                  content {
                    name = lookup(cookie.value, "name")

                    dynamic "text_transformation" {
                      for_each = lookup(cookie.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }
                dynamic "forwarded_ip" {
                  for_each = lookup(custom_key.value, "forwarded_ip", null) == null ? [] : [lookup(custom_key.value, "forwarded_ip")]
                  content {}
                }
                dynamic "header" {
                  for_each = lookup(custom_key.value, "header", null) == null ? [] : [lookup(custom_key.value, "header")]

                  content {
                    name = lookup(header.value, "name")

                    dynamic "text_transformation" {
                      for_each = lookup(header.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }
                dynamic "http_method" {
                  for_each = lookup(custom_key.value, "http_method", null) == null ? [] : [lookup(custom_key.value, "http_method")]
                  content {}
                }
                dynamic "ip" {
                  for_each = lookup(custom_key.value, "ip", null) == null ? [] : [lookup(custom_key.value, "ip")]
                  content {}
                }
                dynamic "label_namespace" {
                  for_each = lookup(custom_key.value, "label_namespace", null) == null ? [] : [lookup(custom_key.value, "label_namespace")]
                  content {
                    namespace = lookup(label_namespace.value, "namespace")
                  }
                }
                dynamic "query_argument" {
                  for_each = lookup(custom_key.value, "query_argument", null) == null ? [] : [lookup(custom_key.value, "query_argument")]

                  content {
                    name = lookup(query_argument.value, "name")

                    dynamic "text_transformation" {
                      for_each = lookup(query_argument.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }
                dynamic "query_string" {
                  for_each = lookup(custom_key.value, "query_string", null) == null ? [] : [lookup(custom_key.value, "query_string")]

                  content {
                    dynamic "text_transformation" {
                      for_each = lookup(query_string.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }
                dynamic "uri_path" {
                  for_each = lookup(custom_key.value, "uri_path", null) == null ? [] : [lookup(custom_key.value, "uri_path")]

                  content {
                    dynamic "text_transformation" {
                      for_each = lookup(uri_path.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

              }
            }
            dynamic "scope_down_statement" {
              for_each = lookup(rate_based_statement.value, "scope_down_statement", null) == null ? [] : [lookup(rate_based_statement.value, "scope_down_statement")]
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = lookup(scope_down_statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(scope_down_statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")

                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                      }
                    }
                  }
                }

                dynamic "geo_match_statement" {
                  for_each = lookup(scope_down_statement.value, "geo_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")

                    dynamic "forwarded_ip_config" {
                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = lookup(scope_down_statement.value, "label_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "label_match_statement")]
                  content {
                    key   = lookup(label_match_statement.value, "key")
                    scope = lookup(label_match_statement.value, "scope")
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = lookup(scope_down_statement.value, "byte_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "byte_match_statement")]
                  content {
                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")

                    dynamic "field_to_match" {
                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(byte_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(scope_down_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(scope_down_statement.value, "size_constraint_statement")]
                  content {
                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")

                    dynamic "field_to_match" {
                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(scope_down_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(scope_down_statement.value, "xss_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(xss_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(scope_down_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(scope_down_statement.value, "regex_pattern_set_reference_statement")]
                  content {
                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "regex_match_statement" {
                  for_each = lookup(scope_down_statement.value, "regex_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "regex_match_statement")]
                  content {
                    regex_string = lookup(regex_match_statement.value, "regex_string")

                    dynamic "field_to_match" {
                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                      content {
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }

                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }

                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }

                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }

                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lookup(single_header.value, "name")
                          }
                        }

                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                          content {
                            name = lookup(single_query_argument.value, "name")
                          }
                        }

                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }

                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = lookup(cookies.value, "match_scope")
                            oversize_handling = lookup(cookies.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }

                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                            lookup(field_to_match.value, "headers")
                          ]
                          content {
                            match_scope       = lookup(headers.value, "match_scope")
                            oversize_handling = lookup(headers.value, "oversize_handling")

                            dynamic "match_pattern" {
                              for_each = [lookup(headers.value, "match_pattern")]
                              content {
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                  content {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = lookup(regex_match_statement.value, "text_transformation")
                      content {
                        priority = lookup(text_transformation.value, "priority")
                        type     = lookup(text_transformation.value, "type")
                      }
                    }
                  }
                }

                dynamic "and_statement" {
                  for_each = lookup(scope_down_statement.value, "and_statement", null) == null ? [] : [lookup(scope_down_statement.value, "and_statement")]
                  content {
                    dynamic "statement" {
                      for_each = lookup(and_statement.value, "statements")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")

                            dynamic "forwarded_ip_config" {
                              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")

                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                position          = lookup(ip_set_forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        dynamic "label_match_statement" {
                          for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        dynamic "byte_match_statement" {
                          for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                          content {
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")

                            dynamic "field_to_match" {
                              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(byte_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")

                            dynamic "field_to_match" {
                              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(size_constraint_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(sqli_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(xss_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_match_statement" {
                          for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                          content {
                            regex_string = lookup(regex_match_statement.value, "regex_string")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "not_statement" {
                          for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                          content {
                            dynamic "statement" {
                              for_each = [lookup(not_statement.value, "statement")]
                              content {
                                dynamic "geo_match_statement" {
                                  for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                                  content {
                                    country_codes = lookup(geo_match_statement.value, "country_codes")

                                    dynamic "forwarded_ip_config" {
                                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                                      content {
                                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                                      }
                                    }
                                  }
                                }

                                dynamic "ip_set_reference_statement" {
                                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                                  content {
                                    arn = lookup(ip_set_reference_statement.value, "arn")

                                    dynamic "ip_set_forwarded_ip_config" {
                                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                                      content {
                                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                                      }
                                    }
                                  }
                                }

                                dynamic "label_match_statement" {
                                  for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                                  content {
                                    key   = lookup(label_match_statement.value, "key")
                                    scope = lookup(label_match_statement.value, "scope")
                                  }
                                }

                                dynamic "byte_match_statement" {
                                  for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                                  content {
                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                    search_string         = lookup(byte_match_statement.value, "search_string")

                                    dynamic "field_to_match" {
                                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(byte_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "size_constraint_statement" {
                                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                                  content {
                                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                    size                = lookup(size_constraint_statement.value, "size")

                                    dynamic "field_to_match" {
                                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "sqli_match_statement" {
                                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "xss_match_statement" {
                                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(xss_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "regex_pattern_set_reference_statement" {
                                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                                  content {
                                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                                    dynamic "field_to_match" {
                                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "regex_match_statement" {
                                  for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                                  content {
                                    regex_string = lookup(regex_match_statement.value, "regex_string")

                                    dynamic "field_to_match" {
                                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(regex_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "or_statement" {
                  for_each = lookup(scope_down_statement.value, "or_statement", null) == null ? [] : [lookup(scope_down_statement.value, "or_statement")]
                  content {
                    dynamic "statement" {
                      for_each = lookup(or_statement.value, "statements")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")

                            dynamic "forwarded_ip_config" {
                              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")

                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                position          = lookup(ip_set_forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        dynamic "label_match_statement" {
                          for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        dynamic "byte_match_statement" {
                          for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                          content {
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")

                            dynamic "field_to_match" {
                              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(byte_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")

                            dynamic "field_to_match" {
                              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(size_constraint_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(sqli_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(xss_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_match_statement" {
                          for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                          content {
                            regex_string = lookup(regex_match_statement.value, "regex_string")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "not_statement" {
                          for_each = lookup(statement.value, "not_statement", null) == null ? [] : [lookup(statement.value, "not_statement")]
                          content {
                            dynamic "statement" {
                              for_each = [lookup(not_statement.value, "statement")]
                              content {
                                dynamic "geo_match_statement" {
                                  for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                                  content {
                                    country_codes = lookup(geo_match_statement.value, "country_codes")

                                    dynamic "forwarded_ip_config" {
                                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                                      content {
                                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                                      }
                                    }
                                  }
                                }

                                dynamic "ip_set_reference_statement" {
                                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                                  content {
                                    arn = lookup(ip_set_reference_statement.value, "arn")

                                    dynamic "ip_set_forwarded_ip_config" {
                                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                                      content {
                                        fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                        position          = lookup(ip_set_forwarded_ip_config.value, "position")
                                      }
                                    }
                                  }
                                }

                                dynamic "label_match_statement" {
                                  for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                                  content {
                                    key   = lookup(label_match_statement.value, "key")
                                    scope = lookup(label_match_statement.value, "scope")
                                  }
                                }

                                dynamic "byte_match_statement" {
                                  for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                                  content {
                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                    search_string         = lookup(byte_match_statement.value, "search_string")

                                    dynamic "field_to_match" {
                                      for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(byte_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "size_constraint_statement" {
                                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                                  content {
                                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                    size                = lookup(size_constraint_statement.value, "size")

                                    dynamic "field_to_match" {
                                      for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(size_constraint_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "sqli_match_statement" {
                                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(sqli_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "xss_match_statement" {
                                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(xss_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "regex_pattern_set_reference_statement" {
                                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                                  content {
                                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                                    dynamic "field_to_match" {
                                      for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }

                                dynamic "regex_match_statement" {
                                  for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                                  content {
                                    regex_string = lookup(regex_match_statement.value, "regex_string")

                                    dynamic "field_to_match" {
                                      for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                                      content {
                                        dynamic "all_query_arguments" {
                                          for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }

                                        dynamic "body" {
                                          for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }

                                        dynamic "method" {
                                          for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }

                                        dynamic "query_string" {
                                          for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }

                                        dynamic "single_header" {
                                          for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lookup(single_header.value, "name")
                                          }
                                        }

                                        dynamic "single_query_argument" {
                                          for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                          content {
                                            name = lookup(single_query_argument.value, "name")
                                          }
                                        }

                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }

                                        dynamic "cookies" {
                                          for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = lookup(cookies.value, "match_scope")
                                            oversize_handling = lookup(cookies.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }

                                        dynamic "headers" {
                                          for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                            lookup(field_to_match.value, "headers")
                                          ]
                                          content {
                                            match_scope       = lookup(headers.value, "match_scope")
                                            oversize_handling = lookup(headers.value, "oversize_handling")

                                            dynamic "match_pattern" {
                                              for_each = [lookup(headers.value, "match_pattern")]
                                              content {
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                                dynamic "all" {
                                                  for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                                  content {}
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(regex_match_statement.value, "text_transformation")
                                      content {
                                        priority = lookup(text_transformation.value, "priority")
                                        type     = lookup(text_transformation.value, "type")
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = lookup(scope_down_statement.value, "not_statement", null) == null ? [] : [lookup(scope_down_statement.value, "not_statement")]
                  content {
                    dynamic "statement" {
                      for_each = lookup(not_statement.value, "statement")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")

                            dynamic "forwarded_ip_config" {
                              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")

                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) == null ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config")]
                              content {
                                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                                position          = lookup(ip_set_forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        dynamic "label_match_statement" {
                          for_each = lookup(statement.value, "label_match_statement", null) == null ? [] : [lookup(statement.value, "label_match_statement")]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        dynamic "byte_match_statement" {
                          for_each = lookup(statement.value, "byte_match_statement", null) == null ? [] : [lookup(statement.value, "byte_match_statement")]
                          content {
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")

                            dynamic "field_to_match" {
                              for_each = lookup(byte_match_statement.value, "field_to_match", null) == null ? [] : [lookup(byte_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(byte_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")

                            dynamic "field_to_match" {
                              for_each = lookup(size_constraint_statement.value, "field_to_match", null) == null ? [] : [lookup(size_constraint_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(size_constraint_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(sqli_match_statement.value, "field_to_match", null) == null ? [] : [lookup(sqli_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(sqli_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = lookup(xss_match_statement.value, "field_to_match", null) == null ? [] : [lookup(xss_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(xss_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_pattern_set_reference_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }

                        dynamic "regex_match_statement" {
                          for_each = lookup(statement.value, "regex_match_statement", null) == null ? [] : [lookup(statement.value, "regex_match_statement")]
                          content {
                            regex_string = lookup(regex_match_statement.value, "regex_string")

                            dynamic "field_to_match" {
                              for_each = lookup(regex_match_statement.value, "field_to_match", null) == null ? [] : [lookup(regex_match_statement.value, "field_to_match")]
                              content {
                                dynamic "all_query_arguments" {
                                  for_each = lookup(field_to_match.value, "all_query_arguments", null) == null ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }

                                dynamic "body" {
                                  for_each = lookup(field_to_match.value, "body", null) == null ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }

                                dynamic "method" {
                                  for_each = lookup(field_to_match.value, "method", null) == null ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }

                                dynamic "query_string" {
                                  for_each = lookup(field_to_match.value, "query_string", null) == null ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }

                                dynamic "single_header" {
                                  for_each = lookup(field_to_match.value, "single_header", null) == null ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lookup(single_header.value, "name")
                                  }
                                }

                                dynamic "single_query_argument" {
                                  for_each = lookup(field_to_match.value, "single_query_argument", null) == null ? [] : [lookup(field_to_match.value, "single_query_argument")]
                                  content {
                                    name = lookup(single_query_argument.value, "name")
                                  }
                                }

                                dynamic "uri_path" {
                                  for_each = lookup(field_to_match.value, "uri_path", null) == null ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }

                                dynamic "cookies" {
                                  for_each = lookup(field_to_match.value, "cookies", null) == null ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "included_cookies")
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) == 0 ? [] : lookup(match_pattern.value, "excluded_cookies")

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }

                                dynamic "headers" {
                                  for_each = lookup(field_to_match.value, "headers", null) == null ? [] : [
                                    lookup(field_to_match.value, "headers")
                                  ]
                                  content {
                                    match_scope       = lookup(headers.value, "match_scope")
                                    oversize_handling = lookup(headers.value, "oversize_handling")

                                    dynamic "match_pattern" {
                                      for_each = [lookup(headers.value, "match_pattern")]
                                      content {
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)

                                        dynamic "all" {
                                          for_each = lookup(match_pattern.value, "all", null) == null ? [] : [1]
                                          content {}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            dynamic "text_transformation" {
                              for_each = lookup(regex_match_statement.value, "text_transformation")
                              content {
                                priority = lookup(text_transformation.value, "priority")
                                type     = lookup(text_transformation.value, "type")
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "rule_group_reference_statement" {
          for_each = lookup(rule.value, "rule_group_reference_statement", null) == null ? [] : [lookup(rule.value, "rule_group_reference_statement")]
          content {
            arn = lookup(rule_group_reference_statement.value, "arn")

            dynamic "rule_action_override" {
              for_each = lookup(rule_group_reference_statement.value, "rule_action_override", null) == null ? [] : [lookup(rule_group_reference_statement.value, "rule_action_override")]
              content {
                name = lookup(rule_action_override.value, "name")

                dynamic "action_to_use" {
                  for_each = lookup(rule_action_override.value, "action_to_use", null) == null ? [] : [lookup(rule_action_override.value, "action_to_use")]
                  content {
                    dynamic "allow" {
                      for_each = action_to_use.value == "allow" ? [1] : []
                      content {}
                    }
                    dynamic "block" {
                      for_each = action_to_use.value == "block" ? [1] : []
                      content {}
                    }
                    dynamic "captcha" {
                      for_each = action_to_use.value == "captcha" ? [1] : []
                      content {}
                    }
                    dynamic "count" {
                      for_each = action_to_use.value == "count" ? [1] : []
                      content {}
                    }
                  }
                }
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = [lookup(rule.value, "visibility_config")]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled")
          metric_name                = lookup(visibility_config.value, "metric_name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled")
        }
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_body == null ? [] : var.custom_response_body
    iterator = custom_response_body

    content {
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
      key          = custom_response_body.value.key
    }
  }

  captcha_config {
    immunity_time_property {
      immunity_time = var.captcha_config
    }
  }

  challenge_config {
    immunity_time_property {
      immunity_time = var.challenge_config
    }
  }

  token_domains = var.token_domains

  visibility_config {
    cloudwatch_metrics_enabled = var.visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.visibility_config.metric_name
    sampled_requests_enabled   = var.visibility_config.sampled_requests_enabled
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.enabled_web_acl_association ? length(var.resource_arn) : 0

  resource_arn = var.resource_arn[count.index]
  web_acl_arn  = aws_wafv2_web_acl.this.arn

  depends_on = [aws_wafv2_web_acl.this]
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enabled_logging_configuration ? 1 : 0

  log_destination_configs = [var.log_destination_configs]
  resource_arn            = aws_wafv2_web_acl.this.arn

  dynamic "redacted_fields" {
    for_each = var.redacted_fields == null ? [] : var.redacted_fields
    iterator = redacted_fields

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
