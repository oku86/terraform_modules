# ------------------------------------------------------------------------------
# OUTPUT VALUES
# ------------------------------------------------------------------------------

output "ec2_asg_arn" {
  value = aws_autoscaling_group.autoscaling_group.arn
}

output "alerts_sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}