output "attrs" {
  value = {
    name = aws_ecr_repository.this.name
    arn  = aws_ecr_repository.this.arn
  }
}
