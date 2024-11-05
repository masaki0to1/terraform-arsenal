output "attrs" {
  value = {
    id   = aws_iam_role.this.id
    arn  = aws_iam_role.this.arn
    name = aws_iam_role.this.name
  }
}