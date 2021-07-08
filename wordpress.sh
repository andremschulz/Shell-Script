#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
WORDPRESS="https://wordpress.org/latest.zip"
USER="root"
PASSWORD=`(date +%s | sha256sum | base64 | head -c 32;)`
DATABASE="CREATE DATABASE wordpress;"
USERDATABASE="CREATE USER 'wordpress' IDENTIFIED BY 'wordpress';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'wordpress' IDENTIFIED BY 'wordpress';"
GRANTALL="GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
FLUSH="FLUSH PRIVILEGES;"
CREDENCIAL= echo "usuário: wordpress    senha: ${PASSWORD}    Nome do Banco: wordpress" > /home/credenciais.txt 
clear
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
echo -e "Adicionando o Repositórios.."
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
sudo rm /var/cache/debconf/config.dat &>> $LOG
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
rm /var/lib/dpkg/updates/0001 &>> $LOG
sudo dpkg --configure -a &>> $LOG
sleep 2;
sudo apt --fix-broken install -y  &>> $LOG
sleep 2;
apt -y install lamp-server^ perl python apt-transport-https unzip &>> $LOG
apt update &>> $LOG
echo -e "Fazendo o download, instalação e configuração do WP.."
wget $WORDPRESS &>> $LOG
unzip latest.zip &>> $LOG
mv -v wordpress/ /var/www/html/wp &>> $LOG
cd /tmp/ && git clone https://git.brascloud.com.br/andre/default-file-nginx.git
cp -v /tmp/default-file-nginx/htaccess /var/www/html/wp/.htaccess &>> $LOG
cp -v /tmp/default-file-nginx/wp-config.php /var/www/html/wp/ &>> $LOG
chmod -Rfv 755 /var/www/html/wp/ &>> $LOG
chown -Rfv www-data.www-data /var/www/html/wp/ &>> $LOG
rm -v latest.zip &>> $LOG
echo -e "Criando a Base de Dados do Wordpress, aguarde..."
mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Editando o arquivo de configuração da Base de Dados do Wordpress, aguarde..."
sed 's/define('DB_PASSWORD', 'wordpress');/define('DB_PASSWORD', '${PASSWORD}'); /g' /var/www/html/wp/wp-config.php
sed -i '225 i ServerTokens ProductOnly' /etc/apache2/apache2.conf &>> $LOG
sed -i '226 i ServerSignature Off' /etc/apache2/apache2.conf &>> $LOG
systemctl restart apache2
echo -e "Arquivo editado com sucesso!!!, continuando com o script..."
#echo -e "Editando o arquivo de configuração do .htaccess do Wordpress, aguarde..."
#sed 's/ /g' /var/www/html/wp/.htaccess
echo -e "Arquivo editado com sucesso!!!, continuando com o script..."
echo -e "Instalação do Wordpress feito com Sucesso!!!"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo "Credenciais salvas em: /home/credenciais.txt"
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1