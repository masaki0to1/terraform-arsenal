locals {
  env = "common"

  # timestamp settings
  utc_timestamp     = timestamp()
  offset_hours      = 9 # Offset to JST
  jst_timestamp     = timeadd(local.utc_timestamp, "${local.offset_hours}h")
  fmt_jst_timestamp = formatdate("YYYYMMDDhhmmss", local.jst_timestamp)

  # Common project configuration
  common_conf = {
    project        = "example"
    service        = "service"
    owner          = "owner"
    default_region = "ap-northeast-1"
  }

  # naming rule (e.g. common-example-service)
  name_prefix = join("-", [local.env, local.common_conf.project, local.common_conf.service])

  # base domain (e.g. dev.example-service)
  base_domain = join(".", [local.env, "${local.common_conf.project}-${local.common_conf.service}"])

  base_tags = {
    Env       = local.env
    Project   = local.common_conf.project
    Service   = local.common_conf.service
    Owner     = local.common_conf.owner
    Terraform = "true"
  }
}