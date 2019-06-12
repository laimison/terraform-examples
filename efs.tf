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
