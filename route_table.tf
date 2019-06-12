# Adds gateway to a dedicated routing table (dedicated VPC)
resource "aws_route" "my_route" {
  # This routing table was created together with VPC so re-using it
  route_table_id = "${aws_vpc.example_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

# Adds explicit association to the dedicated subnet (dedicated VPC)
resource "aws_route_table_association" "my_routes_association" {
  subnet_id      = "${aws_subnet.subnet1.id}"

  # Use newly created route above
  # route_table_id = "${aws_route_table.my_routes.id}"

  # Use existing route (which was created with )
  route_table_id = "${aws_vpc.example_vpc.main_route_table_id}"
}
