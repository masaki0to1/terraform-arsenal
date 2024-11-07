## Network ##
# VPC Core
module "vpc_core" {
  source                  = "../../modules/vpc_core"
  env                     = local.env
  vpc_conf                = local.vpc_conf.main_vpc
  private_subnets         = local.subnet_conf.private_subnets
  public_subnets          = local.subnet_conf.public_subnets
  map_public_ip_on_launch = true
}

# Elastic IP
module "eip_nat_1a" {
  source = "../../modules/elastic_ip"
}

module "eip_nat_1c" {
  source = "../../modules/elastic_ip"
}

module "eip_redash_1a" {
  source      = "../../modules/elastic_ip"
  instance_id = module.ec2_redash_1a.attrs.id
}

# Internet Gateway
module "igw" {
  source = "../../modules/internet_gateway"
  vpc_id = module.vpc_core.vpc.id
}

# NAT Gateway
module "nat_1a" {
  source    = "../../modules/nat_gateway"
  eip_id    = module.eip_nat_1a.attrs.id
  subnet_id = module.vpc_core.public_subnets["public-1a"].id
}

module "nat_1c" {
  source    = "../../modules/nat_gateway"
  eip_id    = module.eip_nat_1c.attrs.id
  subnet_id = module.vpc_core.public_subnets["public-1c"].id
}

# VPC Routing
module "vpc_routing_public" {
  source           = "../../modules/vpc_routing"
  vpc_id           = module.vpc_core.vpc.id
  route_table_name = "${local.name_prefix}-public"
  routes = {
    route_default_public = {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id             = module.igw.attrs.id
    }
  }
  # public subnets share a common route table
  subnet_ids = [
    module.vpc_core.public_subnets["public-1a"].id,
    module.vpc_core.public_subnets["public-1c"].id
  ]
}

module "vpc_routing_private_1a" {
  source           = "../../modules/vpc_routing"
  vpc_id           = module.vpc_core.vpc.id
  route_table_name = "${local.name_prefix}-private-1a"
  routes = {
    route_default_1a = {
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = module.nat_1a.attrs.id
    }
    # route_vpc_peering_1a = {
    #   destination_cidr_block    = "172.16.0.0/16"
    #   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    # }
    # route_internal_1a = {
    #   destination_cidr_block = "10.0.0.0/8"
    #   transit_gateway_id     = aws_transit_gateway.main.id
    # }
  }
  subnet_ids = [
    module.vpc_core.private_subnets["private-1a"].id
  ]
}

module "vpc_routing_private_1c" {
  source           = "../../modules/vpc_routing"
  vpc_id           = module.vpc_core.vpc.id
  route_table_name = "${local.name_prefix}-private-1c"
  routes = {
    route_default_1c = {
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = module.nat_1c.attrs.id
    }
  }
  subnet_ids = [
    module.vpc_core.private_subnets["private-1c"].id
  ]
}