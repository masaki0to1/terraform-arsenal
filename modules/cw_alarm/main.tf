resource "aws_cloudwatch_log_metric_filter" "this" {
  name           = var.name
  pattern        = var.pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name          = var.metric_transformation.name
    namespace     = var.metric_transformation.namespace
    value         = var.metric_transformation.value
    default_value = var.metric_transformation.default_value
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_transformation.name
  namespace          = var.metric_transformation.namespace
  period             = var.period
  statistic          = var.statistic
  threshold          = var.threshold
  treat_missing_data = var.treat_missing_data
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  dimensions = var.dimensions

  tags = var.tags
}