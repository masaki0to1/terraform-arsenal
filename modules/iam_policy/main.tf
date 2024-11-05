resource "aws_iam_role_policy" "this" {
  name = var.policy_name
  role = var.role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.policy_statements : {
        Sid      = statement.sid
        Effect   = statement.effect
        Action   = statement.actions
        Resource = statement.resources
      }
    ]
  })
}