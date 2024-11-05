output "route_table" {
  value = {
    id   = aws_route_table.this.id
    name = var.route_table_name
  }
}