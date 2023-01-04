# AWS application load balancer with HTTPS and records for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of the application load balancer with HTTPS and records across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of application load balancer with HTTPS and records configurations for this module:

- Load balancer
- Target groups
- Listeners
- Target groups attachment
- ACM
- Record sets

## Usage exemples
### OBS: This module is able to create a configuration with one load balancer existing or creating a new, if definet the lb_arn_exists variable with ARN, the configurations of the target groups, listeners and attachments will be over the load balancer set else will be create a new load balancer and the configuration will be over it.

### Create new load balancer application type, using only HTTP with ACM, records sets and target to instance EC2

```hcl
module "alb_acm_records_test" {
  source          = "web-virtua-aws-multi-account-modules/load-balancer/aws"
  zone_id_route53 = data.aws_route53_zone.hosted_zone.zone_id
  alb_name        = "tf-alb-acm-records"
  master_domain   = "test.eks.dominio.com"

  alternatives_domains = [
    "www.test.eks.dominio.com"
  ]

  target_group_type = "instance"
  target_group_port = 80
  listener_port     = 80

  target_group_health_check = {
    path = "/"
    port = 80
  }

  target_group_attachments = [
    {
      target_id = "i-0618a...85fb1f"
      ip        = 80
    },
    {
      target_id = "i-02a5d04...209b8f"
      ip        = 80
    },
  ]

  security_groups = [
    "sg-0a0bc4269...33267"
  ]

  subnets = [
    "subnet-05b87...a88e8"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Using a load balancer application type existing, using only HTTP with ACM, records sets and target to instance EC2

```hcl
module "alb_acm_records_test" {
  source          = "web-virtua-aws-multi-account-modules/load-balancer/aws"
  zone_id_route53 = data.aws_route53_zone.hosted_zone.zone_id
  alb_name        = "tf-alb-acm-records"
  master_domain   = "test.eks.dominio.com"
  lb_arn_exists   = "arn:aws:elasticloadbalancing:us-east-1:385...012:loadbalancer/app/tf-lb-http-test/fccc22...a557"

  alternatives_domains = [
    "www.test.eks.dominio.com"
  ]

  target_group_type = "instance"
  target_group_port = 80
  listener_port     = 80

  target_group_health_check = {
    path = "/"
    port = 80
  }

  target_group_attachments = [
    {
      target_id = "i-0618a...85fb1f"
      ip        = 80
    },
    {
      target_id = "i-02a5d04...209b8f"
      ip        = 80
    },
  ]

  security_groups = [
    "sg-0a0bc4269...33267"
  ]

  subnets = [
    "subnet-05b87...a88e8"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| alb_name | `string` | `null` | yes | Name prefix to ALB | `-` |
| master_domain | `string` | `null` | yes | Master domain | `-` |
| acm_name | `string` | `null` | no | Name prefix to ACM | `-` |
| zone_id_route53 | `string` | `null` | yes | Zone ID of the Route 53 AWS | `-` |
| zone_id_route53_type | `bool` | `false` | no | Set if hosted zone is private | `*`false <br> `*`true |
| alternatives_domains | `list(string)` | `null` | no | Alternatives domains to master domain | `-` |
| lb_arn_exists | `string` | `null` | no | If this variable is defined with the LB ARN, then will be use the a load balancer existing and don't will be create a new load balancer else will be created a load balancer | `-` |
| security_groups | `list(string)` | `null` | no | A list of security group IDs to assign to the LB, It's only valid for Load Balancers of type application" | `-` |
| subnets | `list(string)` | `null` | no | Is required at least two subnets different Availability Zones. Is a list of subnet IDs to attach to the LB, these subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource. Note that subnets or subnet_mapping is required | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| tags | `map(any)` | `{}` | no | Tags to load balancer resourcers | `-` |
| access_logs | `object` | `null` | no | Define one S3 bucket to keep access logs | `-` |
| idle_timeout | `number` | `400` | no | The time in seconds that the connection is allowed to be idle, It's only valid for Load Balancers of type application | `-` |
| enable_deletion_protection | `bool` | `false` | no | If true, deletion of the load balancer will be disabled via the AWS API, this will prevent Terraform from deleting the load balancer | `*`false <br> `*`true |
| enable_cross_zone_load_balancing | `bool` | `true` | no | If true, cross-zone load balancing of the load balancer will be enabled, this is a network load balancer feature | `*`false <br> `*`true |
| enable_http2 | `bool` | `true` | no | Indicates whether HTTP/2 is enabled in application load balancer | `*`false <br> `*`true |
| ip_address_type | `string` | `ipv4` | no | The type of IP addresses used by the subnets for your load balancer, can be ipv4 or dualstack. Please note that internal LBs can only use ipv4 as the ip_address_type. You can only change to dualstack ip_address_type if the selected subnets are IPv6 enabled | `-` |
| preserve_host_header | `bool` | `false` | no | Indicates whether Host header should be preserve and forward to targets without any change | `*`false <br> `*`true |
| internal | `bool` | `false` | no | If true, the LB will be internal | `*`false <br> `*`true |
| enable_waf_fail_open | `bool` | `false` | no | Indicates whether to route requests to targets if lb fails to forward the request to AWS WAF | `*`false <br> `*`true |
| load_balancer_create_timeout | `string` | `10m` | no | Timeout value when creating the ALB | `-` |
| load_balancer_update_timeout | `string` | `10m` | no | Timeout value when updating the ALB | `-` |
| load_balancer_delete_timeout | `string` | `10m` | no | Timeout value when deleting the ALB | `-` |
| subnets_mapping | `list(object)` | `null` | no | Can be set in network load balancers attaching one or more subnets. Note that subnets or subnet_mapping is required | `-` |
| drop_invalid_header_fields | `bool` | `false` | no | Indicates whether invalid header fields are dropped in application load balancers | `*`false <br> `*`true |
| desync_mitigation_mode | `string` | `defensive` | no | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync, can be monitor, defensive, strictest | `-` |
| customer_owned_ipv4_pool | `string` | `null` | no | The ID of the customer owned ipv4 pool to use for this load balancer | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to hosted zone | `*`false <br> `*`true |
| elb_ssl_policy_default_listener | `string` | `ELBSecurityPolicy-2016-08` | no | ELB SSL policy to listeners, should be use when TLS is active | `-` |
| target_group_type | `string` | `instance` | no | Type of target that you must specify when registering targets with this target group, can be instance, IP or lambda | `-` |
| target_group_port | `number` | `80` | no | Port to target group | `-` |
| target_group_health_check | `object` | `object` | no | Health check to target group | `-` |
| target_group_stickiness | `object` | `object` | no | Stickiness to target group | `-` |
| target_group_attachments | `list(object)` | `null` | yes | Attachments of targets ID's to target group | `-` |
| listener_port | `number` | `80` | no | HTTP port listener | `-` |


* Model of variable access_logs
```hcl
variable "access_logs" {
  description = "Define one S3 bucket to keep access logs"
  type = object({
    bucket  = string
    prefix  = optional(string, null)
    enabled = optional(bool, true)
  })
  default = [
    bucket  = "bucket-logs"
    prefix  = "errors"
    enabled = true
  ]
}
```

* Model of variable subnets_mapping
```hcl
variable "subnets_mapping" {
  description = "Can be set in network load balancers attaching one or more subnets. Note that subnets or subnet_mapping is required"
  type = list(object({
    subnet_id            = string
    private_ipv4_address = optional(string, null)
    ipv6_address         = optional(string, null)
    allocation_id        = optional(string, null)
  }))
  default = [
    {
      subnet_id = "subnet-05b87...a88e8"
    }
  ]
}
```

* Model of variable target_group_health_check
```hcl
variable "target_group_health_check" {
  description = "Health check to target group"
  type = object({
    path                = optional(string)
    port                = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    protocol            = optional(string)
    matcher             = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
    enabled             = optional(bool)
  })
  default = {
    path = "/"
    port = 80
  }
}
```

* Model of variable target_group_stickiness
```hcl
variable "target_group_stickiness" {
  description = "Stickiness to target group"
  type = object({
    enabled         = optional(bool)
    type            = optional(string)
    cookie_name     = optional(string)
    cookie_duration = optional(string)
  })
  default = {
    enabled = true
    type    = "lb_cookie"
  }
}
```

* Model of variable target_group_attachments
```hcl
variable "target_group_attachments" {
  description = "Attachments of targets ID's to target group"
  type = list(object({
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = [
    {
      target_id = "i-0618a2...5fb1f"
      ip        = 80
    },
    {
      target_id = "i-02a5d0...209b8f"
      ip        = 80
    },
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [aws_lb.create_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.create_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_listener.create_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group_attachment.create_target_groups_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_acm_certificate.create_acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.create_acm_certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.create_record_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.create_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_record.create_record_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_delegation_set.create_delegation_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_delegation_set) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `lb` | All load balancer |
| `lb_dns_name` | Load balancer DNS name |
| `lb_arn` | Load balancer ARN |
| `lb_zone_id` | Load balancer zone ID |
| `target_groups` | Target groups |
| `target_groups_ids` | Target group IDs |
| `target_groups_arns` | Target group ARNs |
| `listeners` | Listeners |
| `listeners_arns` | Listeners ARNs |
| `target_groups_attachment` | Target groups attachment |
| `acm_certificate` | All ACM certificate |
| `acm_certificate_arn` | ACM certificate ARN |
| `acm_certificate_domain_validation_options` | ACM certificate domain validation options |
| `records_domain_validation` | Records domain validation |
| `acm_certificate_validation` | ACM certificate validation |
| `zone` | All Route53 zone hosted |
| `zone_id` | Zone ID to zone hosted |
| `zone_arn` | ARN to zone hosted |
| `zone_name_servers` | Name servers to zone hosted |
| `zone_name` | Zone name to zone hosted|
| `delegation_set` | All delegation set |
| `delegation_set_id` | Delegation set ID |
| `delegation_set_arn` | Delegation set ARN |
| `records` | All records sets |
| `records_names` | All records sets names |
| `records_fqdn` | All records sets FQDN |
