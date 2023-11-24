output "asg_vpc_subnet" {
  value = module.vpc.vpc_fe_subnet
}

output "asg_efs_id" {
  value = aws_efs_file_system.tokyo_efs.id
}

output "asg_efs_vpc_sg" {
  value = aws_efs_mount_target.tokyo_EFS_mount.security_groups
}

output "efs_file_system_dns" {
  value = aws_efs_file_system.tokyo_efs.dns_name
}