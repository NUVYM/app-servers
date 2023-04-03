#!/bin/sh
# glpi.sh
# Adiél Lima
# 03apr2023
# contato@nuvym.net
# v1
###########################################################
################### install packages ############################################################################
sudo pkg install -y glpi-9.5.3,1 mod_php74-7.4.14 apache24-2.4.46 mysql57-server
########################## config mysql #########################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/my.cnf
sudo mv my.cnf /usr/local/etc/mysql/
sudo chown mysql /usr/local/etc/mysql/my.cnf 
sudo chmod 400 /usr/local/etc/mysql/my.cnf 
sudo mkdir /var/run/mysql 
sudo chmod 775 /var/run/mysql
sudo chown mysql:mysql /var/run/mysql
########################## config apache ########################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/httpd.conf
sudo mv httpd.conf /usr/local/etc/apache24/ 
sudo chown root /usr/local/etc/apache24/httpd.conf
sudo chmod 400 /usr/local/etc/apache24/httpd.conf 
sudo mkdir /var/log/apache
sudo chown www /var/log/apache
sudo chmod 700 /var/log/apache
######################### config rc.conf ########################################################################
sudo sh -c "echo mysql_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_http_accept_enable="YES" >> /etc/rc.conf" 
######################### config databases ######################################################################
sudo service mysql-server restart
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/user-my.cnf
mv user-my.cnf .my.cnf 
chown ec2-user .my.cnf 
chmod 600 .my.cnf
sudo cp /root/.mysql_secret /home/ec2-user/.mysql_secret
sudo chown ec2-user .mysql_secret
echo password=\"`cat .mysql_secret | awk 'NR==2'`\" >> .my.cnf
rm .mysql_secret 
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/config-mysql 
mysql --connect-expired-password < config-mysql
rm config-mysql
################################ pre final config ##################################################################
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/mem.sh
mkdir /home/ec2-user/scripts
chown ec2-user /home/ec2-user/scripts
chmod 700 /home/ec2-user/scripts
mv mem.sh /home/ec2-user/scripts/.mem.sh 
chmod 700 /home/ec2-user/scripts/.mem.sh 
sudo chflags schg /home/ec2-user/scripts/.mem.sh 
echo "@reboot /home/ec2-user/scripts/.mem.sh"  > /home/ec2-user/cron
cat /home/ec2-user/cron | sudo crontab -u root -
rm cron
############################## final config ###############################################################
sudo pkg install -y php74-pecl-APCu-5.1.19
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/config_db.php
sudo mv config_db.php /usr/local/www/glpi/config/config_db.php
sudo chmod 400 /usr/local/www/glpi/config/config_db.php
sudo chown www /usr/local/www/glpi/config/config_db.php
sudo chown www /usr/local/www/glpi/index.php
sudo chmod 500 /usr/local/www/glpi/index.php
sudo chflags schg /usr/local/www/glpi/index.php
sudo rm /usr/local/www/glpi/install/install.php
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Glpi/master/glpi.sql
mysql glpi --user='root' --password='P@ssw0rd-#CHANGEME!' < glpi.sql
sudo sh -c "echo upload_tmp_dir = /tmp >> /usr/local/etc/php.ini"
sudo chown www /tmp
rm glpi.sql
sudo reboot