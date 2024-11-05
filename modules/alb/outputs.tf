output "attrs" {
  value = {
    id  = aws_lb.this.id
    arn = aws_lb.this.arn
  }
}