output "lb" {
  description = "Load balancer"
  value       = module.create_loadbalancer_application.lb
}

output "lb_dns_name" {
  description = "Load balancer DNS name"
  value       = module.create_loadbalancer_application.lb_dns_name
}

output "lb_arn" {
  description = "Load balancer ARN"
  value       = module.create_loadbalancer_application.lb_arn
}

output "lb_zone_id" {
  description = "Load balancer zone ID"
  value       = module.create_loadbalancer_application.lb_zone_id
}

output "target_groups" {
  description = "Target groups"
  value       = module.create_loadbalancer_application.target_groups
}

output "target_groups_ids" {
  description = "Target group IDs"
  value       = module.create_loadbalancer_application.target_groups_ids
}

output "target_groups_arns" {
  description = "Target group ARNs"
  value       = module.create_loadbalancer_application.target_groups_arns
}

output "listeners" {
  description = "Listeners"
  value       = module.create_loadbalancer_application.listeners
}

output "listeners_arns" {
  description = "Listeners ARNs"
  value       = module.create_loadbalancer_application.listeners_arns
}

output "target_groups_attachment" {
  description = "Target groups attachment"
  value       = module.create_loadbalancer_application.target_groups_attachment
}

output "acm_certificate" {
  description = "ACM certificate"
  value       = module.create_acm_certificate.acm_certificate
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.create_acm_certificate.acm_certificate_arn
}

output "acm_certificate_domain_validation_options" {
  description = "ACM certificate domain validation options"
  value       = module.create_acm_certificate.acm_certificate_domain_validation_options
}

output "records_domain_validation" {
  description = "Records domain validation"
  value       = module.create_acm_certificate.records_domain_validation
}

output "acm_certificate_validation" {
  description = "ACM certificate validation"
  value       = module.create_acm_certificate.acm_certificate_validation
}

###
output "zone" {
  description = "Route53 zone hosted"
  value       = module.create_hosted_zone.zone
}

output "zone_id" {
  description = "Zone ID zone hosted"
  value       = module.create_hosted_zone.zone_id
}

output "zone_arn" {
  description = "ARN zone hosted"
  value       = module.create_hosted_zone.zone_arn
}

output "zone_name_servers" {
  description = "Name servers zone hosted"
  value       = module.create_hosted_zone.zone_name_servers
}

output "zone_name" {
  description = "Zone name zone hosted"
  value       = module.create_hosted_zone.zone_name
}

output "delegation_set" {
  description = "Delegation set"
  value       = module.create_hosted_zone.delegation_set
}

output "delegation_set_id" {
  description = "Delegation set ID"
  value       = module.create_hosted_zone.delegation_set_id
}

output "delegation_set_arn" {
  description = "Delegation set ARN"
  value       = module.create_hosted_zone.delegation_set_arn
}

output "records" {
  description = "Records sets"
  value       = module.create_hosted_zone.records
}

output "records_names" {
  description = "Records sets names"
  value       = module.create_hosted_zone.records_names
}

output "records_fqdn" {
  description = "Records sets fqdn"
  value       = module.create_hosted_zone.records_fqdn
}
