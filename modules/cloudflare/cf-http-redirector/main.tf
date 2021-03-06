terraform {
  required_version = ">= 0.11.0"
}



//Need Filter --> Firewall Rule
module "http-filter" {
  source = "../filter"
  zone_id = "${var.zone_id}"
  URI = "${var.uri_pattern}"
  UA = "${var.user_agent}"
  referer = "${var.referer}"
  filter_selection = "${var.filter_selection}"
}

module "http-firewall" {
  source = "../firewall_rule"
  zone_id = "${var.zone_id}"
  description = "${var.description}"
  f_id = "${module.http-filter.filter_id}"
  action = "block"
}

//Then worker route and finally a script to do the redirection
//make sure we name the script the same in deploy.
module "worker-route" {
  source = "../worker_creation"
  matching_uri = "${format("%s%s",var.my_domain_name, var.uri_pattern)}"
  worker_name = "${var.worker_name}"
  worker_script_content = "${replace(var.worker_script_content,"C2DOMAIN",var.c2_server)}"
  zid = "${var.zone_id}"
}