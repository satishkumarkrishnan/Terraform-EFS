terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

module "asg" {
  source="git@github.com:satishkumarkrishnan/terraform-aws-asg.git?ref=main"  
}

module "kms" {
  source="git@github.com:satishkumarkrishnan/Terraform-KMS.git?ref=main"  
}

#Resource  code for creating EFS 
resource "aws_efs_file_system" "tokyo_efs" {
  creation_token = "tokyo_token"
  encrypted      = true
  kms_key_id     = module.kms.kms_arn
  depends_on     = [module.asg]

  tags = {
    Name = "Tokyo-EFS"
  }
}

#Adding lifecycle Policy
resource "aws_efs_file_system" "foo_with_lifecyle_policy" {
 # creation_token = "tokyo_token"   

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"    
  }
}

#EFS Mount Target
resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.tokyo_efs.id
  subnet_id      = module.asg.vpc_subnet
  depends_on     = [module.asg]
}