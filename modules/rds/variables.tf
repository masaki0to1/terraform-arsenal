variable "cluster_parameter_group" {
  description = "Configuration for RDS cluster parameter group"
  type = object({
    family = string
    name = string
    parameter = list(object({
      name = string
      value = string
      apply_method = string
    }))
  })
}

variable "db_parameter_group" {
  description = "Configuration for RDS DB parameter group"
  type = object({
    family = string
    name = string
    parameter = list(object({
      name = string
      value = string
      apply_method = string
    }))
  })
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type = bool
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type = bool
}

variable "cluster_identifier" {
  description = "The cluster identifier"
  type = string
}

variable "fmt_jst_timestamp" {
  description = "Timestamp in JST format"
  type = string
}

variable "apply_immediately_cluster" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type = bool
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster"
  type = string
}

variable "engine_version" {
  description = "The database engine version"
  type = string
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    availability_zone = string
  }))
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type = string
  sensitive = true
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type = number
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the cluster"
  type = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to use in the subnet group"
  type = list(string)
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type = number
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type = string
}

variable "maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type = string
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to enable for exporting to CloudWatch logs"
  type = list(string)
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type = bool
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data"
  type = number
}

variable "instance_count" {
  description = "Number of DB instances to create in the cluster"
  type = number
}

variable "instance_class" {
  description = "The instance class to use for DB instances"
  type = string
}

variable "apply_immediately_instance" {
  description = "Specifies whether any instance modifications are applied immediately"
  type = bool
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically"
  type = bool
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type = bool
}

variable "autoscaling_policy" {
  description = "Configuration for autoscaling policy"
  type = object({
    name = string
    policy_type = string
    metric_type = string
    target_value = number
    scale_in_cooldown = number
    scale_out_cooldown = number
  })
}
