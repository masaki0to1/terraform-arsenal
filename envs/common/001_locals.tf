locals {
  # basic settings
  common_conf = {
    project           = "example"
    service           = "service"
    owner             = "owner"
    region            = "ap-northeast-1"
    utc_timestamp     = timestamp()
    offset_hours      = 9 # Offset to JST
    jst_timestamp     = timeadd(local.utc_timestamp, "${local.offset_hours}h")
    fmt_jst_timestamp = formatdate("YYYYMMDDhhmmss", local.jst_timestamp)
  }
}