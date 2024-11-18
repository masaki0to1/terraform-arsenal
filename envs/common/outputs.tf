output "local" {
  value = {
    default_region    = local.common_conf.default_region
    project           = local.common_conf.project
    service           = local.common_conf.service
    owner             = local.common_conf.owner
    fmt_jst_timestamp = local.fmt_jst_timestamp
  }
}