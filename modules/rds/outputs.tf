output "attrs" {
  value = {
    cluster_arn             = aws_rds_cluster.this.arn
    cluster_id              = aws_rds_cluster.this.id
    cluster_endpoint        = aws_rds_cluster.this.endpoint
    cluster_reader_endpoint = aws_rds_cluster.this.reader_endpoint
    cluster_port            = aws_rds_cluster.this.port
    cluster_database_name   = aws_rds_cluster.this.database_name
    cluster_master_username = aws_rds_cluster.this.master_username
    cluster_instances = [
      for instance in aws_rds_cluster_instance.this : {
        id         = instance.id
        arn        = instance.arn
        endpoint   = instance.endpoint
        identifier = instance.identifier
      }
    ]
  }
}