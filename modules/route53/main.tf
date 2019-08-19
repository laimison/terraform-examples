variable "vpc1_id" {}

################################################## PRIVATE DNS ZONE ################################################
resource "aws_route53_zone" "private1" {
  name = "internal."

  # Private zone requires at least one association with VPC
  vpc {
    vpc_id = "${var.vpc1_id}"

    # Hardcoding for the tests
    # vpc_id = "vpc-0bb1527d0055f8551"
  }

  # lifecycle {
  #   ignore_changes = ["vpc"]
  # }
}

# This is needed only for multiple cross-region DNS zone
# resource "aws_route53_zone_association" "secondary" {
#   zone_id = "${aws_route53_zone.private1.zone_id}"
#   vpc_id  = "${aws_vpc.vpc2.id}"
# }

resource "aws_route53_record" "test" {
  zone_id = "${aws_route53_zone.private1.zone_id}"
  name = "test.dev.${aws_route53_zone.private1.name}"
  type = "A"
  ttl = "60"
  records = ["10.10.10.10"]
}
