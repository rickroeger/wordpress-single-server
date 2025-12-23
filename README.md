# wordpress-single-server
Simple terraform script to create an Wordpress Single Server

- 1x VPC and Public Subnet
- 1x EC2 instance
- 1x WordPress and Mariadb Install in one sigle server

## 1. Configure the AWSCLI Profile

Configure the awscli profile. You need to create accesskey and secretkey on AWS WEB Console and provide on this command
```
aws configure --profille [profile_name]
```
```
aws configure --profille mvp
```
## 2. Configure the Terraform.tfvars

Configure you terraform.ftvars as your needs: 
```
#main configuration
region      = "us-east-2"
app         = "wordpress-blue"
environment = "qas"
profile     = "mvp"

#network configs
cidr               = "192.168.0.0/20"
azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
vpc_public_subnets = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]


#MYSQL Configuration
mysq_admin_pwd     = ""
mysq_user_pwd      = "" #password for wp_user
mysql_table_prefix = "wp_blue_"
mysql_database     = "wp_blue"

```
## 3. Prepare the Cloud Init file
You must create the file below. It's the cloud init file. The script run on machine bootstrap
example:
```
cat << EOF > cloud-init.txt
#cloud-config
runcmd:
  - apt-get update
  - apt-get install -y docker.io
  - systemctl start docker
  - systemctl enable docker
EOF
```
## 4. Apply the Terrafor Configuration
```
tfswitch #switch to current terraform configuration
terraform plan
terraform apply
```
## 5. Log on WOrdpress and finish you configuration
Access the web interface and follow the step by step
```
http://[dns external]:80/WordPress
```
