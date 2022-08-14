#!/bin/bash
###CRIADO POR PEDRO SARAIVA####
### DATA 05112020####

HOST=$(hostname)
DIR=/home/pentaho/scripts/logCrontab
DATA=$(date +"%d-%m-%Y")

##rm $DIR/crontab-${DATA}.txt
echo "${DATA} Executado"
crontab -l -u pentaho > ${DIR}/crontab-${DATA}.txt

echo "Enviando o Email"

/home/pentaho/scripts/SnakeMail.py -H "Endereco do server de email" -p 25 -f pedromarquessaraiva@outlook.com -t "pedromarquessaraiva@outlook.com" -u "BACKUP CRONTAB PENTAHO - DIA ${DATA} " -x "${DIR}/crontab-${DATA}.txt" -m "Segue o Crontab do Pentaho em anexo."

find /home/pentaho/scripts/logCrontab/ -mtime +3 -name "crontab-*.txt" -exec rm {} \;
