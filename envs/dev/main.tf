## ECR ##
module "ecr_repo" {
  source        = "../../modules/ecr"
  ecr_repo_name = "${local.name_prefix}-repo"
}

## ACM ##
module "acm" {
  source   = "../../modules/acm"
  acm_conf = local.acm_conf
  domain   = "dev.example.com"
  san      = ["*.dev.example.com"]

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
    aws.route53  = aws.route53
  }
}

## IAM ##
# scheduler role
module "iam_role_scheduler" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-scheduler"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["scheduler.amazonaws.com"]
      }
    }
  ]
}

# scheduler policy
module "iam_policy_scheduler" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-scheduler"
  role_id     = module.iam_role_scheduler.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "ecs:UpdateService",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "rds:StartDBCluster",
        "rds:StopDBCluster"
      ]
      resources = ["*"]
    }
  ]
}

# ec2 role
module "iam_role_ec2" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ec2"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ec2.amazonaws.com"]
      }
    }
  ]
}

# ec2 policy
module "iam_policy_ec2" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ec2"
  role_id     = module.iam_role_ec2.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "ssm:StartSession",
        "ssm:SendCommand",
        "ssm:TerminateSession",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations"
      ]
      resources = ["*"]
    }
  ]
}

# ec2 attachment
module "iam_attachment_ec2" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_ec2.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# cognito role
module "iam_role_cognito_auth" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-cognito-auth"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = module.cognito_line_oidc.attrs.identity_pool_id
        },
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }
  ]
}

# cognito attachment
module "iam_attachment_cognito_auth" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_cognito_auth.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  ]
}

# ecs task execution role
module "iam_role_ecs_task_exec" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ecs-task-exec"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
    }
  ]
}

# ecs task execution policy
module "iam_policy_ecs_task_exec" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ecs-task-exec"
  role_id     = module.iam_role_ecs_task_exec.attrs.id

  policy_statements = [
    {
      sid    = "AllowGetSsmParams"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowCreateLogs"
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowUseEcr"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
      resources = ["${module.ecr_repo.attrs.arn}"]
    }
  ]
}

# ecs task execution attachment
module "iam_attachment_ecs_task_exec" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_ecs_task_exec.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# ecs task role
module "iam_role_ecs_task" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ecs-task"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
    }
  ]
}

# ecs task policy
module "iam_policy_ecs_task" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ecs-task"
  role_id     = module.iam_role_ecs_task.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "rds:ListTagsForResource",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSubnetGroups",
        "rds:DescribeDBSnapshots",
        "rds:DescribeDBClusterSnapshots",
        "rds:DescribeDBClusterParameters",
        "rds:DescribeDBClusterEndpoints",
        "rds:DescribeDBClusterMembers",
        "rds-db:connect",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:PutObjectVersion",
        "s3:GetBucketLocation"
      ]
      resources = ["*"]
    }
  ]
}

# lambda exec role
module "iam_role_lambda_exec" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-lambda-exec"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["lambda.amazonaws.com"]
      }
    }
  ]
}

# lambda ses policy
module "iam_policy_lambda_ses" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-lambda-ses"
  role_id     = module.iam_role_lambda_exec.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "sns:Publish",
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = ["*"]
    }
  ]
}

# lambda cwlogs policy
module "iam_policy_lambda_cwlogs" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-lambda-cwlogs"
  role_id     = module.iam_role_lambda_exec.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      resources = ["*"]
    }
  ]
}

# lambda exec attachment
module "iam_attachment_lambda_exec" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_lambda_exec.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# github actions role
module "iam_role_github_actions_oidc" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-github-actions-oidc"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }
  ]
}

# github actions policy
module "iam_policy_github_actions" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-github-actions"
  role_id     = module.iam_role_github_actions_oidc.attrs.id

  policy_statements = [
    {
      sid    = "AllowPassRole"
      effect = "Allow"
      actions = [
        "iam:PassRole"
      ]
      resources = [
        "arn:aws:iam::*:role/${module.iam_role_ecs_task.attrs.name}",
        "arn:aws:iam::*:role/${module.iam_role_ecs_task_exec.attrs.name}"
      ]
    },
    {
      sid    = "AllowExecEcs"
      effect = "Allow"
      actions = [
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:TagResource"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowUseAdminOriginBucket"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersion",
        "s3:DeleteObject"
      ]
      resources = [
        "${module.s3_bucket_admin_origin.attrs.arn}",
        "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
    },
    {
      sid    = "AllowUseAdminDistribution"
      effect = "Allow"
      actions = [
        "cloudfront:ListDistributions",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListStreamingDistributions",
        "cloudfront:GetStreamingDistribution",
        "cloudfront:GetStreamingDistributionConfig",
        "cloudfront:ListInvalidations",
        "cloudfront:GetInvalidation",
        "cloudfront:CreateInvalidation"
      ]
      resources = [
        "${module.landing_page_cfd_admin.attrs.arn}"
      ]
    }
  ]
}

## S3 ##
# resources origin bucket
module "s3_bucket_resources_origin" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-resources-origin"

  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
    }
  ]
}

# admin origin bucket
module "s3_bucket_admin_origin" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-admin-origin"

  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
    }
  ]
}

# admin logging bucket
module "s3_bucket_admin_logging" {
  source = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-admin-logging"
}

module "s3_bucket_policy_resources_origin" {
  source = "../../modules/s3_bucket_policy"

  bucket_id = module.s3_bucket_resources_origin.attrs.bucket_id
  policy_statements = [
    {
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        "Service" : "cloudfront.amazonaws.com"
      },
      Action   = "s3:GetObject",
      Resource = "${module.s3_bucket_resources_origin.attrs.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" : "${module.s3_bucket_cfd_resources.attrs.arn}"
        }
      }
    }
  ]
}

module "s3_bucket_policy_admin_origin" {
  source = "../../modules/s3_bucket_policy"

  bucket_id = module.s3_bucket_admin_origin.attrs.bucket_id
  policy_statements = [
    {
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        "Service" : "cloudfront.amazonaws.com"
      },
      Action   = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ]
      Resource = [
      "${module.s3_bucket_admin_origin.attrs.arn}",
      "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
      Condition = {
        StringEquals = {
          "AWS:SourceArn" : "${module.landing_page_cfd_admin.attrs.arn}"
        }
      }
    },
    {
      Sid = "AllowGithubActionsAccess",
      Effect = "Allow",
      Principal = {
        "AWS" : "${module.iam_role_github_actions_oidc.attrs.arn}"
      },
      Action = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      Resource = [
        "${module.s3_bucket_admin_origin.attrs.arn}",
        "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
    }
  ]
}

module "aws_s3_bucket_ownership_controls" {
  source = "../../modules/s3_bucket_ownership_controls"

  bucket_id = module.s3_bucket_admin_logging.attrs.id
  object_ownership = "BucketOwnerPreferred"
}

module "s3_bucket_acl_admin" {
  source = "../../modules/s3_bucket_acl"
  depends_on = [ module.aws_s3_bucket_ownership_controls ]

  bucket_id = module.s3_bucket_admin_logging.attrs.id
  acl = "private"
}

## CFD ##
# resources cfd
module "s3_bucket_cfd_resources" {
  source = "../../modules/cfd/s3_bucket_cfd"

  oac_name    = "${local.name_prefix}-resources-oac"
  domain_name = module.s3_bucket_resources_origin.attrs.bucket_regional_domain_name
  origin_id   = "${local.name_prefix}-resources-origin"

  price_class         = "PriceClass_200"
  default_root_object = "index.html"
  alias_domain        = ["resources.${var.domain}"]

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]

  forward_query_string = false
  forward_cookies      = "none"

  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400

  geo_restriction_type           = "none"
  cloudfront_default_certificate = false
  acm_certificate_arn            = module.acm.virginia_cert.arn
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1.2_2019"
}

# admin cfd
module "landing_page_cfd_admin" {
  source = "../../modules/cfd/landing_page_cfd"

  func_name = "${local.name_prefix}-basic-auth"
  runtime = "cloudfront-js-2.0"
  comment = "${local.name_prefix}-basic-auth"
  is_publish = true
  basic_auth_users = [
    { username = "lp_admin_user"}
  ]
  basic_auth_passwords = module.secrets.admin_auth_pass_value

  oac_name    = "${local.name_prefix}-admin-oac"
  domain_name = module.s3_bucket_admin_origin.attrs.bucket_regional_domain_name
  origin_id   = "${local.name_prefix}-admin-origin"

  price_class         = "PriceClass_200"
  default_root_object = "index.html"
  alias_domain        = ["resources.${var.domain}"]

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]

  forward_query_string = false
  forward_cookies      = "none"

  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400

  geo_restriction_type           = "none"
  cloudfront_default_certificate = false
  acm_certificate_arn            = module.acm.virginia_cert.arn
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1.2_2019"

  custom_error_responses = [
    {
      error_code = 403
      response_code = 200
      response_page_path = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code = 404
      response_code = 200
      response_page_path = "/index.html"
      error_caching_min_ttl = 10
    }
  ]
}

## Instance Profile ##
module "instance_profile_redash" {
  source                = "../../modules/instance_profile"
  instance_profile_name = "${local.name_prefix}-instance-profile-redash"
  role_name             = module.iam_role_ec2.attrs.name
}

## Server ##
module "ec2_redash_1a" {
  source                 = "../../modules/ec2"
  name                   = "${local.name_prefix}-redash-1a"
  ami                    = local.ec2_conf.redash.ami
  instance_type          = local.ec2_conf.redash.instance_type
  subnet_id              = module.vpc_core.public_subnets["public-1a"].id
  vpc_security_group_ids = [module.redash_sg.attrs.id]
  iam_instance_profile   = module.instance_profile_redash.attrs.name
}

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

## ALB ##
module "public_alb_1" {
  source             = "../../modules/alb"
  name               = "${local.name_prefix}-public-alb"
  alb_conf           = local.public_alb_conf
  subnet_ids         = [for pub_subnet in module.vpc_core.public_subnets : pub_subnet.id]
  security_group_ids = [module.public_alb_sg.attrs.id]
}

module "private_alb_1" {
  source             = "../../modules/alb"
  name               = "${local.name_prefix}-private-alb"
  alb_conf           = local.private_alb_conf
  subnet_ids         = [for pri_subnet in module.vpc_core.private_subnets : pri_subnet.id]
  security_group_ids = [module.private_alb_sg.attrs.id]
}

# Target Group
module "ecs_tg" {
  source              = "../../modules/target_group"
  name                = "${local.name_prefix}-ecs-tg"
  port                = 80
  protocol            = "HTTP"
  target_type         = "ip"
  vpc_id              = module.vpc_core.vpc.id
  path                = "/"
  healthy_threshold   = 3
  unhealthy_threshold = 3
  target_group_conf   = local.target_group_conf
}

# Listener
module "listener_forward" {
  source            = "../../modules/listener"
  load_balancer_arn = module.public_alb_1.attrs.arn
  port              = 80
  protocol          = "HTTP"
  default_action = {
    type             = "forward"
    target_group_arn = module.ecs_tg.attrs.arn
  }
}

module "listener_redirect" {
  source            = "../../modules/listener"
  load_balancer_arn = module.public_alb_1.attrs.arn
  port              = 80
  protocol          = "HTTP"
  default_action = {
    type = "redirect"
    redirect = {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
      host        = "example.com"
      path        = "/sample-path"
      query       = "?sample=true"
    }
  }
}

module "listener_fixed_response" {
  source            = "../../modules/listener"
  load_balancer_arn = module.public_alb_1.attrs.arn
  port              = 80
  protocol          = "HTTP"
  default_action = {
    type = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

module "listener_https" {
  source            = "../../modules/listener"
  load_balancer_arn = module.public_alb_1.attrs.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.tokyo_cert.arn
  default_action = {
    type             = "forward"
    target_group_arn = module.ecs_tg.attrs.arn
  }
}
