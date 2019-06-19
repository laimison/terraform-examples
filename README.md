# Terraform Examples

## Create a First User Through IAM

Go to AWS Console

IAM - add user
type in your key_name
Programmatic access
AWS Management Console access
Custom password
Require password reset: no

Administrator Access group: my-admin

## Get Started

```
cp variables.tf.example variables.tf
```

* Go to AWS console, IAM section

* Find your key name

* Secret key

* Access key

```
variable "key_name" {
  type    = string
  default = "your-key-name"
}

variable "secret_key" {
  type    = string
  default = "your-secret-key"
}

variable "access_key" {
  type    = string
  default = "your-access-key"
}
```

## Some Tips

It's useful to run this in a loop while working

```
while true; do terraform destroy; sleep 3; terraform apply; sleep 3; done
```

## Setup Cloudwatch Alarm for Higher Than 0 Estimated Bill in AWS

Cloudwatch
Billing Preferences
Receive PDF Invoice By Email
Receive Free Tier Usage Alerts - your@email.address
Receive Billing Alerts

Cloudwatch
Billing
Create Alarm
EstimatedCharges
0
send notification - your@email.address

Cloudwatch
Billing
Create Alarm
"Total Estimated Charge"
0
send notification - your@email.address

## References

Create a first EC2 instance - https://www.youtube.com/watch?v=RA1mNClGYJ4

Inline vs discrete security groups - http://cavaliercoder.com/blog/inline-vs-discrete-security-groups-in-terraform.html

Create a VPC - https://www.youtube.com/watch?v=IxA1IPypzHs

Use Bash in Terraform for EBS volumes - http://www.sanjeevnandam.com/blog/ec2-mount-ebs-volume-during-launch-time

Mount EFS volume using Bash - https://cwong47.gitlab.io/technology-terraform-aws-efs/

Modularize Terraform - https://coderbook.com/@marcus/how-to-split-and-organize-terraform-code-into-modules/
