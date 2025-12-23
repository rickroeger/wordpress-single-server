#!/bin/bash


#wait disk attached:
sleep 100

#download the workpress
cd /tmp
wget https://github.com/WordPress/WordPress/archive/master.zip
unzip master -d /tmp/WordPress_Temp
mkdir -p /tmp/WordPress
cp -paf /tmp/WordPress_Temp/WordPress-master/* /tmp/WordPress
rm -rf /tmp/WordPress_Temp
rm -f master

#mount httpd filesystem
mkfs.xfs /dev/nvme1n1
mkdir -p /var/www
mount /dev/nvme1n1 /var/www
echo "/dev/nvme1n1 /var/www xfs defaults,nofail 0 2" >> /etc/fstab

#mount mariadb filesystem
useradd mysql
mkfs.xfs /dev/nvme2n1
mkdir -p /var/lib/mysql
mount /dev/nvme2n1 /var/lib/mysql
echo "/dev/nvme2n1 /var/lib/mysql xfs defaults,nofail 0 2" >> /etc/fstab
chown mysql:mysql /var/lib/mysql

#install dependencies
sudo yum update
sudo yum install -y httpd 
sudo yum install -y php8.1 php8.1-mysqlnd
sudo yum install -y mariadb105-server 

#copy the wordpress
cp -r /tmp/WordPress/ /var/www/html/
chmod 777 -R /var/www/html/WordPress

#enable and start services 
systemctl start mariadb.service
systemctl start httpd.service
systemctl start php-fpm.service
systemctl enable mariadb.service
systemctl enable httpd.service
systemctl enable php-fpm.service


mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PWD}';
CREATE USER 'wp_user'@'localhost';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* To 'wp_user'@'localhost' IDENTIFIED BY '${MYSQL_USER_PWD}';
EOF
