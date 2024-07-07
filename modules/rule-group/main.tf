resource "aws_wafv2_rule_group" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope
  capacity    = var.capacity
  tags        = var.tags

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
            content {}
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

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", null) == null ? [] : [lookup(rule.value, "rule_label")]
        content {
          name = lookup(rule_label.value, "name")
        }
      }

      statement {
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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = upper(lookup(cookies.value, "oversize_handling"))

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

        dynamic "rate_based_statement" {
          for_each = length(lookup(rule.value, "rate_based_statement", {})) == 0 ? [] : [lookup(rule.value, "rate_based_statement", {})]
          content {
            limit              = lookup(rate_based_statement.value, "limit")
            aggregate_key_type = lookup(rate_based_statement.value, "aggregate_key_type", "IP")

            dynamic "forwarded_ip_config" {
              for_each = length(lookup(rate_based_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(rate_based_statement.value, "forwarded_ip_config", {})]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }

            dynamic "custom_key" {
              for_each = lookup(rate_based_statement.value, "custom_key", null) == null ? [] : [lookup(rate_based_statement.value, "custom_key")]
              content {

                dynamic "cookie" {
                  for_each = lookup(custom_key.value, "cookie", null) == null ? [] : [lookup(custom_key.value, "cookie")]
                  content {
                    name = lookup(cookie.value, "name")
                    dynamic "text_transformation" {
                      for_each = lookup(cookie.value, "text_transformation", null) == null ? [] : [lookup(cookie.value, "text_transformation")]
                      content {
                        type     = lookup(text_transformation.value, "type")
                        priority = lookup(text_transformation.value, "priority")
                      }
                    }
                  }
                }

                dynamic "forwarded_ip" {
                  for_each = lookup(custom_key.value, "forwarded_ip", null) == null ? [] : [lookup(custom_key.value, "forwarded_ip")]
                  content {}
                }

                dynamic "http_method" {
                  for_each = lookup(custom_key.value, "http_method", null) == null ? [] : [lookup(custom_key.value, "http_method")]
                  content {}
                }

                dynamic "header" {
                  for_each = lookup(custom_key.value, "header", null) == null ? [] : [lookup(custom_key.value, "header")]
                  content {
                    name = lookup(header.value, "name")
                    dynamic "text_transformation" {
                      for_each = lookup(header.value, "text_transformation", null) == null ? [] : [lookup(header.value, "text_transformation")]
                      content {
                        type     = lookup(text_transformation.value, "type")
                        priority = lookup(text_transformation.value, "priority")
                      }
                    }
                  }
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
                      for_each = lookup(query_argument.value, "text_transformation", null) == null ? [] : [lookup(query_argument.value, "text_transformation")]
                      content {
                        type     = lookup(text_transformation.value, "type")
                        priority = lookup(text_transformation.value, "priority")
                      }
                    }
                  }
                }

                dynamic "query_string" {
                  for_each = lookup(custom_key.value, "query_string", null) == null ? [] : [lookup(custom_key.value, "query_string")]
                  content {
                    dynamic "text_transformation" {
                      for_each = lookup(query_string.value, "text_transformation", null) == null ? [] : [lookup(query_string.value, "text_transformation")]
                      content {
                        type     = lookup(text_transformation.value, "type")
                        priority = lookup(text_transformation.value, "priority")
                      }
                    }
                  }
                }

                dynamic "uri_path" {
                  for_each = lookup(custom_key.value, "uri_path", null) == null ? [] : [lookup(custom_key.value, "uri_path")]
                  content {
                    dynamic "text_transformation" {
                      for_each = lookup(uri_path.value, "text_transformation", null) == null ? [] : [lookup(uri_path.value, "text_transformation")]
                      content {
                        type     = lookup(text_transformation.value, "type")
                        priority = lookup(text_transformation.value, "priority")
                      }
                    }

                  }
                }
              }
            }


            dynamic "scope_down_statement" {
              for_each = length(lookup(rate_based_statement.value, "scope_down_statement", {})) == 0 ? [] : [lookup(rate_based_statement.value, "scope_down_statement", {})]
              content {
                # scope down byte_match_statement
                dynamic "byte_match_statement" {
                  for_each = length(lookup(scope_down_statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "byte_match_statement", {})]
                  content {
                    dynamic "field_to_match" {
                      for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                      content {
                        dynamic "cookies" {
                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = lookup(cookies.value, "oversize_handling")
                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                              }
                            }
                          }
                        }
                        dynamic "uri_path" {
                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }
                        dynamic "all_query_arguments" {
                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }
                        dynamic "body" {
                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }
                        dynamic "method" {
                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }
                        dynamic "query_string" {
                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lower(lookup(single_header.value, "name"))
                          }
                        }
                        dynamic "headers" {
                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                          content {
                            match_scope = upper(lookup(headers.value, "match_scope"))
                            dynamic "match_pattern" {
                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                              }
                            }
                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                          }
                        }
                      }
                    }
                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                    search_string         = lookup(byte_match_statement.value, "search_string")
                    text_transformation {
                      priority = lookup(byte_match_statement.value, "priority")
                      type     = lookup(byte_match_statement.value, "type")
                    }
                  }
                }

                # scope down regex_match_statement
                dynamic "regex_match_statement" {
                  for_each = length(lookup(scope_down_statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "regex_match_statement", {})]
                  content {
                    dynamic "field_to_match" {
                      for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                      content {
                        dynamic "cookies" {
                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = lookup(cookies.value, "oversize_handling")
                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                              }
                            }
                          }
                        }
                        dynamic "uri_path" {
                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }
                        dynamic "all_query_arguments" {
                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }
                        dynamic "body" {
                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }
                        dynamic "method" {
                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }
                        dynamic "query_string" {
                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lower(lookup(single_header.value, "name"))
                          }
                        }
                        dynamic "headers" {
                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                          content {
                            match_scope = upper(lookup(headers.value, "match_scope"))
                            dynamic "match_pattern" {
                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                              }
                            }
                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                          }
                        }
                      }
                    }
                    regex_string = lookup(regex_match_statement.value, "regex_string")
                    text_transformation {
                      priority = lookup(regex_match_statement.value, "priority")
                      type     = lookup(regex_match_statement.value, "type")
                    }
                  }
                }

                # scope down geo_match_statement
                dynamic "geo_match_statement" {
                  for_each = length(lookup(scope_down_statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "geo_match_statement", {})]
                  content {
                    country_codes = lookup(geo_match_statement.value, "country_codes")
                    dynamic "forwarded_ip_config" {
                      for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                      }
                    }
                  }
                }

                # scope down label_match_statement
                dynamic "label_match_statement" {
                  for_each = length(lookup(scope_down_statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "label_match_statement", {})]
                  content {
                    key   = lookup(label_match_statement.value, "key")
                    scope = lookup(label_match_statement.value, "scope")
                  }
                }

                #scope down regex_pattern_set_reference_statement
                dynamic "regex_pattern_set_reference_statement" {
                  for_each = length(lookup(scope_down_statement.value, "regex_pattern_set_reference_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "regex_pattern_set_reference_statement", {})]
                  content {
                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                    dynamic "field_to_match" {
                      for_each = length(lookup(regex_pattern_set_reference_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match", {})]
                      content {
                        dynamic "cookies" {
                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                          content {
                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                            oversize_handling = lookup(cookies.value, "oversize_handling")
                            dynamic "match_pattern" {
                              for_each = [lookup(cookies.value, "match_pattern")]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                              }
                            }
                          }
                        }
                        dynamic "uri_path" {
                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                          content {}
                        }
                        dynamic "all_query_arguments" {
                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                          content {}
                        }
                        dynamic "body" {
                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                          content {}
                        }
                        dynamic "method" {
                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                          content {}
                        }
                        dynamic "query_string" {
                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                          content {
                            name = lower(lookup(single_header.value, "name"))
                          }
                        }
                        dynamic "headers" {
                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                          content {
                            match_scope = upper(lookup(headers.value, "match_scope"))
                            dynamic "match_pattern" {
                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                              content {
                                dynamic "all" {
                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                  content {}
                                }
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                              }
                            }
                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                          }
                        }
                      }
                    }
                    text_transformation {
                      priority = lookup(regex_pattern_set_reference_statement.value, "priority")
                      type     = lookup(regex_pattern_set_reference_statement.value, "type")
                    }
                  }
                }

                # scope down ip_set_reference_statement
                dynamic "ip_set_reference_statement" {
                  for_each = length(lookup(scope_down_statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "ip_set_reference_statement", {})]
                  content {
                    arn = lookup(ip_set_reference_statement.value, "arn")
                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                      content {
                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                        position          = lookup(forwarded_ip_config.value, "position")
                      }
                    }
                  }
                }

                # scope down NOT statements
                dynamic "not_statement" {
                  for_each = length(lookup(scope_down_statement.value, "not_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "not_statement", {})]
                  content {
                    statement {
                      # Scope down NOT ip_set_statement
                      dynamic "ip_set_reference_statement" {
                        for_each = length(lookup(not_statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(not_statement.value, "ip_set_reference_statement", {})]
                        content {
                          arn = lookup(ip_set_reference_statement.value, "arn")
                          dynamic "ip_set_forwarded_ip_config" {
                            for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                            content {
                              fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(forwarded_ip_config.value, "header_name")
                              position          = lookup(forwarded_ip_config.value, "position")
                            }
                          }
                        }
                      }
                      # scope down NOT byte_match_statement
                      dynamic "byte_match_statement" {
                        for_each = length(lookup(not_statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "byte_match_statement", {})]
                        content {
                          dynamic "field_to_match" {
                            for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                            content {
                              dynamic "cookies" {
                                for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = upper(lookup(cookies.value, "match_scope"))
                                  oversize_handling = lookup(cookies.value, "oversize_handling")
                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      dynamic "all" {
                                        for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                        content {}
                                      }
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                    }
                                  }
                                }
                              }
                              dynamic "uri_path" {
                                for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }
                              dynamic "all_query_arguments" {
                                for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }
                              dynamic "body" {
                                for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }
                              dynamic "method" {
                                for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }
                              dynamic "query_string" {
                                for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }
                              dynamic "single_header" {
                                for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lower(lookup(single_header.value, "name"))
                                }
                              }
                              dynamic "headers" {
                                for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                content {
                                  match_scope = upper(lookup(headers.value, "match_scope"))
                                  dynamic "match_pattern" {
                                    for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                    content {

                                      dynamic "all" {
                                        for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                        content {}
                                      }
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                    }
                                  }
                                  oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                }
                              }
                            }
                          }
                          positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                          search_string         = lookup(byte_match_statement.value, "search_string")
                          text_transformation {
                            priority = lookup(byte_match_statement.value, "priority")
                            type     = lookup(byte_match_statement.value, "type")
                          }
                        }
                      }

                      # scope down NOT regex_match_statement
                      dynamic "regex_match_statement" {
                        for_each = length(lookup(not_statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "regex_match_statement", {})]
                        content {
                          dynamic "field_to_match" {
                            for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                            content {
                              dynamic "cookies" {
                                for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                content {
                                  match_scope       = upper(lookup(cookies.value, "match_scope"))
                                  oversize_handling = lookup(cookies.value, "oversize_handling")
                                  dynamic "match_pattern" {
                                    for_each = [lookup(cookies.value, "match_pattern")]
                                    content {
                                      dynamic "all" {
                                        for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                        content {}
                                      }
                                      included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                      excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                    }
                                  }
                                }
                              }
                              dynamic "uri_path" {
                                for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                content {}
                              }
                              dynamic "all_query_arguments" {
                                for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                content {}
                              }
                              dynamic "body" {
                                for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                content {}
                              }
                              dynamic "method" {
                                for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                content {}
                              }
                              dynamic "query_string" {
                                for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                content {}
                              }
                              dynamic "single_header" {
                                for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                content {
                                  name = lower(lookup(single_header.value, "name"))
                                }
                              }
                              dynamic "headers" {
                                for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                content {
                                  match_scope = upper(lookup(headers.value, "match_scope"))
                                  dynamic "match_pattern" {
                                    for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                    content {
                                      dynamic "all" {
                                        for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                        content {}
                                      }
                                      included_headers = lookup(match_pattern.value, "included_headers", null)
                                      excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                    }
                                  }
                                  oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                }
                              }
                            }
                          }
                          regex_string = lookup(regex_match_statement.value, "regex_string")
                          text_transformation {
                            priority = lookup(regex_match_statement.value, "priority")
                            type     = lookup(regex_match_statement.value, "type")
                          }
                        }
                      }

                      # scope down NOT geo_match_statement
                      dynamic "geo_match_statement" {
                        for_each = length(lookup(not_statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "geo_match_statement", {})]
                        content {
                          country_codes = lookup(geo_match_statement.value, "country_codes")
                          dynamic "forwarded_ip_config" {
                            for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                            content {
                              fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                              header_name       = lookup(forwarded_ip_config.value, "header_name")
                            }
                          }
                        }
                      }

                      # Scope down NOT label_match_statement
                      dynamic "label_match_statement" {
                        for_each = length(lookup(not_statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "label_match_statement", {})]
                        content {
                          key   = lookup(label_match_statement.value, "key")
                          scope = lookup(label_match_statement.value, "scope")
                        }
                      }
                    }
                  }
                }

                ### scope down AND statements (Requires at least two statements)
                dynamic "and_statement" {
                  for_each = length(lookup(scope_down_statement.value, "and_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "and_statement", {})]
                  content {

                    dynamic "statement" {
                      for_each = lookup(and_statement.value, "statements", {})
                      content {
                        # Scope down AND byte_match_statement
                        dynamic "byte_match_statement" {
                          for_each = length(lookup(statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(statement.value, "byte_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value, "priority")
                              type     = lookup(byte_match_statement.value, "type")
                            }
                          }
                        }

                        # Scope down AND regex_match_statement
                        dynamic "regex_match_statement" {
                          for_each = length(lookup(statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(statement.value, "regex_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            regex_string = lookup(regex_match_statement.value, "regex_string")
                            text_transformation {
                              priority = lookup(regex_match_statement.value, "priority")
                              type     = lookup(regex_match_statement.value, "type")
                            }
                          }
                        }

                        # Scope down AND geo_match_statement
                        dynamic "geo_match_statement" {
                          for_each = length(lookup(statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(statement.value, "geo_match_statement", {})]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")
                            dynamic "forwarded_ip_config" {
                              for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        # Scope down AND ip_set_statement
                        dynamic "ip_set_reference_statement" {
                          for_each = length(lookup(statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(statement.value, "ip_set_reference_statement", {})]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                                position          = lookup(forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        # Scope down AND label_match_statement
                        dynamic "label_match_statement" {
                          for_each = length(lookup(statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(statement.value, "label_match_statement", {})]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        # Scope down AND not_statement
                        dynamic "not_statement" {
                          for_each = length(lookup(statement.value, "not_statement", {})) == 0 ? [] : [lookup(statement.value, "not_statement", {})]
                          content {
                            statement {
                              # Scope down NOT ip_set_statement
                              dynamic "ip_set_reference_statement" {
                                for_each = length(lookup(not_statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(not_statement.value, "ip_set_reference_statement", {})]
                                content {
                                  arn = lookup(ip_set_reference_statement.value, "arn")
                                  dynamic "ip_set_forwarded_ip_config" {
                                    for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                                    content {
                                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                                      position          = lookup(forwarded_ip_config.value, "position")
                                    }
                                  }
                                }
                              }
                              # scope down NOT byte_match_statement
                              dynamic "byte_match_statement" {
                                for_each = length(lookup(not_statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "byte_match_statement", {})]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                                    content {
                                      dynamic "cookies" {
                                        for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = upper(lookup(cookies.value, "match_scope"))
                                          oversize_handling = lookup(cookies.value, "oversize_handling")
                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                            }
                                          }
                                        }
                                      }
                                      dynamic "uri_path" {
                                        for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }
                                      dynamic "all_query_arguments" {
                                        for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }
                                      dynamic "body" {
                                        for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }
                                      dynamic "method" {
                                        for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }
                                      dynamic "query_string" {
                                        for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }
                                      dynamic "single_header" {
                                        for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lower(lookup(single_header.value, "name"))
                                        }
                                      }
                                      dynamic "headers" {
                                        for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                        content {
                                          match_scope = upper(lookup(headers.value, "match_scope"))
                                          dynamic "match_pattern" {
                                            for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                            }
                                          }
                                          oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                        }
                                      }
                                    }
                                  }
                                  positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                  search_string         = lookup(byte_match_statement.value, "search_string")
                                  text_transformation {
                                    priority = lookup(byte_match_statement.value, "priority")
                                    type     = lookup(byte_match_statement.value, "type")
                                  }
                                }
                              }

                              # scope down NOT regex_match_statement
                              dynamic "regex_match_statement" {
                                for_each = length(lookup(not_statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "regex_match_statement", {})]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                                    content {
                                      dynamic "cookies" {
                                        for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = upper(lookup(cookies.value, "match_scope"))
                                          oversize_handling = lookup(cookies.value, "oversize_handling")
                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                            }
                                          }
                                        }
                                      }
                                      dynamic "uri_path" {
                                        for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }
                                      dynamic "all_query_arguments" {
                                        for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }
                                      dynamic "body" {
                                        for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }
                                      dynamic "method" {
                                        for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }
                                      dynamic "query_string" {
                                        for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }
                                      dynamic "single_header" {
                                        for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lower(lookup(single_header.value, "name"))
                                        }
                                      }
                                      dynamic "headers" {
                                        for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                        content {
                                          match_scope = upper(lookup(headers.value, "match_scope"))
                                          dynamic "match_pattern" {
                                            for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                            }
                                          }
                                          oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                        }
                                      }
                                    }
                                  }
                                  regex_string = lookup(regex_match_statement.value, "regex_string")
                                  text_transformation {
                                    priority = lookup(regex_match_statement.value, "priority")
                                    type     = lookup(regex_match_statement.value, "type")
                                  }
                                }
                              }

                              # scope down NOT geo_match_statement
                              dynamic "geo_match_statement" {
                                for_each = length(lookup(not_statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "geo_match_statement", {})]
                                content {
                                  country_codes = lookup(geo_match_statement.value, "country_codes")
                                  dynamic "forwarded_ip_config" {
                                    for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                                    content {
                                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                                    }
                                  }
                                }
                              }

                              # Scope down NOT label_match_statement
                              dynamic "label_match_statement" {
                                for_each = length(lookup(not_statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "label_match_statement", {})]
                                content {
                                  key   = lookup(label_match_statement.value, "key")
                                  scope = lookup(label_match_statement.value, "scope")
                                }
                              }
                            }
                          }
                        }

                        ### Scope down AND or_statement
                        dynamic "or_statement" {
                          for_each = length(lookup(statement.value, "or_statement", {})) == 0 ? [] : [lookup(statement.value, "or_statement", {})]
                          content {

                            dynamic "statement" {
                              for_each = lookup(or_statement.value, "statements", {})
                              content {

                                # Scope down AND or_statement byte_match_statement
                                dynamic "byte_match_statement" {
                                  for_each = length(lookup(statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(statement.value, "byte_match_statement", {})]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                                      content {
                                        dynamic "cookies" {
                                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                                            oversize_handling = lookup(cookies.value, "oversize_handling")
                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                dynamic "all" {
                                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                  content {}
                                                }
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                              }
                                            }
                                          }
                                        }
                                        dynamic "uri_path" {
                                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }
                                        dynamic "all_query_arguments" {
                                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }
                                        dynamic "body" {
                                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }
                                        dynamic "method" {
                                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }
                                        dynamic "query_string" {
                                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }
                                        dynamic "single_header" {
                                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lower(lookup(single_header.value, "name"))
                                          }
                                        }
                                        dynamic "headers" {
                                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                          content {
                                            match_scope = upper(lookup(headers.value, "match_scope"))
                                            dynamic "match_pattern" {
                                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                              content {
                                                dynamic "all" {
                                                  for_each = length(lookup(match_pattern.value, "all", {})) == 0 ? [] : [lookup(match_pattern.value, "all")]
                                                  content {}
                                                }
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                              }
                                            }
                                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                          }
                                        }
                                      }
                                    }
                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                    search_string         = lookup(byte_match_statement.value, "search_string")
                                    text_transformation {
                                      priority = lookup(byte_match_statement.value, "priority")
                                      type     = lookup(byte_match_statement.value, "type")
                                    }
                                  }
                                }

                                # Scope down AND or_statement regex_match_statement
                                dynamic "regex_match_statement" {
                                  for_each = length(lookup(statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(statement.value, "regex_match_statement", {})]
                                  content {
                                    dynamic "field_to_match" {
                                      for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                                      content {
                                        dynamic "cookies" {
                                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                                            oversize_handling = lookup(cookies.value, "oversize_handling")
                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                dynamic "all" {
                                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                  content {}
                                                }
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                              }
                                            }
                                          }
                                        }
                                        dynamic "uri_path" {
                                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }
                                        dynamic "all_query_arguments" {
                                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }
                                        dynamic "body" {
                                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }
                                        dynamic "method" {
                                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }
                                        dynamic "query_string" {
                                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }
                                        dynamic "single_header" {
                                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lower(lookup(single_header.value, "name"))
                                          }
                                        }
                                        dynamic "headers" {
                                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                          content {
                                            match_scope = upper(lookup(headers.value, "match_scope"))
                                            dynamic "match_pattern" {
                                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                              content {
                                                dynamic "all" {
                                                  for_each = length(lookup(match_pattern.value, "all", {})) == 0 ? [] : [lookup(match_pattern.value, "all")]
                                                  content {}
                                                }
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                              }
                                            }
                                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                          }
                                        }
                                      }
                                    }
                                    regex_string = lookup(regex_match_statement.value, "regex_string")
                                    text_transformation {
                                      priority = lookup(regex_match_statement.value, "priority")
                                      type     = lookup(regex_match_statement.value, "type")
                                    }
                                  }
                                }

                                # Scope down AND or_statement geo_match_statement
                                dynamic "geo_match_statement" {
                                  for_each = length(lookup(statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(statement.value, "geo_match_statement", {})]
                                  content {
                                    country_codes = lookup(geo_match_statement.value, "country_codes")
                                    dynamic "forwarded_ip_config" {
                                      for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                                      content {
                                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                                      }
                                    }
                                  }
                                }

                                # Scope down AND or_statement ip_set_statement
                                dynamic "ip_set_reference_statement" {
                                  for_each = length(lookup(statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(statement.value, "ip_set_reference_statement", {})]
                                  content {
                                    arn = lookup(ip_set_reference_statement.value, "arn")
                                    dynamic "ip_set_forwarded_ip_config" {
                                      for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                                      content {
                                        fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                        header_name       = lookup(forwarded_ip_config.value, "header_name")
                                        position          = lookup(forwarded_ip_config.value, "position")
                                      }
                                    }
                                  }
                                }

                                # Scope down AND or_statement label_match_statement
                                dynamic "label_match_statement" {
                                  for_each = length(lookup(statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(statement.value, "label_match_statement", {})]
                                  content {
                                    key   = lookup(label_match_statement.value, "key")
                                    scope = lookup(label_match_statement.value, "scope")
                                  }
                                }

                                # Scope down AND or_statement regex_pattern_set_reference_statement
                                dynamic "regex_pattern_set_reference_statement" {
                                  for_each = length(lookup(statement.value, "regex_pattern_set_reference_statement", {})) == 0 ? [] : [lookup(statement.value, "regex_pattern_set_reference_statement", {})]
                                  content {
                                    arn = lookup(regex_pattern_set_reference_statement.value, "arn")
                                    dynamic "field_to_match" {
                                      for_each = length(lookup(regex_pattern_set_reference_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_pattern_set_reference_statement.value, "field_to_match", {})]
                                      content {
                                        dynamic "cookies" {
                                          for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                          content {
                                            match_scope       = upper(lookup(cookies.value, "match_scope"))
                                            oversize_handling = lookup(cookies.value, "oversize_handling")
                                            dynamic "match_pattern" {
                                              for_each = [lookup(cookies.value, "match_pattern")]
                                              content {
                                                dynamic "all" {
                                                  for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                  content {}
                                                }
                                                included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                                excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                              }
                                            }
                                          }
                                        }
                                        dynamic "uri_path" {
                                          for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                          content {}
                                        }
                                        dynamic "all_query_arguments" {
                                          for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                          content {}
                                        }
                                        dynamic "body" {
                                          for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                          content {}
                                        }
                                        dynamic "method" {
                                          for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                          content {}
                                        }
                                        dynamic "query_string" {
                                          for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                          content {}
                                        }
                                        dynamic "single_header" {
                                          for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                          content {
                                            name = lower(lookup(single_header.value, "name"))
                                          }
                                        }
                                        dynamic "headers" {
                                          for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                          content {
                                            match_scope = upper(lookup(headers.value, "match_scope"))
                                            dynamic "match_pattern" {
                                              for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                              content {
                                                dynamic "all" {
                                                  for_each = length(lookup(match_pattern.value, "all", {})) == 0 ? [] : [lookup(match_pattern.value, "all")]
                                                  content {}
                                                }
                                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                              }
                                            }
                                            oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                          }
                                        }
                                      }
                                    }
                                    text_transformation {
                                      priority = lookup(regex_pattern_set_reference_statement.value, "priority")
                                      type     = lookup(regex_pattern_set_reference_statement.value, "type")
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

                ### scope down OR statements (Requires at least two statements)
                dynamic "or_statement" {
                  for_each = length(lookup(scope_down_statement.value, "or_statement", {})) == 0 ? [] : [lookup(scope_down_statement.value, "or_statement", {})]
                  content {

                    dynamic "statement" {
                      for_each = lookup(or_statement.value, "statements", {})
                      content {
                        # Scope down OR byte_match_statement
                        dynamic "byte_match_statement" {
                          for_each = length(lookup(statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(statement.value, "byte_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                            search_string         = lookup(byte_match_statement.value, "search_string")
                            text_transformation {
                              priority = lookup(byte_match_statement.value, "priority")
                              type     = lookup(byte_match_statement.value, "type")
                            }
                          }
                        }

                        # Scope down OR sqli_match_statement
                        dynamic "sqli_match_statement" {
                          for_each = length(lookup(statement.value, "sqli_match_statement", {})) == 0 ? [] : [lookup(statement.value, "sqli_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(sqli_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(sqli_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = length(lookup(match_pattern.value, "all", {})) == 0 ? [] : [lookup(match_pattern.value, "all")]
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            text_transformation {
                              priority = lookup(sqli_match_statement.value, "priority")
                              type     = lookup(sqli_match_statement.value, "type")
                            }
                          }
                        }

                        # OR xss_match_statement
                        dynamic "xss_match_statement" {
                          for_each = length(lookup(statement.value, "xss_match_statement", {})) == 0 ? [] : [lookup(statement.value, "xss_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(xss_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(xss_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = lookup(cookies.value, "match_scope")
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = length(lookup(match_pattern.value, "all", {})) == 0 ? [] : [lookup(match_pattern.value, "all")]
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            text_transformation {
                              priority = lookup(xss_match_statement.value, "priority")
                              type     = lookup(xss_match_statement.value, "type")
                            }
                          }
                        }

                        # Scope down OR regex_match_statement
                        dynamic "regex_match_statement" {
                          for_each = length(lookup(statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(statement.value, "regex_match_statement", {})]
                          content {
                            dynamic "field_to_match" {
                              for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                              content {
                                dynamic "cookies" {
                                  for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                  content {
                                    match_scope       = upper(lookup(cookies.value, "match_scope"))
                                    oversize_handling = lookup(cookies.value, "oversize_handling")
                                    dynamic "match_pattern" {
                                      for_each = [lookup(cookies.value, "match_pattern")]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                        excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                      }
                                    }
                                  }
                                }
                                dynamic "uri_path" {
                                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                  content {}
                                }
                                dynamic "all_query_arguments" {
                                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                  content {}
                                }
                                dynamic "body" {
                                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                  content {}
                                }
                                dynamic "method" {
                                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                  content {}
                                }
                                dynamic "query_string" {
                                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                  content {}
                                }
                                dynamic "single_header" {
                                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                  content {
                                    name = lower(lookup(single_header.value, "name"))
                                  }
                                }
                                dynamic "headers" {
                                  for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                  content {
                                    match_scope = upper(lookup(headers.value, "match_scope"))
                                    dynamic "match_pattern" {
                                      for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                      content {
                                        dynamic "all" {
                                          for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                          content {}
                                        }
                                        included_headers = lookup(match_pattern.value, "included_headers", null)
                                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                      }
                                    }
                                    oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                  }
                                }
                              }
                            }
                            regex_string = lookup(regex_match_statement.value, "regex_string")
                            text_transformation {
                              priority = lookup(regex_match_statement.value, "priority")
                              type     = lookup(regex_match_statement.value, "type")
                            }
                          }
                        }

                        # Scope down OR geo_match_statement
                        dynamic "geo_match_statement" {
                          for_each = length(lookup(statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(statement.value, "geo_match_statement", {})]
                          content {
                            country_codes = lookup(geo_match_statement.value, "country_codes")
                            dynamic "forwarded_ip_config" {
                              for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                              }
                            }
                          }
                        }

                        # Scope down OR ip_set_statement
                        dynamic "ip_set_reference_statement" {
                          for_each = length(lookup(statement.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(statement.value, "ip_set_reference_statement", {})]
                          content {
                            arn = lookup(ip_set_reference_statement.value, "arn")
                            dynamic "ip_set_forwarded_ip_config" {
                              for_each = length(lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "forwarded_ip_config", {})]
                              content {
                                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                header_name       = lookup(forwarded_ip_config.value, "header_name")
                                position          = lookup(forwarded_ip_config.value, "position")
                              }
                            }
                          }
                        }

                        # Scope down OR label_match_statement
                        dynamic "label_match_statement" {
                          for_each = length(lookup(statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(statement.value, "label_match_statement", {})]
                          content {
                            key   = lookup(label_match_statement.value, "key")
                            scope = lookup(label_match_statement.value, "scope")
                          }
                        }

                        # Scope down OR not_statement
                        dynamic "not_statement" {
                          for_each = length(lookup(statement.value, "not_statement", {})) == 0 ? [] : [lookup(statement.value, "not_statement", {})]
                          content {
                            statement {
                              # scope down NOT byte_match_statement
                              dynamic "byte_match_statement" {
                                for_each = length(lookup(not_statement.value, "byte_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "byte_match_statement", {})]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
                                    content {
                                      dynamic "cookies" {
                                        for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = upper(lookup(cookies.value, "match_scope"))
                                          oversize_handling = lookup(cookies.value, "oversize_handling")
                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                            }
                                          }
                                        }
                                      }
                                      dynamic "uri_path" {
                                        for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }
                                      dynamic "all_query_arguments" {
                                        for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }
                                      dynamic "body" {
                                        for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }
                                      dynamic "method" {
                                        for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }
                                      dynamic "query_string" {
                                        for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }
                                      dynamic "single_header" {
                                        for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lower(lookup(single_header.value, "name"))
                                        }
                                      }
                                      dynamic "headers" {
                                        for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                        content {
                                          match_scope = upper(lookup(headers.value, "match_scope"))
                                          dynamic "match_pattern" {
                                            for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                            }
                                          }
                                          oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                        }
                                      }
                                    }
                                  }
                                  positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
                                  search_string         = lookup(byte_match_statement.value, "search_string")
                                  text_transformation {
                                    priority = lookup(byte_match_statement.value, "priority")
                                    type     = lookup(byte_match_statement.value, "type")
                                  }
                                }
                              }

                              # scope down NOT regex_match_statement
                              dynamic "regex_match_statement" {
                                for_each = length(lookup(not_statement.value, "regex_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "regex_match_statement", {})]
                                content {
                                  dynamic "field_to_match" {
                                    for_each = length(lookup(regex_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(regex_match_statement.value, "field_to_match", {})]
                                    content {
                                      dynamic "cookies" {
                                        for_each = length(lookup(field_to_match.value, "cookies", {})) == 0 ? [] : [lookup(field_to_match.value, "cookies")]
                                        content {
                                          match_scope       = upper(lookup(cookies.value, "match_scope"))
                                          oversize_handling = lookup(cookies.value, "oversize_handling")
                                          dynamic "match_pattern" {
                                            for_each = [lookup(cookies.value, "match_pattern")]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_cookies = length(lookup(match_pattern.value, "included_cookies", [])) != 0 ? lookup(match_pattern.value, "included_cookies") : []
                                              excluded_cookies = length(lookup(match_pattern.value, "excluded_cookies", [])) != 0 ? lookup(match_pattern.value, "excluded_cookies") : []
                                            }
                                          }
                                        }
                                      }
                                      dynamic "uri_path" {
                                        for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                                        content {}
                                      }
                                      dynamic "all_query_arguments" {
                                        for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                                        content {}
                                      }
                                      dynamic "body" {
                                        for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                                        content {}
                                      }
                                      dynamic "method" {
                                        for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                                        content {}
                                      }
                                      dynamic "query_string" {
                                        for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                                        content {}
                                      }
                                      dynamic "single_header" {
                                        for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                                        content {
                                          name = lower(lookup(single_header.value, "name"))
                                        }
                                      }
                                      dynamic "headers" {
                                        for_each = length(lookup(field_to_match.value, "headers", {})) == 0 ? [] : [lookup(field_to_match.value, "headers")]
                                        content {
                                          match_scope = upper(lookup(headers.value, "match_scope"))
                                          dynamic "match_pattern" {
                                            for_each = length(lookup(headers.value, "match_pattern", {})) == 0 ? [] : [lookup(headers.value, "match_pattern", {})]
                                            content {
                                              dynamic "all" {
                                                for_each = contains(keys(match_pattern.value), "all") ? [lookup(match_pattern.value, "all")] : []
                                                content {}
                                              }
                                              included_headers = lookup(match_pattern.value, "included_headers", null)
                                              excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                                            }
                                          }
                                          oversize_handling = upper(lookup(headers.value, "oversize_handling"))
                                        }
                                      }
                                    }
                                  }
                                  regex_string = lookup(regex_match_statement.value, "regex_string")
                                  text_transformation {
                                    priority = lookup(regex_match_statement.value, "priority")
                                    type     = lookup(regex_match_statement.value, "type")
                                  }
                                }
                              }

                              # scope down NOT geo_match_statement
                              dynamic "geo_match_statement" {
                                for_each = length(lookup(not_statement.value, "geo_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "geo_match_statement", {})]
                                content {
                                  country_codes = lookup(geo_match_statement.value, "country_codes")
                                  dynamic "forwarded_ip_config" {
                                    for_each = length(lookup(geo_match_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(geo_match_statement.value, "forwarded_ip_config", {})]
                                    content {
                                      fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                                      header_name       = lookup(forwarded_ip_config.value, "header_name")
                                    }
                                  }
                                }
                              }

                              # Scope down NOT label_match_statement
                              dynamic "label_match_statement" {
                                for_each = length(lookup(not_statement.value, "label_match_statement", {})) == 0 ? [] : [lookup(not_statement.value, "label_match_statement", {})]
                                content {
                                  key   = lookup(label_match_statement.value, "key")
                                  scope = lookup(label_match_statement.value, "scope")
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

  visibility_config {
    cloudwatch_metrics_enabled = var.visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.visibility_config.metric_name
    sampled_requests_enabled   = var.visibility_config.sampled_requests_enabled
  }
}
