# Terraform Examples

Here is some Terraform example to provision basic AWS infrastructure with custom VPC, EC2 instances, ELB, also EBS and EFS volumes.

As of June, 2019, the code is not modularised, no state management for more than one developer working with git and considered as very initial version.

## Get Started

Steps to start using it on a fresh AWS account

### Create User

* Go to AWS Console

* IAM - add user

* type in your key_name

* Programmatic access

* AWS Management Console access

* Custom password

* Require password reset: no

* Administrator Access group: my-admin

### Update Credentials

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

## Run it

```
terraform apply
terraform destroy
```

or useful for tests to start from scratch - and take a break :)

```
terraform destroy -auto-approve && terraform apply -auto-approve
```

## How ELB works

```
mac:~ $ curl http://my-terraform-elb-227091730.us-east-1.elb.amazonaws.com
Apache server ip-10-0-178-82.ec2.internal reached!
mac:~ $ curl http://my-terraform-elb-227091730.us-east-1.elb.amazonaws.com
Apache server ip-10-0-178-82.ec2.internal reached!
mac:~ $ curl http://my-terraform-elb-227091730.us-east-1.elb.amazonaws.com
Apache server ip-10-0-105-163.ec2.internal reached!
mac:~ $
```

## How volumes work

```
[ec2-user@ip-10-0-168-252 ~]$ df -m
Filesystem                                    1M-blocks  Used     Available Use% Mounted on
devtmpfs                                            391     0           391   0% /dev
tmpfs                                               410     0           410   0% /dev/shm
tmpfs                                               410    11           400   3% /run
tmpfs                                               410     0           410   0% /sys/fs/cgroup
/dev/xvda2                                        10228  1138          9091  12% /
/dev/xvdh                                           976     3           907   1% /app
fs-d3c78030.efs.us-east-1.amazonaws.com:/ 8796093022207     0 8796093022207   0% /nfs
tmpfs                                                82     0            82   0% /run/user/1000
[ec2-user@ip-10-0-168-252 ~]$
```

## Output

Terraform output variables

```
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:

efs_dns_name = fs-42b1f6a1.efs.us-east-1.amazonaws.com
elb_dns = my-terraform-elb-633456504.us-east-1.elb.amazonaws.com
public_dns = ec2-54-162-71-214.compute-1.amazonaws.com
public_dns2 = ec2-3-80-248-69.compute-1.amazonaws.com
```

## Connect to EC2

```
ssh -i your.key ec2-user@server1
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

Book: Terraform Up and Running by Yevgeniy Brikman
