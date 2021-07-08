#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
URL="http://$IP:$PORT"
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
        add-apt-repository universe &>> $LOG
        add-apt-repository multiverse &>> $LOG
    sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
    sleep 1;
    sudo dpkg --configure -a && sudo apt --fix-broken install -y  &>> $LOG
    sleep 1;
        apt update &>> $LOG
    wget https://downloads.plex.tv/plex-media-server-new/1.23.1.4602-280ab6053/debian/plexmediaserver_1.23.1.4602-280ab6053_amd64.deb &>> $LOG
    dpkg -i plexmediaserver_1.23.1.4602-280ab6053_amd64.deb
    HORAFINAL=$(date +%T)
        HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
        HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
        TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
        echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
exit 1