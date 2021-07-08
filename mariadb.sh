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
apt -y install mariadb-server mariadb-client mariadb-common &>> $LOG
sleep 2;
sed -i 's/ bind-address/#bind-address /g' /etc/mysql/mariadb.conf.d/50-server.cnf &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$GRANTALL" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$UPDATE1045" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$UPDATE1698" mysql &>> $LOG
mariadb -u $USERD -p$PASSWD -e "$FLUSH" mysql &>> $LOG
systemctl restart mariadb &>> $LOG
netstat -an | grep '3306'
echo "Credenciais salvas em: /home/credenciais.txt"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
exit 1