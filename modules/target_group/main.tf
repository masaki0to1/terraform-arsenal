resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    path                = var.path
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.target_group_conf.timeout
    interval            = var.target_group_conf.interval
    matcher             = var.target_group_conf.matcher
  }
}
