provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
}

################################################################## EXAMPLE VPC ############################################################
resource "aws_instance" "server_example_vpc" {
  depends_on = ["aws_internet_gateway.gw"]
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_from_everywhere.id}"]

  # it destroys VM when changing security groups here
  #security_groups = [
    # "default",
  #  "allow_ssh_from_everywhere"
  #]

  tags = {
    Name = "server_example_vpc"
  }
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
