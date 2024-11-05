resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name
  role = var.role_name
}