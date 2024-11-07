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
