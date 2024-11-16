output "attrs" {
  value = {
    family = aws_ecs_task_definition.this.family
  }
}