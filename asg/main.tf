# ------------------------------------------------------------------------------
# CREATE SNS TOPIC USED FOR ASG ALERTS
# ------------------------------------------------------------------------------

resource "aws_sns_topic" "alerts" {
  name = "${var.ops_environment}-${var.ops_service}-alerts"

  tags = {
    Name            = "${var.ops_environment}-${var.ops_service}-alerts"
    ops_terraformed = var.ops_terraformed
    ops_owner       = var.ops_owner
  }
}

# ------------------------------------------------------------------------------
# CREATE IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "instance_role" {
  name               = "${var.ops_environment}-${var.ops_service}-ec2-instances"
  assume_role_policy = data.template_file.ec2_instance_profile.rendered
}

# ------------------------------------------------------------------------------
# CREATE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT
# ------------------------------------------------------------------------------

resource "aws_security_group" "ec2_access" {
  name        = "${var.ops_environment}-${var.ops_service}-ec2-instances"
  description = "Security group for ${var.ops_environment} ${var.ops_service} EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name            = "${var.ops_environment}-${var.ops_service}-ec2-instances"
    ops_terraformed = var.ops_terraformed
    ops_owner       = var.ops_owner
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2_access.id
}

resource "aws_security_group_rule" "allow_all_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2_access.id
}

resource "aws_security_group_rule" "allow_all_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ssh_cidr_blocks

  security_group_id = aws_security_group.ec2_access.id
}

# ------------------------------------------------------------------------------
# CREATE ASG FOR EC2 INSTANCES
# ------------------------------------------------------------------------------

# Instance profile that provides IAM permissions to the instances in ASG
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.ops_environment}-${var.ops_service}"
  role = aws_iam_role.instance_role.name
}

# Launch configuration for instances
resource "aws_launch_configuration" "launch_configuration" {
  name_prefix          = "${var.ops_environment}-${var.ops_service}-ec2-instances"
  instance_type        = var.instance_type
  image_id             = data.aws_ami.latest_ubuntu_ami.id
  security_groups      = [aws_security_group.ec2_access.id]
  user_data            = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  ebs_block_device {
    device_name = var.ebs_device_name
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group for instances
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${var.ops_environment}-${var.ops_service}-ec2"
  vpc_zone_identifier  = var.subnet_ids
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.ha_count
  launch_configuration = aws_launch_configuration.launch_configuration.name
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.ops_environment}-${var.ops_service}-ec2"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "ops_terraformed"
    value               = var.ops_terraformed
    propagate_at_launch = "true"
  }

  tag {
    key                 = "ops_owner"
    value               = var.ops_owner
    propagate_at_launch = "true"
  }
}

# ASG launch and termination error notification
resource "aws_autoscaling_notification" "autoscaling_group_notifications" {
  group_names = [aws_autoscaling_group.autoscaling_group.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.alerts.arn
}
