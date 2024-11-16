output "attrs" {
  value = {
    arn = aws_ecs_cluster.this.arn
    id  = aws_ecs_cluster.this.id
  }
}