provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
}

################################################################## EXAMPLE VPC ############################################################
resource "aws_instance" "server_example_vpc" {
  # Cannot use us-east-1f because subnet is in us-east-1a
  availability_zone = "us-east-1a"
  depends_on = ["aws_internet_gateway.gw"]
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet1.id}"
  # security_groups = [ "default" ]
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh_from_everywhere.id}", "${aws_security_group.allow_internet.id}", "${aws_vpc.example_vpc.default_security_group_id}" ]

  # it destroys VM when changing security groups here
  #security_groups = [
    # "default",
  #  "allow_ssh_from_everywhere"
  #]

  # root_block_device {
  #   volume_type = "gp2"
  #   volume_size = 20
  # }

  user_data = "${file("attach_ebs.sh")}"

  tags = {
    Name = "server_example_vpc"
  }
}

# Create EBS volume
resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 1
  type = "gp2"

  tags = {
    Name = "my_ebs_volume"
  }
}

# Attach to VM: server_example_vpc
resource "aws_volume_attachment" "volume_attachment" {
  # An example: sdh becomes xvdh on Linux
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.my_ebs_volume.id}"
  instance_id = "${aws_instance.server_example_vpc.id}"

  # This is dangerous, but mounted volume cannot be destroyed when destroying VM, because of an error:
  # "Error waiting for Volume (vol-0d7f1f050d86f5a20) to detach from Instance: i-086d6bab259aebf6d"
  force_detach = true
}

output "public_dns" {
  value = aws_instance.server_example_vpc.public_dns
}

################################################################## DEFAULT VPC ############################################################
resource "aws_instance" "server_default_vpc" {
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"

  # it destroys VM when changing security groups here
  security_groups = [
    "default",
    "allow_ssh_from_everywhere_default"
  ]

  tags = {
    Name = "server_default_vpc"
  }
}
