resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = var.vpc_endpoint_type
  service_name        = var.service_name
  subnet_ids          = var.vpc_endpoint_type == "Interface" ? var.subnet_ids : null
  security_group_ids  = var.vpc_endpoint_type == "Interface" ? var.security_group_ids : null
  private_dns_enabled = var.vpc_endpoint_type == "Interface" ? var.private_dns_enabled : null
  route_table_ids     = var.vpc_endpoint_type == "Gateway" ? var.route_table_ids : null
}
