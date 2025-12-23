locals {
  instance_type = "t3.medium"
  ports_tcp_all = ["80"]
}


module "ec2_wordpress" {
  version = "v6.1.5"
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = format("%s-%s-instance", var.app, var.environment)

  ami = data.aws_ami.amz2023.id
  user_data_base64 = base64encode(
    templatefile("${path.module}/scripts/cloud-init.sh", {
      MYSQL_ADMIN_PWD    = var.mysq_admin_pwd
      MYSQL_USER_PWD     = var.mysq_user_pwd
      MYSQL_DATABASE     = var.mysql_database
      MYSQL_TABLE_PREFIX = var.mysql_table_prefix
    })
  )
  /*
  user_data = templatefile("${path.module}/scripts/cloud-init.sh", {
    MYSQL_ADMIN_PWD    = var.mysq_admin_pwd
    MYSQL_USER_PWD     = var.mysq_user_pwd
    MYSQL_DATABASE     = var.mysql_database
    MYSQL_TABLE_PREFIX = var.mysql_table_prefix
  })
*/
  create_eip    = true
  instance_type = "t3.medium"
  key_name      = module.instance_key_pair.key_pair_name
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]
  #iam_role_name               = aws_iam_role.instance_role.name
  create_iam_instance_profile = true
  #iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [aws_security_group.instace_security_group.id]

  root_block_device = {
    size                  = 10
    delete_on_termination = true
    type                  = "gp3"
    encrypted             = true
  }
  ebs_volumes = {
    "/dev/sdb" = {
      size                  = 10 # GB
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      tags = {
        MountPoint = "/var/http"
      }
    },
    "/dev/sdc" = {
      size                  = 10 # GB
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      tags = {
        MountPoint = "/var/lib/mysql"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}

##ref: https://github.com/terraform-aws-modules/terraform-aws-key-pair
module "instance_key_pair" {
  version = "v2.1.1"
  source  = "terraform-aws-modules/key-pair/aws"

  key_name           = format("kp-%s-%s-instance", var.app, var.environment)
  create_private_key = true
}


data "aws_ami" "amz2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "instace_security_group" {
  vpc_id      = module.vpc.vpc_id
  description = "Security group for wordpress nodes."
  name        = format("%s-%s-instance-sg", lower(var.app), var.environment)

  dynamic "ingress" {
    for_each = local.ports_tcp_all
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = format("sg-%s-%s-instance", lower(var.app), var.environment)
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}

