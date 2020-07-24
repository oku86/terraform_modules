# Resource Template

This folder contains a [Terraform](https://www.terraform.io/) module template that can be used to deploy:

 - SNS topic for alerts
 - Security Group and rules:
 	-  **Ingress** - HTTP for everyone
 	-  **Ingress** - SSH for given CIDR blocks (defined by `ssh_cidr_blocks` variable)
 	-  **Egress** - all traffic
 - Launch configuration
 - Auto Scaling Group

&nbsp;

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html) which you can use in your
code by adding a `module` configuration and setting its `source` parameter accordingly:

```hcl
module "asg" {
  source = "git::git@github.com:ORGANISATION/terraform-modules.git//modules/asg?ref=v0.1"

  ops_environment  = "UAT"
  ops_service      = "My-Service-Name"  
  vpc_id           = "vpc-12345678"
  subnet_ids       = ["subnet-12345678", "subnet-11223344", "subnet-55667788"]
  ssh_cidr_blocks  = ["1.2.3.4/32", "1.1.1.0/24"]
  ops_owner        = "engineering"
}
```

&nbsp;

### Input variables:
The module requires a number of input variables:

- `ops_environment ` : environment name
- `ops_service` : service / application name
- `vpc_id` : VPC ID to deploy the EC2 instances
- `subnet_ids` : list of subnet IDs where the EC2 instances will be deployed
- `ssh_cidr_blocks` : list of IPs or network range CIDRs allowed to access instances over SSH
- `ops_owner` : the project owner of these resources

__NOTE:__  Additionally, most configuration parameters have default values (defined in the `variables.tf` file) but can be easily overwritten by simply passing them as inputs.


&nbsp;

#### Output variables:
The module will also output the following values:

- `ec2_asg_arn` : Auto Scaling Group ARN
- `alerts_sns_topic_arn` : Alert SNS topic ARN


These values can be exposed when using the module:

```hcl
output "ec2_asg_arn" {
  value = module.asg.ec2_asg_arn
}

output "alerts_sns_topic_arn" {
  value = module.asg.alerts_sns_topic_arn
}
```