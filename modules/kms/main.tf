resource "aws_kms_key" "this" {
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  is_enabled               = var.is_key_enabled
  enable_key_rotation      = var.enable_key_rotation
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
}

resource "aws_kms_alias" "this" {
  name          = var.key_alias_name
  target_key_id = aws_kms_key.this.arn
}