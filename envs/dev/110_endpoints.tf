# VPC Endpoints
module "vpce_rds" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.rds"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_ssm" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.ssm"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_ssm_messages" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.ssmmessages"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_ecr_api" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.ecr.api"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_ecr_dkr" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.ecr.dkr"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_cw_logs" {
  source              = "../../modules/vpc_endpoint"
  vpc_id              = module.vpc_core.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.region}.logs"
  subnet_ids          = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids  = [module.endpoint_sg.attrs.id]
  private_dns_enabled = true
}

module "vpce_s3" {
  source            = "../../modules/vpc_endpoint"
  vpc_id            = module.vpc_core.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${local.region}.s3"
  route_table_ids   = [module.vpc_routing_private_1a.route_table.id, module.vpc_routing_private_1c.route_table.id]
}
