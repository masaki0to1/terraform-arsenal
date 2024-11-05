output "attrs" {
  value = {
    topic_arn = aws_sns_topic.this.arn
    subscription_arn = aws_sns_topic_subscription.this.arn
  }
}