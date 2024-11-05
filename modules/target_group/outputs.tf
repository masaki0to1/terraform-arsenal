output "attrs" {
  value = {
    id  = aws_lb_target_group.this.id
    arn = aws_lb_target_group.this.arn
  }
}