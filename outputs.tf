output "asg_vpc_subnet" {
  value = module.asg.vpc_subnet
}

output "asg_efs_" {
  value = aws_efs_file_system.tokyo_efs.id
}

