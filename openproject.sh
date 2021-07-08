#!/bin/bash
HORAINICIAL=$(date +%T)
USER="postgres"
PASSWD=`(date +%s | sha256sum | base64 | head -c 32;)`
CREDENCIAL= echo " usuário: ${USER} senha: ${PASSWD}" > /home/credenciais.txt 
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
HOSTNAME=hostname
KEY="https://dl.packager.io/srv/opf/openproject/key"
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
sleep 1;
sudo dpkg --configure -a && sudo apt --fix-broken install -y  &>> $LOG
sleep 1;
	wget -qO- $KEY| apt-key add - &>> $LOG
    cd /tmp/ && git clone https://git.brascloud.com.br/andre/default-file-nginx.git
	cp -v /tmp/default-file-nginx/openproject.list /etc/apt/sources.list.d/ &>> $LOG
	apt update &>> $LOG
	apt -y install openproject &>> $LOG
    cp -v /tmp/default-file-nginx/installer.dat /etc/openproject/ &>> $LOG
	    openproject configure &>> $LOG
	netstat -an | grep 45432
	sudo -u $USER psql -p 45432 openproject --command '\l' | grep openproject
    su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password '$PASSWD';"\" 
	HORAFINAL=$(date +%T)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1