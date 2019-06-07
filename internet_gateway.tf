resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.example_vpc.id}"

  tags = {
    Name = "gw"
  }
}
