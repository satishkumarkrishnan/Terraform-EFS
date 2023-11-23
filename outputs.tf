output "asg_vpc_subnet" {
  value = module.asg.vpc_subnet
}

output "asg_efs_id" {
  value = aws_efs_file_system.tokyo_efs.id
}

output "asg_efs_vpc_sg" {
  value = aws_efs_mount_target.alpha.security_groups
}