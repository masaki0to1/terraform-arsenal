output "attrs" {
  description = "Attributes of the created security group"
  value = {
    id   = aws_security_group.this.id
    arn  = aws_security_group.this.arn
    name = aws_security_group.this.name
  }
}