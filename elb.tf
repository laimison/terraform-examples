resource "aws_elb" "my-elb" {
  name               = "my-terraform-elb"

  # A list of security group IDs to assign to the ELB. Only valid if creating an ELB within a VPC
  # security_groups =

  # subnets - (Required for a VPC ELB) A list of subnet IDs to attach to the ELB
  # The issue to explore: "Failure registering instances with ELB: InvalidInstance: EC2 instance i-05432d1d5a5ee4d09 is not in the same VPC as ELB."
  # Likely it means that you haven't specified any subnets for your ELB. Therefore, the ELB is being created in the default VPC.
  #
  # A list of subnet IDs in your virtual private cloud (VPC) to attach to your load balancer. Do not specify multiple subnets that are in the same Availability Zone.
  # You can specify the AvailabilityZones or Subnets property, but not both.
  # availability_zones = ["us-east-1a"]
  subnets = [ "${aws_subnet.subnet1.id}" ]

  internal = false

  #access_logs {
  #(Required) The S3 bucket name to store the logs in
  #  bucket        = "foo"
  #  bucket_prefix = "bar"
  #  interval      = 60
  #}

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
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${aws_instance.server_example_vpc.id}"]

  # Enable cross-zone load balancing. Default: true
  cross_zone_load_balancing   = false

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
