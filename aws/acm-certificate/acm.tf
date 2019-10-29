locals {
  // Get distinct list of domains and SANs
  distinct_domain_names = distinct(concat([var.domain_name], data.template_file.breakup_san.*.rendered))

  // Copy domain_validation_options for the distinct domain names
  validation_domains = [for k, v in aws_acm_certificate.cert.domain_validation_options : tomap(v) if contains(local.distinct_domain_names, v.domain_name)]
}

data "template_file" "breakup_san" {
  count = length(var.subject_alternative_names)

  template = replace(var.subject_alternative_names[count.index], "*.", "")
}

# Create the certificate request
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
    ignore_changes = ["subject_alternative_names"] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
  }
}

resource "aws_route53_record" "validation" {
  count = var.validation_method == "DNS" ? length(local.distinct_domain_names) : 0

  zone_id = var.dns_zone_id
  name    = local.validation_domains[count.index]["resource_record_name"]
  type    = local.validation_domains[count.index]["resource_record_type"]
  ttl     = 60

  records = [
    local.validation_domains[count.index]["resource_record_value"]
  ]
}

# Validate the certificate using the DNS validation records created
# This resource represents a successful validation of an ACM certificate in concert with other resources.
# WARNING: This resource implements a part of the validation workflow. It does not represent a real-world entity in AWS, therefore changing or deleting this resource on its own has no immediate effect.
resource "aws_acm_certificate_validation" "cert" {
  count = "${var.validation_method == "DNS" && var.wait_for_validation ? 1 : 0 }"
  certificate_arn = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = "${aws_route53_record.validation.*.fqdn}"
}