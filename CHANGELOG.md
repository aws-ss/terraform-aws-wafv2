# Changelog

All notable changes to this project will be documented in this file.

## [3.11.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.10.1...v3.11.0) (2025-06-19)


### Features

* Support ASN match rule statement ([97b8b8b](https://github.com/aws-ss/terraform-aws-wafv2/commit/97b8b8bd4729c1b3a9e983d362f3055fd68a255f))

### [3.10.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.10.0...v3.10.1) (2025-06-14)


### Bug Fixes

* Support multiple custom response body/header ([d901f3e](https://github.com/aws-ss/terraform-aws-wafv2/commit/d901f3ec2cc08c1aa32fe93a8c250d1c64bdc445))

## [3.10.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.9.0...v3.10.0) (2025-06-03)


### Features

* Support 'rule_label' arguments in rule ([4d3a8b1](https://github.com/aws-ss/terraform-aws-wafv2/commit/4d3a8b1b71857d5c92428bb8a5930f80df6ece3f))

## [3.9.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.8.1...v3.9.0) (2025-06-03)


### Features

* Support 'association_config' argument ([54d956c](https://github.com/aws-ss/terraform-aws-wafv2/commit/54d956c56e5e165faea0e3b9b7161f9a8b3e7adb))

### [3.8.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.8.0...v3.8.1) (2025-05-25)


### Bug Fixes

* custom_key always yields an empty list ([964a93b](https://github.com/aws-ss/terraform-aws-wafv2/commit/964a93b97cb57c7dbddea8ec587e5cab56ee1c5d))

## [3.8.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.7.3...v3.8.0) (2025-03-15)


### Features

* Support multiple conditions in 'redacted_fields' ([36a4079](https://github.com/aws-ss/terraform-aws-wafv2/commit/36a4079a8a1eec3059d769e7e3d1d1fff5574a47))

### [3.7.3](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.7.2...v3.7.3) (2025-03-14)


### Bug Fixes

* 'rule_action_override' challenge config condition ([7a085b6](https://github.com/aws-ss/terraform-aws-wafv2/commit/7a085b6d50173ce7863d24983b82e984d3f2442a))
* rule_action_override challenge config condition ([231b436](https://github.com/aws-ss/terraform-aws-wafv2/commit/231b436b536c0ef0999a3a71ebc1ff064385854b))

### [3.7.2](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.7.1...v3.7.2) (2025-02-24)


### Bug Fixes

* Add custom_response support for 'block' action in rule-group ([bc05415](https://github.com/aws-ss/terraform-aws-wafv2/commit/bc05415d9b26cd1e0a80d2a1e3053be577234017))

### [3.7.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.7.0...v3.7.1) (2025-02-24)


### Bug Fixes

* Ensure for_each is always a list to prevent null assignment issues ([a784773](https://github.com/aws-ss/terraform-aws-wafv2/commit/a7847736f476f0c3b3c9a489b68bd9f0cab47fe4))

## [3.7.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.6.1...v3.7.0) (2025-01-30)


### Features

* Added AWSManagedRules rule sets to WAFv2 ([146f78e](https://github.com/aws-ss/terraform-aws-wafv2/commit/146f78e54e6e7c38c6aafbbe24030f186aeee7e8))

### [3.6.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.6.0...v3.6.1) (2025-01-03)


### Bug Fixes

* Update terraform/providers version ([448add5](https://github.com/aws-ss/terraform-aws-wafv2/commit/448add546a1f4f919e06a4c327fbcc3e90534b1c))

## [3.6.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.5.0...v3.6.0) (2024-12-31)


### Features

* Add 'custom_keys' in rate_based_statement ([4a3c5be](https://github.com/aws-ss/terraform-aws-wafv2/commit/4a3c5be05a34485fe12a61967b03a1d7906190b0))

## [3.5.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.4.0...v3.5.0) (2024-12-27)


### Features

* Add 'challenge' argument in action ([322450e](https://github.com/aws-ss/terraform-aws-wafv2/commit/322450e10a4fec0807003ee8fe54eab69e93c968))

## [3.4.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.3.0...v3.4.0) (2024-12-27)


### Features

* Add 'forwarded_ip_config' argument in geo_match_statement ([398c50e](https://github.com/aws-ss/terraform-aws-wafv2/commit/398c50e9b00df9e77d434b002e3f3df9cf883471))

## [3.3.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.2.0...v3.3.0) (2024-12-27)


### Features

* Add 'evaluation_window_sec' argument in rate_based_statement ([42c2322](https://github.com/aws-ss/terraform-aws-wafv2/commit/42c232264f7df83c58d16e2f4ae89eeecbd99aae))

## [3.2.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.1.1...v3.2.0) (2024-07-31)


### Features

* Add 'ip_set_forwarded_ip_config' argument in ip_set_reference_statement ([69a5bac](https://github.com/aws-ss/terraform-aws-wafv2/commit/69a5bac3fda1c305209f4d2eb5abd01f78c560eb))

### [3.1.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.1.0...v3.1.1) (2024-05-23)


### Bug Fixes

* Syntax to search for 'rule_label' value name ([112c566](https://github.com/aws-ss/terraform-aws-wafv2/commit/112c56698866d21bfcbb67f2a2c3dcb5b93354fe))

## [3.1.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v3.0.0...v3.1.0) (2024-05-23)


### Features

* Support 'rule_label' arguments in aws_wafv2_rule_group ([468b2ca](https://github.com/aws-ss/terraform-aws-wafv2/commit/468b2ca7774f7b37317677c01686dee7634b10c4))

## [3.0.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v2.3.0...v3.0.0) (2024-03-19)


### ⚠ BREAKING CHANGES

* Update logical rule statements

### Features

* Update logical rule statements ([0d81ff8](https://github.com/aws-ss/terraform-aws-wafv2/commit/0d81ff8e90c03216af8e6566de0949cdafb5b5f3))

## [2.3.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v2.2.0...v2.3.0) (2023-08-26)


### Features

* Add contents for 'FieldToMatch' ([a4531e3](https://github.com/aws-ss/terraform-aws-wafv2/commit/a4531e395c91512f6571123ae5c4740c09a603b5))

## [2.2.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v2.1.0...v2.2.0) (2023-08-15)


### Features

* Add 'rule_action_override' field ([a072971](https://github.com/aws-ss/terraform-aws-wafv2/commit/a0729710c1b1921d125a827541b91c1d8091cac0))

## [2.1.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v2.0.1...v2.1.0) (2023-08-15)


### Features

* Configure multiple "text_transformation" ([c607cd1](https://github.com/aws-ss/terraform-aws-wafv2/commit/c607cd1f611a70f0dff266edd8be247de59eba67))

### [2.0.1](https://github.com/aws-ss/terraform-aws-wafv2/compare/v2.0.0...v2.0.1) (2023-07-15)


### Bug Fixes

* attributes must be accessed on specific instances ([12ddd40](https://github.com/aws-ss/terraform-aws-wafv2/commit/12ddd40fdf90066c83a036a18b227f0f793bda0d))

## [2.0.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.5.0...v2.0.0) (2023-07-15)


### ⚠ BREAKING CHANGES

* Merging modules

### Features

* Merging modules ([1e1dff4](https://github.com/aws-ss/terraform-aws-wafv2/commit/1e1dff43e600d4206b6d3a2c211250a3b79a46ea))

## [1.5.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.4.0...v1.5.0) (2023-05-31)


### Features

* Support custom response when the blocked ([7d4df68](https://github.com/aws-ss/terraform-aws-wafv2/commit/7d4df68c2b649e4bf4b5b6537fef48383e0aba0a))

## [1.4.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.3.0...v1.4.0) (2023-04-13)


### Features

* Support logging configuration ([15399f2](https://github.com/aws-ss/terraform-aws-wafv2/commit/15399f2cf057524edd8ef7fa215aca9839834833))

## [1.3.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.2.0...v1.3.0) (2023-04-12)


### Features

* Support create Rule Group resource. ([c9ee3e4](https://github.com/aws-ss/terraform-aws-wafv2/commit/c9ee3e4e5c8d211e865b20cc9482b8ff632df4f7))

## [1.2.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.1.0...v1.2.0) (2023-04-12)


### Features

* Support WebACL association ([dc0e369](https://github.com/aws-ss/terraform-aws-wafv2/commit/dc0e369f20f1079045696ded3ee48f228793b895))

## [1.1.0](https://github.com/aws-ss/terraform-aws-wafv2/compare/v1.0.0...v1.1.0) (2023-04-10)


### Features

* Support for create IPSet ([fbd015b](https://github.com/aws-ss/terraform-aws-wafv2/commit/fbd015bc2a3f642be96337f78e2343dca0b83fea))

## 1.0.0 (2023-04-09)


### ⚠ BREAKING CHANGES

* Update `aws_wafv2_web_acl` module

### Features

* Update `aws_wafv2_web_acl` module ([d4ba232](https://github.com/aws-ss/terraform-aws-wafv2/commit/d4ba232761225c6ebc5e97031bd517442b38c4f2))
