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
