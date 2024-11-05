
resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  family = var.cluster_parameter_group.family
  name = var.cluster_parameter_group.name

  dynamic "parameter" {
    for_each = var.cluster_parameter_group.parameter
    content {
      name = parameter.value.name
      value = parameter.value.value  
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "this" {
  family = var.db_parameter_group.family
  name = var.db_parameter_group.name

  dynamic "parameter" {
    for_each = var.db_parameter_group.parameter
    content {
      name = parameter.value.name
      value = parameter.value.value  
      apply_method = parameter.value.apply_method
    }
  }
}

resource "aws_rds_cluster" "this" {
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "final-snapshot-${var.cluster_identifier}-deployed-at-${var.fmt_jst_timestamp}"
  cluster_identifier = var.cluster_identifier
  apply_immediately = var.apply_immediately_cluster
  engine = var.engine
  engine_version = var.engine_version
  availability_zones = [ for pri_sub in var.private_subnets : pri_sub.availability_zone ]
  database_name = var.database_name
  master_username = var.master_username
  master_password = var.master_password
  port = var.port
  
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  storage_encrypted = var.storage_encrypted
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ 
      availability_zones, # Ignore availability_zones to prevent errors when db subnet has less than 3 AZs
      engine_version
    ]
  }
}

resource "aws_rds_cluster_instance" "this" {
  depends_on = [ aws_rds_cluster.this ]
  count = var.instance_count
  identifier = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class = var.instance_class
  engine = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_parameter_group.this.name
  db_parameter_group_name = aws_db_parameter_group.this.name
  apply_immediately = var.apply_immediately_instance
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible = var.publicly_accessible
  
  
  lifecycle {
    ignore_changes = [
      engine_version
    ]
    create_before_destroy = true
  }
}