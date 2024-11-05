resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = var.route_table_name
    },
    var.tags
  )
}

resource "aws_route" "this" {
  for_each = var.routes

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = each.value.destination_cidr_block

  # Conditional IDs for each gateway type.
  gateway_id                = try(each.value.gateway_id, null)
  nat_gateway_id            = try(each.value.nat_gateway_id, null)
  network_interface_id      = try(each.value.network_interface_id, null)
  vpc_peering_connection_id = try(each.value.vpc_peering_connection_id, null)
  transit_gateway_id        = try(each.value.transit_gateway_id, null)
}

resource "aws_route_table_association" "this" {
  for_each = toset(var.subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}