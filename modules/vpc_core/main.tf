resource "aws_vpc" "main" {
  cidr_block           = var.vpc_conf.cidr_block
  enable_dns_hostnames = var.vpc_conf.enable_dns_hostnames
  enable_dns_support   = var.vpc_conf.enable_dns_support
  instance_tenancy     = var.vpc_conf.instance_tenancy

  tags = {
    Name = var.vpc_conf.name
  }
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
}
