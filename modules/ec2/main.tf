resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name
  user_data              = var.user_data != "" ? var.user_data : null

  tags = {
    Name = var.name
  }
}

resource "aws_ebs_volume" "root_volume" {
  availability_zone = aws_instance.this.availability_zone
  size              = var.root_volume_size
  type              = aws_instance.this.root_block_device[0].volume_type
  encrypted         = aws_instance.this.root_block_device[0].encrypted
  final_snapshot    = true
  tags              = aws_instance.this.tags

  lifecycle {
    prevent_destroy = true
  }
}