#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USERD="postgres"
PASSWD=`(date +%s | sha256sum | base64 | head -c 32;)`&>> $LOG
EMAILPASS=$PASSWD
CREDENCIAL= echo " usuário: ${USERD} senha: ${PASSWD}" > /home/credenciais.txt 
clear
echo "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" 
add-apt-repository universe &>> $LOG
add-apt-repository multiverse &>> $LOG
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
#sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0"; /g' /etc/apt/apt.conf.d/20auto-upgrades
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock &>> $LOG
sleep 1;
sudo dpkg --configure -a && sudo apt --fix-broken install -y  &>> $LOG
sleep 1;
sudo apt update &>> $LOG
apt -y install postgresql-13 &>> $LOG
systemctl enable postgresql &>> $LOG
sed -i 's/localhost/*/g ' /etc/postgresql/13/main/postgresql.conf &>> $LOG
sed -i 's/#listen_addresses/listen_addresses/g ' /etc/postgresql/13/main/postgresql.conf &>> $LOG
sed -i '97 i host    all             all             0.0.0.0/0             md5' /etc/postgresql/13/main/pg_hba.conf &>> $LOG
apt update &>> $LOG
su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password '$PASSWD';"\" 
service postgresql restart &>> $LOG
echo "Credenciais salvas em: /home/credenciais.txt"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo "Tempo gasto para execução do script $0: $TEMPO"
echo "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`" &>> $LOG
exit