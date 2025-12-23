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


