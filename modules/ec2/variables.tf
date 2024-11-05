variable "name" {
  type        = string
  description = "Name tag of the EC2 instance"
}

variable "ami" {
  type        = string
  description = "ID of AMI to use for the instance"
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the instance"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with"
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instance"
  default     = null
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile to launch the instance with"
  default     = null
}

variable "user_data" {
  type        = string
  description = "User data to provide when launching the instance"
  default     = ""
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 8
}

# variable "root_volume_type" {
#   type        = string
#   description = "Type of root volume. Can be standard, gp2, gp3, io1, io2"
#   default     = "gp3"
# }

# variable "root_volume_encrypted" {
#   type        = bool
#   description = "Whether to encrypt the root volume"
#   default     = true
# }
