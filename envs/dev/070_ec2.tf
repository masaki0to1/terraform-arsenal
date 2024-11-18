## Instance Profile ##
module "instance_profile_redash" {
  source                = "../../modules/instance_profile"
  instance_profile_name = "${local.name_prefix}-instance-profile-redash"
  role_name             = module.iam_role_ec2.attrs.name
}

## Instance ##
module "ec2_redash_1a" {
  source                 = "../../modules/ec2"
  name                   = "${local.name_prefix}-redash-1a"
  ami                    = local.ec2_conf.redash.ami
  instance_type          = local.ec2_conf.redash.instance_type
  subnet_id              = module.vpc_core.public_subnets["public_1a"].id
  vpc_security_group_ids = [module.redash_sg.attrs.id]
  iam_instance_profile   = module.instance_profile_redash.attrs.name
}