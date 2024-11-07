# Security Groups
module "public_alb_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-public-alb-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS all inbound traffic and all outbound traffic."

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS inbound"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP inbound"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "private_alb_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-private-alb-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS all inbound traffic from VPC CIDR ${module.vpc_core.vpc.vpc_cidr} and all outbound traffic."

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.vpc_core.vpc.cidr]
      description = "Allow HTTP from VPC CIDR ${module.vpc_core.vpc.vpc_cidr}"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc_core.vpc.cidr]
      description = "Allow HTTPS from VPC CIDR ${module.vpc_core.vpc.vpc_cidr}"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "bastion_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-bastion-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow all outbound traffic."

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "redash_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-redash-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS all inbound traffic and all outbound traffic."

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS inbound"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP inbound"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "ecs_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-ecs-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS inbound traffic from public ALB and all outbound traffic."

  ingress_rules = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [module.vpc_core.vpc.vpc_cidr]
      description = "Allow all inbound traffic from public ALB"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "rds_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-rds-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS inbound traffic to port 3306 from VPC CIDR ${module.vpc_core.vpc.vpc_cidr} and all outbound traffic."

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [module.vpc_core.vpc.vpc_cidr]
      description = "Allow inbound traffic to port 3306 from VPC CIDR ${module.vpc_core.vpc.vpc_cidr}"
    },
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [module.redash_sg.attrs.id]
      description     = "Allow inbound traffic to port 3306 from Redash SG"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "endpoint_sg" {
  source      = "../../modules/vpc_security"
  name        = "${local.name_prefix}-endpoint-sg"
  vpc_id      = module.vpc_core.vpc.id
  description = "Allow TLS inbound traffic to port 443 from VPC CIDR ${module.vpc_core.vpc.vpc_cidr} and all outbound traffic"

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc_core.vpc.vpc_cidr]
      description = "Allow HTTPS inbound"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}
