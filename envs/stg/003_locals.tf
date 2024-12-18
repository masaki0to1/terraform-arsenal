data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    region  = var.common_conf_state.region
    bucket  = var.common_conf_state.bucket
    key     = var.common_conf_state.key
    profile = var.common_conf_state.aws_profile
  }
}

locals {
  # basic settings
  aws_default_profile = "tf-user@Sandbox"
  env                 = "stg"
  default_region      = data.terraform_remote_state.common.outputs.local.default_region
  project             = data.terraform_remote_state.common.outputs.local.project
  service             = data.terraform_remote_state.common.outputs.local.service
  owner               = data.terraform_remote_state.common.outputs.local.owner

  # timestamp settings
  utc_timestamp     = timestamp()
  offset_hours      = 9 # Offset to JST
  jst_timestamp     = timeadd(local.utc_timestamp, "${local.offset_hours}h")
  fmt_jst_timestamp = formatdate("YYYYMMDDhhmmss", local.jst_timestamp)

  # naming rule (e.g. stg-example-service)
  name_prefix = join("-", [local.env, local.project, local.service])

  # base domain (e.g. stg.example-service)
  base_domain = join(".", [local.env, "${local.project}-${local.service}"])

  base_tags = {
    Env       = local.env
    Project   = local.project
    Service   = local.service
    Owner     = local.owner
    Terraform = "true"
  }

  ec2_conf = {
    redash = {
      ami              = "ami-0162fe8bfebb6ea16"
      instance_type    = "t3.medium"
      root_volume_size = 8
      final_snapshot   = true
      prevent_destroy  = true
    }
  }

  vpc_conf = {
    main_vpc = {
      name                 = "${local.name_prefix}-main"
      cidr_block           = "10.16.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
      instance_tenancy     = "default"
    }
  }

  subnet_conf = {
    private_subnets = {
      private_1a = {
        name              = "${local.name_prefix}-private-1a"
        cidr_block        = "10.16.10.0/24"
        availability_zone = "ap-northeast-1a"
      }
      private_1c = {
        name              = "${local.name_prefix}-private-1c"
        cidr_block        = "10.16.11.0/24"
        availability_zone = "ap-northeast-1c"
      }
    }
    public_subnets = {
      public_1a = {
        name              = "${local.name_prefix}-public-1a"
        cidr_block        = "10.16.100.0/24"
        availability_zone = "ap-northeast-1a"
      }
      public_1c = {
        name              = "${local.name_prefix}-public-1c"
        cidr_block        = "10.16.101.0/24"
        availability_zone = "ap-northeast-1c"
      }
    }
  }

  acm_conf = {
    method         = "DNS"
    hosted_zone_id = "Z05206600986666000000000000000000"
    dvo_record_ttl = 60
  }

  cognito_conf = {
    line_identity_provider = {
      name = "line"
      type = "OIDC"
      details = {
        oidc_issuer                   = "https://access.line.me"
        attributes_url                = "https://api.line.me/oauth2/v2.1/userinfo"
        attributes_url_add_attributes = false # for LINE OIDC
        attributes_request_method     = "GET"
        authorize_scopes              = "email openid profile"
        authorize_url                 = "https://access.line.me/oauth2/v2.1/authorize"
        token_url                     = "https://api.line.me/oauth2/v2.1/token"
        jwks_uri                      = "https://api.line.me/oauth2/v2.1/certs"
      }
    }
  }

  public_alb_conf = {
    internal                   = false
    enable_deletion_protection = false
    load_balancer_type         = "application"
  }

  private_alb_conf = {
    internal                   = true
    enable_deletion_protection = false
    load_balancer_type         = "application"
  }

  target_group_conf = {
    timeout  = 5
    interval = 30
    matcher  = "200"
  }
}
