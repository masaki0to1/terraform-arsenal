output "attrs" {
  value = {
    log_group_name = aws_cloudwatch_log_group.this.name
  }
}