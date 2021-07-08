#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USER="root"
PASSWORD=`(date +%s | sha256sum | base64 | head -c 32;)`
CREDENCIAL= echo " usuário: ${USER} senha: ${PASSWORD}" > /home/credenciais.txt 
DATABASE="CREATE DATABASE joomla CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
USERDATABASE="CREATE USER 'joomla' IDENTIFIED BY 'joomla';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'joomla' IDENTIFIED BY 'joomla';"
GRANTALL="GRANT ALL PRIVILEGES ON joomla.* TO 'joomla' IDENTIFIED BY '$PASSWORD' WITH GRANT OPTION;"
FLUSH="FLUSH PRIVILEGES;"
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
add-apt-repository ppa:ondrej/php -y &>> $LOG
sudo rm /var/cache/debconf/config.dat
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
rm /var/lib/dpkg/updates/0001 &>> $LOG
sudo dpkg --configure -a &>> $LOG
sleep 2;
sudo apt --fix-broken install -y  &>> $LOG
apt update &>> $LOG
apt -y install software-properties-common mysql-server && apt -y install lamp-server^ php8.0 perl python apt-transport-https unzip &>> $LOG
apt -y install php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc &>> $LOG
apt -y install php8.0 &>> $LOG
apt -y install php8.0-common php8.0-mysql php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd php8.0-imagick php8.0-cli php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-soap php8.0-zip php8.0-intl
sleep 2;
chown -v www-data.www-data /var/www/html/* &>> $LOG
sed -i 's/max_execution_time = 30/max_execution_time = 1800/g ' /etc/php/7.2/apache2/php.ini  &>> $LOG
sed -i 's/upload_max_filesize= 2M/upload_max_filesize= 16M/g '/etc/php/7.2/apache2/php.ini  &>> $LOG
sed -i 's/post_max_size = 8M/post_max_size = 32M/g ' /etc/php/7.2/apache2/php.ini  &>> $LOG
sed -i 's/memory_limit = 128M/memory_limit = 512M/g ' /etc/php/7.2/apache2/php.ini &>> $LOG
sed -i 's/$ ; date.timezone=/date.timezone= "America/Sao_Paulo"/g ' /etc/php/7.2/apache2/php.ini  &>> $LOG
sed -i 's/expose_php = On/expose_php = Off /g' /etc/php/7.2/apache2/php.ini  &>> $LOG
sed -i 's/bind-address/#bind-address /g' /etc/mysql/mysql.conf.d/mysqld.cnf &>> $LOG
sed -i '225 i ServerTokens ProductOnly' /etc/apache2/apache2.conf &>> $LOG
sed -i '226 i ServerSignature Off' /etc/apache2/apache2.conf &>> $LOG
cd /var/www/html/
sudo wget https://downloads.joomla.org/cms/joomla3/3-9-27/Joomla_3-9-27-Stable-Full_Package.zip?format=zip
sudo unzip Joomla_3-9-27-Stable-Full_Package.zip?format=zip
sudo chown -R www-data: /var/www/html/* &>> $LOG
rm -rf Joomla_3-9-27-Stable-Full_Package.zip?format=zip
systemctl restart apache2 &>> $LOG
systemctl restart mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
systemctl restart mysql  &>> $LOG
netstat -an | grep '80\|3306'
echo "Credenciais salvas em: /home/credenciais.txt"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
exit 1