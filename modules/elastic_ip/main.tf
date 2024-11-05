resource "aws_eip" "this" {
  instance = var.instance_id
  domain   = var.domain
}
