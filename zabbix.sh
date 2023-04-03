#!/bin/sh
# zabbix.sh
# Adiél Lima
# 03apr2023
# contato@nuvym.net
# v1
###########################################################
## pkg ##
sudo pkg install -y zabbix52-agent zabbix52-frontend zabbix52-server mod_php74-7.4.15 apache24-2.4.46 \
mysql57-server
## config ##
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/httpd.conf
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/my.cnf
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/zabbix_agentd.conf
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/zabbix_server.conf
sudo mv httpd.conf /usr/local/etc/apache24/ 
sudo chown root /usr/local/etc/apache24/httpd.conf
sudo chmod 400 /usr/local/etc/apache24/httpd.conf 
sudo mv my.cnf /usr/local/etc/mysql/
sudo chown mysql /usr/local/etc/mysql/my.cnf 
sudo chmod 400 /usr/local/etc/mysql/my.cnf 
sudo mv zabbix_agentd.conf /usr/local/etc/zabbix52/ 
sudo chown root /usr/local/etc/zabbix52/zabbix_agentd.conf
sudo chmod 400 /usr/local/etc/zabbix52/zabbix_agentd.conf 
sudo mv zabbix_server.conf /usr/local/etc/zabbix52/
sudo chown root /usr/local/etc/zabbix52/zabbix_server.conf
sudo chmod 400 /usr/local/etc/zabbix52/zabbix_server.conf
## rc.conf ##
sudo sh -c "echo zabbix_agentd_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo zabbix_server_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo mysql_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_enable="YES" >> /etc/rc.conf" 
sudo sh -c "echo apache24_http_accept_enable="YES" >> /etc/rc.conf" 
## log ##
sudo mkdir /var/log/apache
sudo chown www /var/log/apache
sudo chmod 700 /var/log/apache
## zabbix ##
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/zabbix.conf.php
sudo mv zabbix.conf.php /usr/local/www/zabbix52/conf/
sudo chown www /usr/local/www/zabbix52/conf/zabbix.conf.php 
sudo chmod 400 /usr/local/www/zabbix52/conf/zabbix.conf.php
sudo sh -c "echo post_max_size=16M >> /usr/local/etc/php.ini"
sudo sh -c "echo max_execution_time=300 >> /usr/local/etc/php.ini"
sudo chown root /usr/local/etc/php.ini
sudo chmod 400 /usr/local/etc/php.ini
sudo chmod 400 /usr/local/www/zabbix52/index.php
sudo chown www /usr/local/www/zabbix52/index.php
sudo chflags schg /usr/local/www/zabbix52/index.php
sudo service apache24 restart
sudo mkdir /usr/local/etc/zabbix52/ssh/
sudo chown ec2-user:zabbix /usr/local/etc/zabbix52/ssh/
sudo chmod 770 /usr/local/etc/zabbix52/ssh/
sudo mkdir /var/run/mysql 
sudo chmod 775 /var/run/mysql
sudo chown mysql:zabbix /var/run/mysql
sudo service mysql-server restart
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/user-my.cnf
mv user-my.cnf .my.cnf 
chown ec2-user .my.cnf 
chmod 600 .my.cnf
sudo cp /root/.mysql_secret /home/ec2-user/.mysql_secret
sudo chown ec2-user .mysql_secret
echo password=\"`cat .mysql_secret | awk 'NR==2'`\" >> .my.cnf
rm .mysql_secret 
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/config-mysql 
#mysql --defaults-file=.my.cnf < config-mysql
#mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/schema.sql
#mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/images.sql
#mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/data.sql
mysql --connect-expired-password < config-mysql
mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/schema.sql
mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/images.sql
mysql zabbix --user='zabbix' --password='P@ssw0rd-#CHANGEME!' < /usr/local/share/zabbix52/server/database/mysql/data.sql
rm config-mysql
sudo mkdir /var/log/zabbix
sudo chmod 700 /var/log/zabbix
sudo chown zabbix /var/log/zabbix
sudo mkdir /var/run/zabbix
sudo chown zabbix /var/run/zabbix
sudo chmod 700 /var/run/zabbix
## hardening ##
fetch -q --no-verify-peer https://raw.githubusercontent.com/Adiel-Ribeiro/Zabbix/master/mem.sh
mkdir /home/ec2-user/scripts
chown ec2-user /home/ec2-user/scripts
chmod 700 /home/ec2-user/scripts
mv mem.sh /home/ec2-user/scripts/.mem.sh 
chmod 700 /home/ec2-user/scripts/.mem.sh 
sudo chflags schg /home/ec2-user/scripts/.mem.sh 
echo "@reboot /home/ec2-user/scripts/.mem.sh"  > /home/ec2-user/cron
cat /home/ec2-user/cron | sudo crontab -u root -
rm cron
sudo reboot