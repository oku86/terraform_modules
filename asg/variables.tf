# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS Region where all resources will be created."
  default     = "eu-west-1"
}

variable "ops_environment" {
  description = "Environment in which all resource will be created."
}

variable "ops_service" {
  description = "Hosted service / application name."
}

variable "vpc_id" {
  description = "The ID of the VPC into which all instances will be deployed."
}

variable "ssh_cidr_blocks" {
  description = "The CIDR blocks of the networks with SSH access."
  type        = list(string)
}

variable "instance_type" {
  description = "ECS instances type. Default to small instance."
  default     = "t2.small"
}

variable "root_volume_size" {
  description = "The Size of Root EBS volume to be used in the ASG group."
  default     = 8
}

variable "root_volume_type" {
  description = "The Type of Root EBS volume to be used in the ASG group."
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "The Size of EBS volume to be used in the ASG group."
  default     = 22
}

variable "ebs_volume_type" {
  description = "The Type of EBS volume to be used in the ASG group."
  default     = "gp2"
}

variable "ebs_device_name" {
  description = "The name of EBS device to mount."
  default     = "/dev/xvdcz"
}

variable "asg_min_size" {
  description = "ASG min number of instances to be running."
  default     = 2
}

variable "asg_max_size" {
  description = "ASG max number of instances to be running."
  default     = 4
}

variable "ha_count" {
  description = "Default number of instances and tasks within the services that must be running."
  default     = 2
}

variable "subnet_ids" {
  description = "Subnet IDs instances will be deployed in."
  type        = list(string)
}

variable "ops_terraformed" {
  description = "Indication of the resource being created via terraform. Must be true for all resources created through modules"
  default     = true
}

variable "ops_owner" {
  description = "Owner (team, department, individual) of all these resources."
}
