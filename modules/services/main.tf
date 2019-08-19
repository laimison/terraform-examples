################################################## VARIABLES ################################################
# Get in the variables as var.test
variable "test" {}
variable "key_name" {}

#################################################### DATA ###################################################
# Declare the data source
data "aws_availability_zones" "available" {}

# Create S3 bucket for elb logs
data "aws_elb_service_account" "main" {}


data "template_file" "init" {
  template = "${file("ec2-init.sh")}"

  vars = {
    some_address = "${aws_efs_mount_target.my_efs_mount.dns_name}"
  }
}

###################################################### VPC1 ##################################################
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc1"
  }
}

#################################################### SUBNET1 ################################################
resource "aws_subnet" "subnet1" {
  # availability_zone = "${data.aws_availability_zones.available.names[0]}"
  availability_zone = "us-east-1a"

  # interpolation to have dynamic value
  vpc_id = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

#################################################### SUBNET2 ################################################
resource "aws_subnet" "subnet2" {
  # availability_zone = "${data.aws_availability_zones.available.names[0]}"
  availability_zone = "us-east-1b"

  # interpolation to have dynamic value
  vpc_id = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

################################################## SUBNET DB 1 ###############################################
resource "aws_subnet" "subnet-db-1" {
  # availability_zone = "${data.aws_availability_zones.available.names[0]}"
  availability_zone = "us-east-1a"

  # interpolation to have dynamic value
  vpc_id = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.48.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-db-1"
  }
}

################################################## SUBNET DB 2 ###############################################
resource "aws_subnet" "subnet-db-2" {
  # availability_zone = "${data.aws_availability_zones.available.names[0]}"
  availability_zone = "us-east-1b"

  # interpolation to have dynamic value
  vpc_id = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.64.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-db-2"
  }
}

###################################################### GW ####################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags = {
    Name = "gw"
  }
}

################################################### ROUTES ###############################################
# Adds gateway to a dedicated routing table (dedicated VPC)
resource "aws_route" "my_route" {
  # This routing table was created together with VPC so re-using it
  route_table_id = "${aws_vpc.vpc1.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

# # Adds explicit association to the dedicated subnet (dedicated VPC)
# resource "aws_route_table_association" "my_routes_association" {
#   subnet_id      = "${aws_subnet.subnet1.id}"
#
#   # Use newly created route above
#   # route_table_id = "${aws_route_table.my_routes.id}"
#
#   # Use existing route (which was created with VPC?)
#   route_table_id = "${aws_vpc.vpc1.main_route_table_id}"
# }

#################################################### EC2 ###################################################
#### SERVER1 ####
resource "aws_instance" "server1" {
  # Check if subnet is in the same zone
  availability_zone = "us-east-1a"
  depends_on = ["aws_internet_gateway.gw", "aws_efs_mount_target.my_efs_mount"]
  # Redhat 8
  ami = "ami-098bb5d92c8886ca1"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet1.id}"
  # security_groups = [ "default" ]
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh_from_everywhere.id}", "${aws_security_group.allow_icmp_from_everywhere.id}", "${aws_security_group.allow_8080_from_everywhere.id}", "${aws_security_group.allow_internet.id}", "${aws_vpc.vpc1.default_security_group_id}" ]

  user_data = "${data.template_file.init.rendered}"

  tags = {
    Name = "server1"
  }
}

output "public_dns" {
  value = aws_instance.server1.public_dns
}

#### SERVER2 ####
resource "aws_instance" "server2" {
  # Check if subnet is in the same zone
  availability_zone = "us-east-1b"
  depends_on = ["aws_internet_gateway.gw"]
  # Ubuntu 16
  # ami = "ami-2757f631"
  # Redhat 8
  ami = "ami-098bb5d92c8886ca1"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet2.id}"
  # security_groups = [ "default" ]
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh_from_everywhere.id}", "${aws_security_group.allow_icmp_from_everywhere.id}", "${aws_security_group.allow_8080_from_everywhere.id}", "${aws_security_group.allow_internet.id}", "${aws_vpc.vpc1.default_security_group_id}" ]

  user_data = "${data.template_file.init.rendered}"

  tags = {
    Name = "server2"
  }
}

output "public_dns2" {
  value = aws_instance.server2.public_dns
}

#### DB SERVER 1 ####
resource "aws_instance" "server-db-1" {
  # Check if subnet is in the same zone
  availability_zone = "us-east-1a"
  depends_on = ["aws_internet_gateway.gw", "aws_efs_mount_target.my_efs_db_mount"]
  # Redhat 8
  ami = "ami-098bb5d92c8886ca1"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet-db-1.id}"
  # security_groups = [ "default" ]
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh_from_everywhere.id}", "${aws_security_group.allow_icmp_from_everywhere.id}", "${aws_security_group.allow_internet.id}", "${aws_vpc.vpc1.default_security_group_id}" ]

  user_data = "${data.template_file.init.rendered}"

  tags = {
    Name = "server-db-1"
  }
}

output "db_public_dns" {
  value = aws_instance.server-db-1.public_dns
}

#### DB SERVER 2 ####
resource "aws_instance" "server-db-2" {
  # Check if subnet is in the same zone
  availability_zone = "us-east-1b"
  depends_on = ["aws_internet_gateway.gw"]
  # Ubuntu 16
  # ami = "ami-2757f631"
  # Redhat 8
  ami = "ami-098bb5d92c8886ca1"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet-db-2.id}"
  # security_groups = [ "default" ]
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh_from_everywhere.id}", "${aws_security_group.allow_icmp_from_everywhere.id}", "${aws_security_group.allow_internet.id}", "${aws_vpc.vpc1.default_security_group_id}" ]

  user_data = "${data.template_file.init.rendered}"

  tags = {
    Name = "server-db-2"
  }
}

output "db_public_dns2" {
  value = aws_instance.server-db-2.public_dns
}

################################################### EBS ####################################################
#### SERVER1 ####
resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 1
  type = "gp2"

  tags = {
    Name = "my_ebs_volume"
  }
}

resource "aws_volume_attachment" "volume_attachment" {
  # An example: sdh becomes xvdh on Linux
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.my_ebs_volume.id}"
  instance_id = "${aws_instance.server1.id}"

  # This is dangerous, but mounted volume cannot be destroyed when destroying VM, because of an error:
  # "Error waiting for Volume (vol-0d7f1f050d86f5a20) to detach from Instance: i-086d6bab259aebf6d"
  force_detach = true
}

#### SERVER2 ####
# Create EBS volume
resource "aws_ebs_volume" "my_ebs_volume2" {
  availability_zone = "us-east-1b"
  size              = 1
  type = "gp2"

  tags = {
    Name = "my_ebs_volume2"
  }
}

resource "aws_volume_attachment" "volume_attachment2" {
  # An example: sdh becomes xvdh on Linux
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.my_ebs_volume2.id}"
  instance_id = "${aws_instance.server2.id}"

  # This is dangerous, but mounted volume cannot be destroyed when destroying VM, because of an error:
  # "Error waiting for Volume (vol-0d7f1f050d86f5a20) to detach from Instance: i-086d6bab259aebf6d"
  force_detach = true
}

################################################### EFS ####################################################
#### APP SERVER 1 ####
resource "aws_efs_file_system" "my_efs" {
  encrypted = false
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  # This parameter valid only when using provisioned throughput_mode
  # provisioned_throughput_in_mibps = 100

  tags = {
    Name = "my_efs"
  }
}

resource "aws_efs_mount_target" "my_efs_mount" {
  file_system_id = "${aws_efs_file_system.my_efs.id}"
  subnet_id      = "${aws_subnet.subnet1.id}"
  # security_groups = ["${aws_security_group.efs.id}"]
}

output "efs_dns_name" {
  value = "${aws_efs_mount_target.my_efs_mount.dns_name}"
}

#### DB SERVER 1 ####
resource "aws_efs_file_system" "my_efs_db" {
  encrypted = false
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  # This parameter valid only when using provisioned throughput_mode
  # provisioned_throughput_in_mibps = 100

  tags = {
    Name = "my_efs_db"
  }
}

resource "aws_efs_mount_target" "my_efs_db_mount" {
  file_system_id = "${aws_efs_file_system.my_efs_db.id}"
  subnet_id      = "${aws_subnet.subnet-db-1.id}"
}

output "efs_db_dns_name" {
  value = "${aws_efs_mount_target.my_efs_db_mount.dns_name}"
}

#################################################### S3 ####################################################
resource "aws_s3_bucket" "elb_logs" {
  bucket = "my-elb-tf-test-bucket-321"
  acl    = "private"

  # Dangerous
  force_destroy = true

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::my-elb-tf-test-bucket-321/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

################################################### ELB ####################################################
resource "aws_elb" "my-elb" {
  name               = "my-terraform-elb"

  # A list of security group IDs to assign to the ELB. Only valid if creating an ELB within a VPC
  security_groups = ["${aws_security_group.elb1.id}"]

  # subnets - (Required for a VPC ELB) A list of subnet IDs to attach to the ELB
  # The issue to explore: "Failure registering instances with ELB: InvalidInstance: EC2 instance i-05432d1d5a5ee4d09 is not in the same VPC as ELB."
  # Likely it means that you haven't specified any subnets for your ELB. Therefore, the ELB is being created in the default VPC.
  #
  # A list of subnet IDs in your virtual private cloud (VPC) to attach to your load balancer. Do not specify multiple subnets that are in the same Availability Zone.
  # You can specify the AvailabilityZones or Subnets property, but not both.
  # availability_zones = ["us-east-1a"]
  subnets = [ "${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}" ]

  internal = false

  access_logs {
    bucket        = "${aws_s3_bucket.elb_logs.bucket}"
    interval      = 5
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  #listener {
  #  instance_port      = 8000
  #  instance_protocol  = "http"
  #  lb_port            = 443
  #  lb_protocol        = "https"
  # (Optional) The ARN of an SSL certificate you have uploaded to AWS IAM. Note ECDSA-specific restrictions below. Only valid when lb_protocol is either HTTPS or SSL
  #  ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  #}

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 3
    # target            = "HTTP:8080/"
    target              = "TCP:8080"
    interval            = 10
  }

  instances                   = ["${aws_instance.server1.id}", "${aws_instance.server2.id}"]

  # Enable cross-zone load balancing. Default: true
  cross_zone_load_balancing   = true

  # The time in seconds that the connection is allowed to be idle
  idle_timeout                = 400

  # The time in seconds to allow for connections to drain. Default: 300
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "my-terraform-elb"
  }
}

output "elb_dns" {
  value = aws_elb.my-elb.dns_name
}

############################################### SECURITY GROUPS ############################################
resource "aws_security_group" "allow_ssh_from_everywhere" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH from everywhere"
  # vpc_id      = "vpc-e51f859f"
  vpc_id      = "${aws_vpc.vpc1.id}"

  # Inline rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ] # add a CIDR block here
  }

  tags = {
    Name = "allow_ssh_from_everywhere"
  }
}

resource "aws_security_group" "allow_icmp_from_everywhere" {
  name        = "allow_icmp_from_everywhere"
  description = "Allow ICMP from everywhere"
  # vpc_id      = "vpc-e51f859f"
  vpc_id      = "${aws_vpc.vpc1.id}"

  # Inline rule
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ] # add a CIDR block here
  }

  tags = {
    Name = "allow_ssh_from_everywhere"
  }
}

resource "aws_security_group" "allow_internet" {
  name        = "allow_internet"
  description = "allow_internet"
  vpc_id      = "${aws_vpc.vpc1.id}"

  # Inline rule
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Inline rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "allow_internet"
  }
}

resource "aws_security_group" "elb1" {
  name        = "elb1"
  description = "elb1"
  vpc_id      = "${aws_vpc.vpc1.id}"

  # Inline rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "elb1"
  }
}

resource "aws_security_group" "allow_8080_from_everywhere" {
  name        = "allow_8080_from_everywhere"
  description = "allow_8080_from_everywhere"
  vpc_id      = "${aws_vpc.vpc1.id}"

  # Inline rule
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [ "0.0.0.0/0" ] # add a CIDR block here
  }

  tags = {
    Name = "allow_8080_from_everywhere"
  }
}

########################################## OUTPUT TO ANOTHER MODULE ########################################
# output "output_test" {
#   value = "${digitalocean_droplet.db.ipv4_address}"
# }

output "vpc1_id" {
  value = "${aws_vpc.vpc1.id}"
}
