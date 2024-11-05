resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol
  certificate_arn   = var.certificate_arn

  default_action {
    type             = var.default_action.type
    target_group_arn = var.default_action.type == "forward" ? var.default_action.target_group_arn : null

    dynamic "fixed_response" {
      for_each = var.default_action.type == "fixed-response" ? [var.default_action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

    dynamic "redirect" {
      for_each = var.default_action.type == "redirect" ? [var.default_action.redirect] : []
      content {
        protocol    = redirect.value.protocol
        port        = redirect.value.port
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  count        = length(var.rules)
  listener_arn = aws_lb_listener.this.arn

  action {
    type             = var.rules[count.index].action.type
    target_group_arn = lookup(var.rules[count.index].action, "target_group_arn", null)

    dynamic "fixed_response" {
      for_each = var.rules[count.index].action.type == "fixed-response" ? [var.rules[count.index].action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

    dynamic "redirect" {
      for_each = var.rules[count.index].action.type == "redirect" ? [var.rules[count.index].action.redirect] : []
      content {
        protocol    = redirect.value.protocol
        port        = redirect.value.port
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }
  }

  dynamic "condition" {
    for_each = var.rules[count.index].conditions
    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }
      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }
    }
  }
}