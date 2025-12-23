#standard information
variable "profile" {
  type = string
}
variable "region" {
  type = string
}
variable "environment" {
  type = string
}
variable "app" {
  type = string
}


#network information
variable "cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "vpc_public_subnets" {
  type = list(any)
}



#database information
variable "mysq_admin_pwd" {
  type = string
}

variable "mysq_user_pwd" {
  type = string
}

variable "mysql_table_prefix" {
  type = string
}

variable "mysql_database" {
  type = string
}
