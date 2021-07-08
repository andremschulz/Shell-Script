#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
    add-apt-repository universe &>> $LOG
	add-apt-repository multiverse &>> $LOG
	apt update &>> $LOG
    apt install snapd &>> $LOG
	snap install rocketchat-server &>> $LOG
sleep 1
	netstat -an | grep '3000\|27017'
	HORAFINAL=$(date +%T)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1