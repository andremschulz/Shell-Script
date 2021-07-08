#cloud-config
#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USER="root"
PASSWORD=`(date +%s | sha256sum | base64 | head -c 32;)`
CREDENCIAL= echo " usuário: ${USER} senha: ${PASSWORD}" > /home/credenciais.txt 
DATABASE="CREATE DATABASE nextcloud;"
USERDATABASE="CREATE USER 'nextcloud' IDENTIFIED BY 'nextcloud';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'nextcloud' IDENTIFIED BY 'nextcloud';"
GRANTALL="GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud' IDENTIFIED BY '$PASSWORD' WITH GRANT OPTION;"
FLUSH="FLUSH PRIVILEGES;"
RELEASE="https://download.nextcloud.com/server/releases/nextcloud-21.0.2.zip"
export DEBIAN_FRONTEND="noninteractive"
clear
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
	add-apt-repository universe &>> $LOG
	add-apt-repository multiverse &>> $LOG
    add-apt-repository ppa:ondrej/php -y &>> $LOG
sleep 1
    sudo rm /var/cache/debconf/config.dat
    sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
    sudo dpkg --configure -a &>> $LOG
    sleep 2;
    sudo apt --fix-broken install -y  &>> $LOG
    apt update &>> $LOG
sleep 2;
	apt -y install software-properties-common mysql-server && apt -y install lamp-server^ php8.0 perl python apt-transport-https unzip &>> $LOG
	apt -y install php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc &>> $LOG
    apt -y install php8.0 &>> $LOG
    apt -y install php8.0-common php8.0-mysql php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd php8.0-imagick php8.0-cli php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-soap php8.0-zip php8.0-intl
	systemctl restart apache2 &>> $LOG
sleep 1;
echo | a2dismod autoindex &>> $LOG
	a2enmod rewrite &>> $LOG
	a2enmod headers &>> $LOG
	a2enmod env &>> $LOG
	a2enmod dir &>> $LOG
	a2enmod mime &>> $LOG
    a2dismod php7.2 &>> $LOG
    a2enmod php8.0 &>> $LOG
echo -e "Fazendo o download e Instalando o nextcloud do site Oficial, aguarde..."
	rm -v nextcloud-21.0.2.zip &>> $LOG
	wget $RELEASE -O nextcloud-21.0.2.zip &>> $LOG
	unzip nextcloud-21.0.2.zip &>> $LOG
	mv -v nextcloud/ /var/www/html/nextcloud/ &>> $LOG
	chown -Rv www-data:www-data /var/www/html/nextcloud/ &>> $LOG
	chmod -Rv 755 /var/www/html/nextcloud/ &>> $LOG
    sed -i 's/expose_php = On/expose_php = Off /g' /etc/php/8.0/apache2/php.ini  &>> $LOG
    sed -i 's/bind-address/#bind-address /g' /etc/mysql/mysql.conf.d/mysqld.cnf &>> $LOG
    sed -i '225 i ServerTokens ProductOnly' /etc/apache2/apache2.conf &>> $LOG
    sed -i '226 i ServerSignature Off' /etc/apache2/apache2.conf &>> $LOG
sleep 1
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
sleep 1
apt update
systemctl restart apache2
echo -e "Instalação do nextcloud feita com Sucesso!!!."
	HORAFINAL=`date +%T`
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1