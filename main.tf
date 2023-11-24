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
/*resource "aws_efs_file_system" "tokyo_efs" {
  creation_token = "tokyo_token"
  encrypted      = true
  kms_key_id     = module.kms.kms_arn
  depends_on     = [module.asg]
  

  tags = {
    Name = "Tokyo-EFS"
  }
}*/

#Adding lifecycle Policy
resource "aws_efs_file_system" "tokyo_efs" {
 creation_token = "tokyo_token"
  encrypted      = true
  kms_key_id     = module.kms.kms_arn
  depends_on     = [module.asg]  

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"    
  }
  tags = {
    Name = "Tokyo-EFS"
  }
}

#EFS Mount Target
resource "aws_efs_mount_target" "tokyo_EFS_mount" {
  file_system_id  = aws_efs_file_system.tokyo_efs.id
  subnet_id       = module.asg.vpc_subnet  
  security_groups = [ module.asg.vpc_fe_sg, module.asg.vpc_be_sg ]
}

#EFS Access Point
resource "aws_efs_access_point" "tokyo_EFS_accesspoint" {
  file_system_id = aws_efs_file_system.tokyo_efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/access"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
  tags = {
    Name = "Tokyo-EFS-Accesspoint"
  }
}


resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.tokyo_efs.id
  policy         = data.aws_iam_policy_document.policy.json
}

resource "null_resource" "configure_nfs" {
  depends_on = [ aws_efs_access_point.tokyo_EFS_accesspoint, aws_efs_mount_target.tokyo_EFS_mount ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    #private_key = module.asg.private_key
    host     = module.asg.instance_id
    
  }
  provisioner "remote-exec" {
inline = [
"sudo yum install httpd php git -y -q ",
"sudo systemctl start httpd",
"sudo systemctl enable httpd",
"sudo yum install nfs-utils -y -q ", # Amazon ami has pre installed nfs utils
# Mounting Efs 
"sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.tokyo_efs.dns_name}:/  /var/www/html",
# Making Mount Permanent
"echo ${aws_efs_file_system.tokyo_efs.dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab " ,
"sudo chmod go+rw /var/www/html",
"sudo git clone https://github.com/Apeksh742/EC2_instance_with_terraform.git /var/www/html",
  ]
 }
}