# DNS + Traffic Management (GLOBAL). Steering FAILOVER con Health Checks.
resource "oci_dns_zone" "this" {
  compartment_id = var.compartment_id
  name           = var.zone_name
  zone_type      = "PRIMARY"
  scope          = "GLOBAL"
  freeform_tags  = var.freeform_tags
}

resource "oci_health_checks_http_monitor" "app" {
  compartment_id      = var.compartment_id
  display_name        = "app-health"
  protocol            = "HTTP"
  targets             = compact([var.primary_ip, var.standby_ip])
  port                = 80
  path                = var.health_path
  interval_in_seconds = 30
  timeout_in_seconds  = 10
  freeform_tags       = var.freeform_tags
}

resource "oci_dns_steering_policy" "this" {
  compartment_id          = var.compartment_id
  display_name            = "app-failover"
  template                = "FAILOVER"
  health_check_monitor_id = oci_health_checks_http_monitor.app.id
  ttl                     = 30

  answers {
    name  = "primary"
    rtype = "A"
    rdata = var.primary_ip
    pool  = "primary"
  }
  answers {
    name  = "standby"
    rtype = "A"
    rdata = var.standby_ip
    pool  = "standby"
  }

  rules {
    rule_type = "FILTER"
    default_answer_data {
      answer_condition = "answer.isDisabled != true"
      should_keep      = true
    }
  }
  rules {
    rule_type = "HEALTH"
  }
  rules {
    rule_type = "PRIORITY"
    default_answer_data {
      answer_condition = "answer.pool == 'primary'"
      value            = 1
    }
    default_answer_data {
      answer_condition = "answer.pool == 'standby'"
      value            = 2
    }
  }
  rules {
    rule_type     = "LIMIT"
    default_count = 1
  }

  freeform_tags = var.freeform_tags
}

resource "oci_dns_steering_policy_attachment" "this" {
  steering_policy_id = oci_dns_steering_policy.this.id
  zone_id            = oci_dns_zone.this.id
  domain_name        = "${var.app_record_name}.${var.zone_name}"
  display_name       = "app-failover-attachment"
}
