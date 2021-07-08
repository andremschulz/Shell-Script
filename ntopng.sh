#!/bin/bash
HORAINICIAL=$(date +%T)
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
NTOPNG="http://apt-stable.ntop.org/18.04/all/apt-ntop-stable.deb"
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
	add-apt-repository universe &>> $LOG
	add-apt-repository multiverse &>> $LOG
    sudo rm /var/cache/debconf/config.dat
    sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
    sudo rm /var/lib/dpkg/updates/0001 &>> $LOG
    sudo dpkg --configure -a &>> $LOG
	apt update &>> $LOG
	rm -v ntopng.deb &>> $LOG
	cd /tmp && wget $NTOPNG -O ntopng.deb &>> $LOG
	dpkg -i ntopng.deb &>> $LOG
	apt update &>> $LOG
	apt -y install software-properties-common &>> $LOG
	apt -y install ntopng ntopng-data &>> $LOG
	systemctl enable ntopng &>> $LOG
	systemctl start ntopng &>> $LOG
	netstat -an | grep 3001
	HORAFINAL=$(date +%T)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1