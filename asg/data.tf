# ------------------------------------------------------------------------------
# EC2 INSTANCE POLICY
# ------------------------------------------------------------------------------

data "template_file" "ec2_instance_profile" {
  template = file("${path.module}/templates/assume-role-policy")

  vars = {
    service_name = "ec2"
  }
}

# ------------------------------------------------------------------------------
# FIND THE LATEST UBUNTU 18.04 AMI
# ------------------------------------------------------------------------------

data "aws_ami" "latest_ubuntu_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["*ubuntu-bionic-18.04-*"]
  }
}

# ------------------------------------------------------------------------------
# EC2 USER DATA
# ------------------------------------------------------------------------------
# NOTE: It would be better if user-data is a required module input

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data")
}