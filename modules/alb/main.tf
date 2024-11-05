resource "aws_lb" "this" {
  name                       = var.name
  internal                   = var.alb_conf.internal
  enable_deletion_protection = var.alb_conf.enable_deletion_protection
  load_balancer_type         = var.alb_conf.load_balancer_type
  subnets                    = var.subnet_ids
  security_groups            = var.security_group_ids

  tags = {
    Name = var.name
  }
}
