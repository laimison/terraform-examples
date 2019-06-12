# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "example_vpc"
  }
}

resource "aws_subnet" "subnet1" {
  # availability_zone = "${data.aws_availability_zones.available.names[0]}"
  availability_zone = "us-east-1a"

  # interpolation to have dynamic value
  vpc_id = "${aws_vpc.example_vpc.id}"
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}
