resource "aws_route_table" "my_routes" {
  vpc_id = "${aws_vpc.example_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "my_routes"
  }
}

resource "aws_route_table_association" "my_routes_association" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.my_routes.id}"
}
