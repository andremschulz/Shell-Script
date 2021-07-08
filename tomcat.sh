#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USER="admin"
PASSWORD=`(date +%s | sha256sum | base64 | head -c 32;)`
CREDENCIAL= echo "usuário: ${USER}    senha: ${PASSWORD}" > /home/credenciais.txt 
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
sudo rm /var/cache/debconf/config.dat
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
sudo dpkg --configure -a &>> $LOG
echo -e "Instalando as dependências do Tomcat, aguarde..."
	apt -y install default-jdk &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script..."
sleep 1
echo
echo -e "Verificando a versão do Java, aguarde..."
	java -version &>> $LOG
	update-java-alternatives -l &>> $LOG
	apt update -y &>> $LOG
echo -e "Versão verificada com sucesso!!!, continuando com o script..."
sleep 1
echo
echo -e "Instalando o Tomcat, aguarde..."
	apt -y install tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user &>> $LOG
echo -e "Tomcat instalado com sucesso!!!, continuando com o script..."
echo
	cp -v /etc/tomcat9/tomcat-users.xml /etc/tomcat9/tomcat-users.xml.bkp &>> $LOG
	cd /tmp/ && git clone https://git.brascloud.com.br/andre/default-file-nginx.git
	cp -v /tmp/default-file-nginx/tomcat-users.xml /etc/tomcat9/tomcat-users.xml &>> $LOG
	sed 's/password="passwd"/password='$PASSWORD'); /g' /etc/tomcat9/tomcat-users.xml
	systemctl restart tomcat9
echo -e "Usuário do Tomcat configurado com sucesso!!!, continuando com o script..."
echo -e "Verificando a porta de conexão do Tomcat, aguarde..."
	netstat -an | grep 8080
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script..."
echo -e "Instalação do Tomcat feita com Sucesso!!!"
	HORAFINAL=`date +%T`
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
	echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1