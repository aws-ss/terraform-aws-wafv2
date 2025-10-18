variable "name" {
  description = "(Required) Friendly name of the WebACL."
  type        = string
}

variable "description" {
  description = "(Optional) Friendly description of the WebACL."
  type        = string
  default     = null
}

variable "scope" {
  description = "(Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application"
  type        = string
}

variable "default_action" {
  description = "(Required) Action to perform if none of the rules contained in the WebACL match."
  type        = string
}

variable "default_custom_response" {
  description = "(Optional) Customise the response when the default action is block"
  type = object({
    response_code            = optional(number, 403)
    custom_response_body_key = optional(string)
    response_header          = optional(list(object({
      name  = string
      value = string
    })))
  })
  default = null
}

variable "association_config" {
  description = "(Optional) Customizes the request body that your protected resource forward to AWS WAF for inspection."
  type        = map(any)
  default     = null
}

variable "visibility_config" {
  description = "(Required) Defines and enables Amazon CloudWatch metrics and web request sample collection."
  type        = map(string)
}

variable "custom_response_body" {
  description = "(Optional) Defines custom response bodies that can be referenced by custom_response actions."
  type = list(object({
    content      = string
    content_type = string
    key          = string
  }))
  default = []
}

variable "captcha_config" {
  description = "(Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300."
  type        = number
  default     = 300
}

variable "challenge_config" {
  description = "(Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300."
  type        = number
  default     = 300
}

variable "token_domains" {
  description = "(Optional) Specifies the domains that AWS WAF should accept in a web request token. This enables the use of tokens across multiple protected websites. When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting. If you don't specify a list of token domains, AWS WAF accepts tokens only for the domain of the protected resource. With a token domain list, AWS WAF accepts the resource's host domain plus all domains in the token domain list, including their prefixed subdomains."
  type        = list(string)
  default     = []
}

variable "rule" {
  description = "(Optional) Rule blocks used to identify the web requests that you want to allow, block, or count."
  type = list(object({
    name            = string
    priority        = number
    action          = optional(string)
    override_action = optional(string)

    # Custom response configuration for block actions
    custom_response = optional(object({
      custom_response_body_key = optional(string)
      response_code            = optional(number)
      response_header = optional(list(object({
        name  = string
        value = string
      })), [])
    }))

    # Rule label
    rule_label = optional(object({
      name = string
    }))

    # Visibility configuration
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })

    # Statement types (mutually exclusive at top level)

    ## Nestable statement types

    asn_match_statement = optional(object({
      asn_list = list(number)
      forwarded_ip_config = optional(object({
        fallback_behavior = string
        header_name       = string
      }))
    }))

    byte_match_statement = optional(object({
      positional_constraint = string
      search_string         = string
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    geo_match_statement = optional(object({
      country_codes = list(string)
      forwarded_ip_config = optional(object({
        fallback_behavior = string
        header_name       = string
      }))
    }))

    ip_set_reference_statement = optional(object({
      arn = string
      ip_set_forwarded_ip_config = optional(object({
        fallback_behavior = string
        header_name       = string
        position          = string
      }))
    }))

    label_match_statement = optional(object({
      key   = string
      scope = string
    }))

    regex_match_statement = optional(object({
      regex_string = string
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    regex_pattern_set_reference_statement = optional(object({
      arn = string
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    rule_group_reference_statement = optional(object({
      arn = string
      rule_action_override = optional(object({
        name          = string
        action_to_use = string # Simplified to string (module handles conversion)
      }))
    }))

    size_constraint_statement = optional(object({
      comparison_operator = string
      size                = number
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    sqli_match_statement = optional(object({
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    xss_match_statement = optional(object({
      field_to_match = object({
        all_query_arguments = optional(object({}))
        body                = optional(object({}))
        method              = optional(object({}))
        query_string        = optional(object({}))
        single_header = optional(object({
          name = string
        }))
        single_query_argument = optional(object({
          name = string
        }))
        uri_path = optional(object({}))
        cookies = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_cookies = optional(list(string), [])
            excluded_cookies = optional(list(string), [])
          })
          match_scope       = string
          oversize_handling = string
        }))
        headers = optional(object({
          match_pattern = object({
            all              = optional(object({}))
            included_headers = optional(list(string))
            excluded_headers = optional(list(string))
          })
          match_scope       = string
          oversize_handling = string
        }))
      })
      text_transformation = list(object({
        priority = number
        type     = string
      }))
    }))

    ## Logical statements


    not_statement = optional(object({
      # asn_match_statement is not supported
      byte_match_statement = optional(object({
        positional_constraint = string
        search_string         = string
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
      geo_match_statement = optional(object({
        country_codes = list(string)
        forwarded_ip_config = optional(object({
          fallback_behavior = string
          header_name       = string
        }))
      }))
      ip_set_reference_statement = optional(object({
        arn = string
        ip_set_forwarded_ip_config = optional(object({
          fallback_behavior = string
          header_name       = string
          position          = string
        }))
      }))
      label_match_statement = optional(object({
        key   = string
        scope = string
      }))
      regex_match_statement = optional(object({
        regex_string = string
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
      regex_pattern_set_reference_statement = optional(object({
        arn = string
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
      # rule_group_reference_statement is not supported
      size_constraint_statement = optional(object({
        comparison_operator = string
        size                = number
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
      sqli_match_statement = optional(object({
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
      xss_match_statement = optional(object({
        field_to_match = object({
          all_query_arguments = optional(object({}))
          body                = optional(object({}))
          method              = optional(object({}))
          query_string        = optional(object({}))
          single_header = optional(object({
            name = string
          }))
          single_query_argument = optional(object({
            name = string
          }))
          uri_path = optional(object({}))
          cookies = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_cookies = optional(list(string), [])
              excluded_cookies = optional(list(string), [])
            })
            match_scope       = string
            oversize_handling = string
          }))
          headers = optional(object({
            match_pattern = object({
              all              = optional(object({}))
              included_headers = optional(list(string))
              excluded_headers = optional(list(string))
            })
            match_scope       = string
            oversize_handling = string
          }))
        })
        text_transformation = list(object({
          priority = number
          type     = string
        }))
      }))
    }))

    and_statement = optional(object({
      statements = list(object({
        # asn_match_statement is not supported
        byte_match_statement = optional(object({
          positional_constraint = string
          search_string         = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
          }))
        }))
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
            position          = string
          }))
        }))
        label_match_statement = optional(object({
          key   = string
          scope = string
        }))
        regex_match_statement = optional(object({
          regex_string = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        # rule_group_reference_statement is not supported
        size_constraint_statement = optional(object({
          comparison_operator = string
          size                = number
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        sqli_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        xss_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        not_statement = optional(object({
          # asn_match_statement is not supported
          byte_match_statement = optional(object({
            positional_constraint = string
            search_string         = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          geo_match_statement = optional(object({
            country_codes = list(string)
            forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
            }))
          }))
          ip_set_reference_statement = optional(object({
            arn = string
            ip_set_forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
              position          = string
            }))
          }))
          label_match_statement = optional(object({
            key   = string
            scope = string
          }))
          regex_match_statement = optional(object({
            regex_string = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          regex_pattern_set_reference_statement = optional(object({
            arn = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          # rule_group_reference_statement is not supported
          size_constraint_statement = optional(object({
            comparison_operator = string
            size                = number
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          sqli_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          xss_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
        }))
      }))
    }))

    or_statement = optional(object({
      statements = list(object({
        # asn_match_statement is not supported
        byte_match_statement = optional(object({
          positional_constraint = string
          search_string         = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
          }))
        }))
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
            position          = string
          }))
        }))
        label_match_statement = optional(object({
          key   = string
          scope = string
        }))
        regex_match_statement = optional(object({
          regex_string = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        # rule_group_reference_statement is not supported
        size_constraint_statement = optional(object({
          comparison_operator = string
          size                = number
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        sqli_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        xss_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        not_statement = optional(object({
          # asn_match_statement is not supported
          byte_match_statement = optional(object({
            positional_constraint = string
            search_string         = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          geo_match_statement = optional(object({
            country_codes = list(string)
            forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
            }))
          }))
          ip_set_reference_statement = optional(object({
            arn = string
            ip_set_forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
              position          = string
            }))
          }))
          label_match_statement = optional(object({
            key   = string
            scope = string
          }))
          regex_match_statement = optional(object({
            regex_string = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          regex_pattern_set_reference_statement = optional(object({
            arn = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          # rule_group_reference_statement is not supported
          size_constraint_statement = optional(object({
            comparison_operator = string
            size                = number
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          sqli_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          xss_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
        }))
      }))
    }))


    ## Other statement types

    managed_rule_group_statement = optional(object({
      name        = string
      vendor_name = optional(string)
      version     = optional(string)
      managed_rule_group_configs = optional(list(object({
        aws_managed_rules_acfp_rule_set = optional(object({
          creation_path          = string
          enable_regex_in_path   = optional(bool)
          registration_page_path = string
          request_inspection = optional(object({
            payload_type = optional(string, "JSON")
            address_fields = optional(object({
              identifiers = list(string)
            }))
            email_field = optional(object({
              identifier = string
            }))
            password_field = optional(object({
              identifier = string
            }))
            phone_number_fields = optional(object({
              identifiers = list(string)
            }))
            username_field = optional(object({
              identifier = string
            }))
          }))
        }))
        aws_managed_rules_atp_rule_set = optional(object({
          enable_regex_in_path = optional(bool)
          login_path           = string
          request_inspection = object({
            payload_type = string
            password_field = optional(object({
              identifier = string
            }))
            username_field = optional(object({
              identifier = string
            }))
          })
        }))
        aws_managed_rules_bot_control_rule_set = optional(object({
          enable_machine_learning = optional(bool)
          inspection_level        = optional(string, "COMMON")
        }))
        aws_managed_rules_anti_ddos_rule_set = optional(object({
          sensitivity_to_block = optional(string, "LOW")
          client_side_action_config = object({
            challenge = object({
              usage_of_action = string
              sensitivity     = optional(string, "HIGH")
              exempt_uri_regular_expression = optional(list(object({
                regex_string = string
              })))
            })
          })
        }))
      })))
      rule_action_override = optional(list(object({
        name          = string
        action_to_use = string
      })))
      # got_to_here
      scope_down_statement = optional(object({
        # asn_match_statement is not supported
        byte_match_statement = optional(object({
          positional_constraint = string
          search_string         = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
          }))
        }))
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
            position          = string
          }))
        }))
        label_match_statement = optional(object({
          key   = string
          scope = string
        }))
        regex_match_statement = optional(object({
          regex_string = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        # rule_group_reference_statement is not supported
        size_constraint_statement = optional(object({
          comparison_operator = string
          size                = number
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        sqli_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        xss_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        and_statement = optional(object({
          statements = list(object({
            # asn_match_statement is not supported
            byte_match_statement = optional(object({
              positional_constraint = string
              search_string         = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
              }))
            }))
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
                position          = string
              }))
            }))
            label_match_statement = optional(object({
              key   = string
              scope = string
            }))
            regex_match_statement = optional(object({
              regex_string = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            # rule_group_reference_statement is not supported
            size_constraint_statement = optional(object({
              comparison_operator = string
              size                = number
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            sqli_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            xss_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
          }))
        }))
        or_statement = optional(object({
          statements = list(object({
            # asn_match_statement is not supported
            byte_match_statement = optional(object({
              positional_constraint = string
              search_string         = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
              }))
            }))
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
                position          = string
              }))
            }))
            label_match_statement = optional(object({
              key   = string
              scope = string
            }))
            regex_match_statement = optional(object({
              regex_string = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            # rule_group_reference_statement is not supported
            size_constraint_statement = optional(object({
              comparison_operator = string
              size                = number
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            sqli_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            xss_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
          }))
        }))
        not_statement = optional(object({
          # asn_match_statement is not supported
          byte_match_statement = optional(object({
            positional_constraint = string
            search_string         = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          geo_match_statement = optional(object({
            country_codes = list(string)
            forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
            }))
          }))
          ip_set_reference_statement = optional(object({
            arn = string
            ip_set_forwarded_ip_config = optional(object({
              fallback_behavior = string
              header_name       = string
              position          = string
            }))
          }))
          label_match_statement = optional(object({
            key   = string
            scope = string
          }))
          regex_match_statement = optional(object({
            regex_string = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          regex_pattern_set_reference_statement = optional(object({
            arn = string
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          # rule_group_reference_statement is not supported
          size_constraint_statement = optional(object({
            comparison_operator = string
            size                = number
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          sqli_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
          xss_match_statement = optional(object({
            field_to_match = object({
              all_query_arguments = optional(object({}))
              body                = optional(object({}))
              method              = optional(object({}))
              query_string        = optional(object({}))
              single_header = optional(object({
                name = string
              }))
              single_query_argument = optional(object({
                name = string
              }))
              uri_path = optional(object({}))
              cookies = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_cookies = optional(list(string), [])
                  excluded_cookies = optional(list(string), [])
                })
                match_scope       = string
                oversize_handling = string
              }))
              headers = optional(object({
                match_pattern = object({
                  all              = optional(object({}))
                  included_headers = optional(list(string))
                  excluded_headers = optional(list(string))
                })
                match_scope       = string
                oversize_handling = string
              }))
            })
            text_transformation = list(object({
              priority = number
              type     = string
            }))
          }))
        }))
      }))
    }))

    rate_based_statement = optional(object({
      limit              = number
      aggregate_key_type = optional(string)
      custom_key = optional(list(object({
        cookie = optional(object({
          name = string
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        forwarded_ip = optional(object({}))
        header = optional(object({
          name = string
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        http_method = optional(object({}))
        ip          = optional(object({}))
        label_namespace = optional(object({
          namespace = string
        }))
        query_argument = optional(object({
          name = string
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        query_string = optional(object({
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        uri_path = optional(object({
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
      })), [])
      evaluation_window_sec = optional(number)
      forwarded_ip_config = optional(object({
        fallback_behavior = string
        header_name       = string
      }))
      scope_down_statement = optional(object({
        # asn_match_statement is not supported
        byte_match_statement = optional(object({
          positional_constraint = string
          search_string         = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
          }))
        }))
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            fallback_behavior = string
            header_name       = string
            position          = string
          }))
        }))
        label_match_statement = optional(object({
          key   = string
          scope = string
        }))
        regex_match_statement = optional(object({
          regex_string = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        # rule_group_reference_statement is not supported
        size_constraint_statement = optional(object({
          comparison_operator = string
          size                = number
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        sqli_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        xss_match_statement = optional(object({
          field_to_match = object({
            all_query_arguments = optional(object({}))
            body                = optional(object({}))
            method              = optional(object({}))
            query_string        = optional(object({}))
            single_header = optional(object({
              name = string
            }))
            single_query_argument = optional(object({
              name = string
            }))
            uri_path = optional(object({}))
            cookies = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_cookies = optional(list(string), [])
                excluded_cookies = optional(list(string), [])
              })
              match_scope       = string
              oversize_handling = string
            }))
            headers = optional(object({
              match_pattern = object({
                all              = optional(object({}))
                included_headers = optional(list(string))
                excluded_headers = optional(list(string))
              })
              match_scope       = string
              oversize_handling = string
            }))
          })
          text_transformation = list(object({
            priority = number
            type     = string
          }))
        }))
        and_statement = optional(object({
          statements = list(object({
            # asn_match_statement is not supported
            byte_match_statement = optional(object({
              positional_constraint = string
              search_string         = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
              }))
            }))
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
                position          = string
              }))
            }))
            label_match_statement = optional(object({
              key   = string
              scope = string
            }))
            regex_match_statement = optional(object({
              regex_string = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            # rule_group_reference_statement is not supported
            size_constraint_statement = optional(object({
              comparison_operator = string
              size                = number
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            sqli_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            xss_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            not_statement = optional(object({
              statement = object({
                # asn_match_statement is not supported
                byte_match_statement = optional(object({
                  positional_constraint = string
                  search_string         = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                geo_match_statement = optional(object({
                  country_codes = list(string)
                  forwarded_ip_config = optional(object({
                    fallback_behavior = string
                    header_name       = string
                  }))
                }))
                ip_set_reference_statement = optional(object({
                  arn = string
                  ip_set_forwarded_ip_config = optional(object({
                    fallback_behavior = string
                    header_name       = string
                    position          = string
                  }))
                }))
                label_match_statement = optional(object({
                  key   = string
                  scope = string
                }))
                regex_match_statement = optional(object({
                  regex_string = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                regex_pattern_set_reference_statement = optional(object({
                  arn = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                # rule_group_reference_statement is not supported
                size_constraint_statement = optional(object({
                  comparison_operator = string
                  size                = number
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                sqli_match_statement = optional(object({
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                xss_match_statement = optional(object({
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
              })
            }))
          }))
        }))
        or_statement = optional(object({
          statements = list(object({
            # asn_match_statement is not supported
            byte_match_statement = optional(object({
              positional_constraint = string
              search_string         = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
              }))
            }))
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
                position          = string
              }))
            }))
            label_match_statement = optional(object({
              key   = string
              scope = string
            }))
            regex_match_statement = optional(object({
              regex_string = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            # rule_group_reference_statement is not supported
            size_constraint_statement = optional(object({
              comparison_operator = string
              size                = number
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            sqli_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            xss_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            not_statement = optional(object({
              statement = object({
                # asn_match_statement is not supported
                byte_match_statement = optional(object({
                  positional_constraint = string
                  search_string         = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                geo_match_statement = optional(object({
                  country_codes = list(string)
                  forwarded_ip_config = optional(object({
                    fallback_behavior = string
                    header_name       = string
                  }))
                }))
                ip_set_reference_statement = optional(object({
                  arn = string
                  ip_set_forwarded_ip_config = optional(object({
                    fallback_behavior = string
                    header_name       = string
                    position          = string
                  }))
                }))
                label_match_statement = optional(object({
                  key   = string
                  scope = string
                }))
                regex_match_statement = optional(object({
                  regex_string = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                regex_pattern_set_reference_statement = optional(object({
                  arn = string
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                # rule_group_reference_statement is not supported
                size_constraint_statement = optional(object({
                  comparison_operator = string
                  size                = number
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                sqli_match_statement = optional(object({
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
                xss_match_statement = optional(object({
                  field_to_match = object({
                    all_query_arguments = optional(object({}))
                    body                = optional(object({}))
                    method              = optional(object({}))
                    query_string        = optional(object({}))
                    single_header = optional(object({
                      name = string
                    }))
                    single_query_argument = optional(object({
                      name = string
                    }))
                    uri_path = optional(object({}))
                    cookies = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_cookies = optional(list(string), [])
                        excluded_cookies = optional(list(string), [])
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                    headers = optional(object({
                      match_pattern = object({
                        all              = optional(object({}))
                        included_headers = optional(list(string))
                        excluded_headers = optional(list(string))
                      })
                      match_scope       = string
                      oversize_handling = string
                    }))
                  })
                  text_transformation = list(object({
                    priority = number
                    type     = string
                  }))
                }))
              })
            }))
          }))
        }))
        not_statement = optional(object({
          statements = list(object({
            # asn_match_statement is not supported
            byte_match_statement = optional(object({
              positional_constraint = string
              search_string         = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
              }))
            }))
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                fallback_behavior = string
                header_name       = string
                position          = string
              }))
            }))
            label_match_statement = optional(object({
              key   = string
              scope = string
            }))
            regex_match_statement = optional(object({
              regex_string = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            # rule_group_reference_statement is not supported
            size_constraint_statement = optional(object({
              comparison_operator = string
              size                = number
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            sqli_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
            xss_match_statement = optional(object({
              field_to_match = object({
                all_query_arguments = optional(object({}))
                body                = optional(object({}))
                method              = optional(object({}))
                query_string        = optional(object({}))
                single_header = optional(object({
                  name = string
                }))
                single_query_argument = optional(object({
                  name = string
                }))
                uri_path = optional(object({}))
                cookies = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_cookies = optional(list(string), [])
                    excluded_cookies = optional(list(string), [])
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
                headers = optional(object({
                  match_pattern = object({
                    all              = optional(object({}))
                    included_headers = optional(list(string))
                    excluded_headers = optional(list(string))
                  })
                  match_scope       = string
                  oversize_handling = string
                }))
              })
              text_transformation = list(object({
                priority = number
                type     = string
              }))
            }))
          }))
        }))
      }))
    }))
  }))

  default = []
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource."
  type        = map(string)
  default     = null
}

variable "enabled_web_acl_association" {
  description = "(Optional) Whether to create ALB association with WebACL."
  type        = bool
  default     = true
}

variable "resource_arn" {
  description = " (Required) The Amazon Resource Name (ARN) of the resource to associate with the web ACL."
  type        = list(string)
}

variable "enabled_logging_configuration" {
  description = "(Optional) Whether to create logging configuration."
  type        = bool
  default     = false
}

variable "log_destination_configs" {
  type        = string
  description = "(Required) The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
  default     = null
}

variable "redacted_fields" {
  type        = list(any)
  description = "(Optional) The parts of the request that you want to keep out of the logs. Up to 100 redacted_fields blocks are supported."
  default     = null
}

variable "logging_filter" {
  type        = any
  description = "(Optional) A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  default     = null
}
