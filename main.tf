data "aws_lb" "alb_existing" {
  arn = var.lb_arn_exists
}

data "aws_route53_zone" "hosted_zone" {
  zone_id      = var.zone_id_route53
  private_zone = var.zone_id_route53_type
}

module "create_acm_certificate" {
  source               = "web-virtua-aws-multi-account-modules/acm/aws"
  zone_id_route53      = var.zone_id_route53
  name_prefix          = var.acm_name != null ? var.acm_name : "${var.alb_name}-acm"
  master_domain        = var.master_domain
  alternatives_domains = var.alternatives_domains
}

module "create_loadbalancer_application" {
  source             = "web-virtua-aws-multi-account-modules/load-balancer/aws"
  load_balancer_type = "application"
  name_prefix        = var.alb_name
  lb_arn_exists      = var.lb_arn_exists
  security_groups    = var.security_groups
  subnets            = var.subnets
  subnets_mapping    = var.subnets_mapping

  access_logs                      = var.access_logs
  idle_timeout                     = var.idle_timeout
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type
  preserve_host_header             = var.preserve_host_header
  internal                         = var.internal
  enable_waf_fail_open             = var.enable_waf_fail_open
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  desync_mitigation_mode           = var.desync_mitigation_mode
  customer_owned_ipv4_pool         = var.customer_owned_ipv4_pool
  use_tags_default                 = var.use_tags_default
  elb_ssl_policy_default_listener  = var.elb_ssl_policy_default_listener
  load_balancer_create_timeout     = var.load_balancer_create_timeout
  load_balancer_update_timeout     = var.load_balancer_update_timeout
  load_balancer_delete_timeout     = var.load_balancer_delete_timeout
  ou_name                          = var.ou_name
  tags                             = var.tags

  target_groups = [
    {
      target_type        = var.target_group_type
      port               = var.target_group_port
      protocol           = "HTTP"
      health_check       = var.target_group_health_check
      targets_attachment = var.target_group_attachments
      stickiness         = var.target_group_stickiness

      listeners = [
        {
          port     = var.listener_port
          protocol = "HTTP"
          default_actions = [
            {
              type = "redirect"
              redirect = {
                port        = 443
                protocol    = "HTTPS"
                status_code = "HTTP_301"
              }
            }
          ]
        },
        {
          port            = 443
          protocol        = "HTTPS"
          certificate_arn = module.create_acm_certificate.acm_certificate_arn
          default_actions = [
            {
              type = "forward"
            }
          ]
        },
      ]
    },
  ]

  depends_on = [
    module.create_acm_certificate
  ]
}

module "create_hosted_zone" {
  source                      = "web-virtua-aws-multi-account-modules/route53/aws"
  set_one_zone_id_all_records = data.aws_route53_zone.hosted_zone.zone_id

  records = concat([{
    name = substr(replace(var.master_domain, data.aws_route53_zone.hosted_zone.name, ""), 0, length(replace(var.master_domain, data.aws_route53_zone.hosted_zone.name, "")) - 1)
    type = "A"
    alias = {
      name                   = var.lb_arn_exists != null ? data.aws_lb.alb_existing.dns_name : module.create_loadbalancer_application.lb_dns_name
      zone_id                = var.lb_arn_exists != null ? data.aws_lb.alb_existing.zone_id : module.create_loadbalancer_application.lb_zone_id
      evaluate_target_health = true
    }
    }], flatten([
    for domain in var.alternatives_domains != null ? var.alternatives_domains : [] : [
      {
        name = replace(domain, data.aws_route53_zone.hosted_zone.name, "")
        type = "CNAME"
        records = [
          var.master_domain
        ]
      }
    ]
  ]))

  depends_on = [
    module.create_loadbalancer_application
  ]
}
