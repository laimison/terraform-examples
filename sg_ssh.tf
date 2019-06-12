################################################################## EXAMPLE VPC ############################################################
resource "aws_security_group" "allow_ssh_from_everywhere" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH from everywhere"
  # vpc_id      = "vpc-e51f859f"
  vpc_id      = "${aws_vpc.example_vpc.id}"

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

resource "aws_security_group" "allow_internet" {
  name        = "allow_internet"
  description = "allow_internet"
  vpc_id      = "${aws_vpc.example_vpc.id}"

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

################################################################## DEFAULT VPC ############################################################
resource "aws_security_group" "allow_ssh_from_everywhere_default" {
  name        = "allow_ssh_from_everywhere_default"
  description = "Allow SSH from everywhere_default"
  vpc_id      = "vpc-e51f859f"
  # vpc_id      = "${aws_vpc.example_vpc.id}"

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
    Name = "allow_ssh_from_everywhere_default"
  }
}

# External rule
# resource "aws_security_group_rule" "ingress_http" {
#   type        = "ingress"
#   from_port   = 80
#   to_port     = 80
#   protocol    = 6
#   cidr_blocks = ["0.0.0.0/0"]
#
#   security_group_id = "${aws_security_group.allow_all.id}"
# }
