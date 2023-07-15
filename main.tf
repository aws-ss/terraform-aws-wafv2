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
                    content {
                      name  = lookup(response_header.value, "name")
                      value = lookup(response_header.value, "value")
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

            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_override", null) == null ? {} : lookup(managed_rule_group_statement.value, "rule_action_override")
              iterator = rule_action_override
              content {
                name = rule_action_override.value
                action_to_use {
                  dynamic "allow" {
                    for_each = rule_action_override.key == "allow" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.key == "block" ? [1] : []
                    content {}
                  }
                  dynamic "captcha" {
                    for_each = rule_action_override.key == "captcha" ? [1] : []
                    content {}
                  }
                  #                  dynamic "challenge" {
                  #                    for_each = rule_action_override.key == "challenge" ? [1] : []
                  #                    content {}
                  #                  }
                  dynamic "count" {
                    for_each = rule_action_override.key == "count" ? [1] : []
                    content {}
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
                  }
                }

                dynamic "geo_match_statement" {
                  for_each = lookup(scope_down_statement.value, "geo_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")
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
                      }
                    }

                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")
                    text_transformation {
                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(scope_down_statement.value, "size_constraint_statement", null) == null ? [] : [lookup(scope_down_statement.value, "size_constraint_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(size_constraint_statement.value, "field_to_match")]
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
                      }
                    }

                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")
                    text_transformation {
                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(scope_down_statement.value, "sqli_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                      }
                    }
                    text_transformation {
                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(scope_down_statement.value, "xss_match_statement", null) == null ? [] : [lookup(scope_down_statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                      }
                    }
                    text_transformation {
                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(scope_down_statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(scope_down_statement.value, "regex_pattern_set_reference_statement")]
                  content {
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
                      }
                    }

                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                    text_transformation {
                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
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
                              }
                            }

                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                              type     = lookup(byte_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
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
                              }
                            }

                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")
                            text_transformation {
                              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                              type     = lookup(xss_match_statement.value["text_transformation"], "type")
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
                                  }
                                }

                                dynamic "ip_set_reference_statement" {
                                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                                  content {
                                    arn = lookup(ip_set_reference_statement.value, "arn")
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
                                      }
                                    }

                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                    search_string         = lookup(byte_match_statement.value, "search_string")
                                    text_transformation {
                                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "size_constraint_statement" {
                                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                                  content {
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
                                      }
                                    }

                                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                    size                = lookup(size_constraint_statement.value, "size")
                                    text_transformation {
                                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "sqli_match_statement" {
                                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                                      }
                                    }

                                    text_transformation {
                                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "xss_match_statement" {
                                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                                      }
                                    }

                                    text_transformation {
                                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "regex_pattern_set_reference_statement" {
                                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                                  content {
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
                                      }
                                    }

                                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                                    text_transformation {
                                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
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
                              }
                            }

                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                            text_transformation {
                              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
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
                              }
                            }

                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                              type     = lookup(byte_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
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
                              }
                            }

                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")
                            text_transformation {
                              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                              type     = lookup(xss_match_statement.value["text_transformation"], "type")
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
                                  }
                                }

                                dynamic "ip_set_reference_statement" {
                                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                                  content {
                                    arn = lookup(ip_set_reference_statement.value, "arn")
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
                                      }
                                    }

                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                    search_string         = lookup(byte_match_statement.value, "search_string")
                                    text_transformation {
                                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "size_constraint_statement" {
                                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                                  content {
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
                                      }
                                    }

                                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                                    size                = lookup(size_constraint_statement.value, "size")
                                    text_transformation {
                                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "sqli_match_statement" {
                                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                                      }
                                    }

                                    text_transformation {
                                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "xss_match_statement" {
                                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                                      }
                                    }

                                    text_transformation {
                                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }

                                dynamic "regex_pattern_set_reference_statement" {
                                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                                  content {
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
                                      }
                                    }

                                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                                    text_transformation {
                                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
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
                              }
                            }

                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                            text_transformation {
                              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
                      for_each = lookup(not_statement.value, "statements")
                      content {
                        dynamic "geo_match_statement" {
                          for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
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
                              }
                            }

                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                              type     = lookup(byte_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
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
                              }
                            }

                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")
                            text_transformation {
                              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                              type     = lookup(xss_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
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
                              }
                            }

                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                            text_transformation {
                              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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

        dynamic "ip_set_reference_statement" {
          for_each = lookup(rule.value, "ip_set_reference_statement", null) == null ? [] : [lookup(rule.value, "ip_set_reference_statement")]
          content {
            arn = lookup(ip_set_reference_statement.value, "arn")
          }
        }

        dynamic "geo_match_statement" {
          for_each = lookup(rule.value, "geo_match_statement", null) == null ? [] : [lookup(rule.value, "geo_match_statement")]
          content {
            country_codes = lookup(geo_match_statement.value, "country_codes")
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
              }
            }

            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
            search_string         = lookup(byte_match_statement.value, "search_string")
            text_transformation {
              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
              type     = lookup(byte_match_statement.value["text_transformation"], "type")
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = lookup(rule.value, "rate_based_statement", null) == null ? [] : [lookup(rule.value, "rate_based_statement")]
          content {
            limit              = lookup(rate_based_statement.value, "limit")
            aggregate_key_type = lookup(rate_based_statement.value, "aggregate_key_type")

            dynamic "forwarded_ip_config" {
              for_each = lookup(rate_based_statement.value, "forwarded_ip_config", null) == null ? [] : [lookup(rate_based_statement.value, "forwarded_ip_config")]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }
          }
        }

        dynamic "size_constraint_statement" {
          for_each = lookup(rule.value, "size_constraint_statement", null) == null ? [] : [lookup(rule.value, "size_constraint_statement")]
          content {
            dynamic "field_to_match" {
              for_each = [lookup(size_constraint_statement.value, "field_to_match")]
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
              }
            }

            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
            size                = lookup(size_constraint_statement.value, "size")
            text_transformation {
              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
            }
          }
        }

        dynamic "sqli_match_statement" {
          for_each = lookup(rule.value, "sqli_match_statement", null) == null ? [] : [lookup(rule.value, "sqli_match_statement")]
          content {
            dynamic "field_to_match" {
              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
              }
            }
            text_transformation {
              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
            }
          }
        }

        dynamic "xss_match_statement" {
          for_each = lookup(rule.value, "xss_match_statement", null) == null ? [] : [lookup(rule.value, "xss_match_statement")]
          content {
            dynamic "field_to_match" {
              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
              }
            }
            text_transformation {
              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
              type     = lookup(xss_match_statement.value["text_transformation"], "type")
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = lookup(rule.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(rule.value, "regex_pattern_set_reference_statement")]
          content {
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
              }
            }

            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
            text_transformation {
              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")
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
                      }
                    }

                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")
                    text_transformation {
                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                  content {
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
                      }
                    }

                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")
                    text_transformation {
                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
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
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
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
                              }
                            }

                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                              type     = lookup(byte_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
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
                              }
                            }

                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")
                            text_transformation {
                              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                              type     = lookup(xss_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
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
                              }
                            }

                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                            text_transformation {
                              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                  content {
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
                      }
                    }

                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                    text_transformation {
                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")
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
                      }
                    }

                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")
                    text_transformation {
                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                  content {
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
                      }
                    }

                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")
                    text_transformation {
                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
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
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
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
                              }
                            }

                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                              type     = lookup(byte_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "size_constraint_statement" {
                          for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                          content {
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
                              }
                            }

                            comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                            size                = lookup(size_constraint_statement.value, "size")
                            text_transformation {
                              priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                              type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "sqli_match_statement" {
                          for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                              type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "xss_match_statement" {
                          for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                          content {
                            dynamic "field_to_match" {
                              for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                              }
                            }

                            text_transformation {
                              priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                              type     = lookup(xss_match_statement.value["text_transformation"], "type")
                            }
                          }
                        }

                        dynamic "regex_pattern_set_reference_statement" {
                          for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                          content {
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
                              }
                            }

                            arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                            text_transformation {
                              priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                              type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
                            }
                          }
                        }
                      }
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                  content {
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
                      }
                    }

                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                    text_transformation {
                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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
            dynamic "statement" {
              for_each = lookup(not_statement.value, "statements")
              content {
                dynamic "geo_match_statement" {
                  for_each = lookup(statement.value, "geo_match_statement", null) == null ? [] : [lookup(statement.value, "geo_match_statement")]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = lookup(statement.value, "ip_set_reference_statement", null) == null ? [] : [lookup(statement.value, "ip_set_reference_statement")]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")
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
                      }
                    }

                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")
                    text_transformation {
                      priority = lookup(byte_match_statement.value["text_transformation"], "priority")
                      type     = lookup(byte_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "size_constraint_statement" {
                  for_each = lookup(statement.value, "size_constraint_statement", null) == null ? [] : [lookup(statement.value, "size_constraint_statement")]
                  content {
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
                      }
                    }

                    comparison_operator = lookup(size_constraint_statement.value, "comparison_operator")
                    size                = lookup(size_constraint_statement.value, "size")
                    text_transformation {
                      priority = lookup(size_constraint_statement.value["text_transformation"], "priority")
                      type     = lookup(size_constraint_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "sqli_match_statement" {
                  for_each = lookup(statement.value, "sqli_match_statement", null) == null ? [] : [lookup(statement.value, "sqli_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(sqli_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(sqli_match_statement.value["text_transformation"], "priority")
                      type     = lookup(sqli_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "xss_match_statement" {
                  for_each = lookup(statement.value, "xss_match_statement", null) == null ? [] : [lookup(statement.value, "xss_match_statement")]
                  content {
                    dynamic "field_to_match" {
                      for_each = [lookup(xss_match_statement.value, "field_to_match")]
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
                      }
                    }

                    text_transformation {
                      priority = lookup(xss_match_statement.value["text_transformation"], "priority")
                      type     = lookup(xss_match_statement.value["text_transformation"], "type")
                    }
                  }
                }

                dynamic "regex_pattern_set_reference_statement" {
                  for_each = lookup(statement.value, "regex_pattern_set_reference_statement", null) == null ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement")]
                  content {
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
                      }
                    }

                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                    text_transformation {
                      priority = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "priority")
                      type     = lookup(regex_pattern_set_reference_statement.value["text_transformation"], "type")
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

            #            dynamic "excluded_rule" {
            #              for_each = lookup(rule_group_reference_statement.value, "excluded_rule", null) == null ? [] : [lookup(rule_group_reference_statement.value, "excluded_rule")]
            #              iterator = excluded_rule
            #              content {
            #                name = lookup(excluded_rule.value, "name")
            #              }
            #            }
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
    for_each = var.custom_response_body
    content {
      content      = var.custom_response_body.content
      content_type = var.custom_response_body.content_type
      key          = var.custom_response_body.key
    }
  }

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