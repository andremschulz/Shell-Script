#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USERD="root"
PASSWD=`(date +%s | sha256sum | base64 | head -c 32;)`
AGAIN=$PASSWD
CREDENCIAL= echo " usuário: ${USERD} senha: ${PASSWD}" > /home/credenciais.txt 
GRANTALL="GRANT ALL ON *.* TO $USERD@'%' IDENTIFIED BY '$PASSWD';"
UPDATE1045="UPDATE user SET Password=PASSWORD('$PASSWD') WHERE User='$USERD';"
UPDATE1698="UPDATE user SET plugin='' WHERE User='$USERD';"
FLUSH="FLUSH PRIVILEGES;"
ADMINUSERD=$USERD
ADMIN_PASS=$PASSWD
APP_PASSWD=$PASSWD
APP_PASS=$PASSWD
WEBSERVER="localhost"
cd /tmp/ && git clone https://git.brascloud.com.br/andre/default-file-nginx.git  &>> $LOG
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
sudo rm /var/cache/debconf/config.dat
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
rm /var/lib/dpkg/updates/0001 &>> $LOG
sudo dpkg --configure -a &>> $LOG
sleep 2;
sudo apt --fix-broken install -y  &>> $LOG
apt update &>> $LOG
echo "mariadb-server-10.1 mysql-server/root_password password $PASSWD" | debconf-set-selections
echo "mariadb-server-10.1 mysql-server/root_password_again password $AGAIN" | debconf-set-selections
debconf-show mariadb-server-10.1 &>> $LOG
apt -y install nginx mariadb-server mariadb-client mariadb-common php-fpm php-mysql \
perl python mcrypt apt-transport-https &>> $LOG
sleep 2;
apt -y install php7.2 php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc \
php-zip php-cli php-json php-readline php-imagick php-bcmath php-apcu &>> $LOG
echo "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect $WEBSERVER" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string $ADMINUSERD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ADMIN_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_PASS" | debconf-set-selections
debconf-show phpmyadmin &>> $LOG
apt -y install phpmyadmin php-mbstring php-gettext php-dev libmcrypt-dev php-pear pwgen &>> $LOG
pecl channel-update pecl.php.net &>> $LOG
echo | pecl install mcrypt-1.0.1 &>> $LOG
phpenmod mcrypt &>> $LOG
phpenmod mbstring &>> $LOG
ln -vs /usr/share/phpmyadmin /var/www/html &>> $LOG
chown -v www-data.www-data /var/www/html/* &>> $LOG
cp -v /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old &>> $LOG
cp -v /tmp/default-file-nginx/default /etc/nginx/sites-available/default &>> $LOG
sed -i 's/max_execution_time = 30/max_execution_time = 1800/g ' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/upload_max_filesize= 2M/upload_max_filesize= 16M/g ' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/post_max_size = 8M/post_max_size = 32M/g ' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/memory_limit = 128M/memory_limit = 256M/g ' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/$ ; date.timezone=/date.timezone= "America/Sao_Paulo"/g ' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/# server_tokens off;/server_tokens off; /g' /etc/nginx/nginx.conf &>> $LOG
sed -i 's/expose_php = On/expose_php = Off /g' /etc/php/7.2/fpm/php.ini  &>> $LOG
sed -i 's/ bind-address/#bind-address /g' /etc/mysql/mariadb.conf.d/50-server.cnf &>> $LOG
systemctl restart php7.2-fpm &>> $LOG
systemctl restart nginx &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$GRANTALL" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$UPDATE1045" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$UPDATE1698" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$FLUSH" mysql &>> $LOG
systemctl restart mariadb &>> $LOG
netstat -an | grep '80\|3306'
echo "Credenciais salvas em: /home/credenciais.txt"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
exit 1