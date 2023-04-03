#!/bin/sh
# wordpress.sh
# Adiél Lima
# 03apr2023
# contato@nuvym.net
# v1
###########################################################
################### install packages ############################################################################
sudo pkg install -y wordpress-5.5.3,1 mod_php74-7.4.14 apache24-2.4.46 mysql57-server
########################## config mysql #########################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/my.cnf
sudo mv my.cnf /usr/local/etc/mysql/
sudo chown mysql /usr/local/etc/mysql/my.cnf 
sudo chmod 400 /usr/local/etc/mysql/my.cnf 
sudo mkdir /var/run/mysql 
sudo chmod 775 /var/run/mysql
sudo chown mysql:mysql /var/run/mysql
########################## config apache ########################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/httpd.conf
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/wp-config.php
sudo mv httpd.conf /usr/local/etc/apache24/ 
sudo chown root /usr/local/etc/apache24/httpd.conf
sudo chmod 400 /usr/local/etc/apache24/httpd.conf 
sudo mkdir /var/log/apache
sudo chown www /var/log/apache
sudo chmod 700 /var/log/apache
sudo mv wp-config.php /usr/local/www/wordpress
sudo chown www /usr/local/www/wordpress/wp-config.php
sudo chmod 400 /usr/local/www/wordpress/wp-config.php
######################### config rc.conf ########################################################################
sudo sh -c "echo mysql_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_http_accept_enable="YES" >> /etc/rc.conf" 
######################### config databases ######################################################################
sudo service mysql-server restart
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/user-my.cnf
mv user-my.cnf .my.cnf 
chown ec2-user .my.cnf 
chmod 600 .my.cnf
sudo cp /root/.mysql_secret /home/ec2-user/.mysql_secret
sudo chown ec2-user .mysql_secret
echo password=\"`cat .mysql_secret | awk 'NR==2'`\" >> .my.cnf
rm .mysql_secret 
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/config-mysql 
mysql --connect-expired-password < config-mysql
rm config-mysql
################################ pre final config ##################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/mem.sh
mkdir /home/ec2-user/scripts
chown ec2-user /home/ec2-user/scripts
chmod 700 /home/ec2-user/scripts
mv mem.sh /home/ec2-user/scripts/.mem.sh 
chmod 700 /home/ec2-user/scripts/.mem.sh 
sudo chflags schg /home/ec2-user/scripts/.mem.sh 
############################ cron #################################################################################
echo "@reboot /home/ec2-user/scripts/.mem.sh"  > /home/ec2-user/cron
cat /home/ec2-user/cron | sudo crontab -u root -
rm cron
###################################### final ##################################################################
sudo chmod 400 /usr/local/www/wordpress/index.php
sudo chown www /usr/local/www/wordpress/index.php
sudo chflags schg /usr/local/www/wordpress/index.php
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Wordpress/master/wordpress.sql
mysql wordpress --user='root' --password='-#CHANGEME!P@ssw0rd' < wordpress.sql
sudo chown www /tmp/
sudo sh -c "echo upload_tmp_dir = /tmp >> /usr/local/etc/php.ini"
sudo chown www /usr/local/www/wordpress/wp-content/
rm wordpress.sql
rm wordpress.sh
sudo reboot