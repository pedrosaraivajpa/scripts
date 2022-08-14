#!/bin/bash

HOST=$(hostname)
DIR=/home/pentaho/logCrontab
DATA=$(date +"%d-%m-%Y")

##rm $DIR/crontab-${DATA}.txt
echo "${DATA} Executado"

echo "Extrai soh os erro do dia no formato de data do log do cron"

ALERTA=$(cat /var/log/cron | grep CRON.*\(pentaho\) | grep -i erro | grep "$(LANG=en date '+%b %e')")

echo "$ALERTA" > /home/pentaho/scripts/logCrontab/logCron.txt

  ##VERIFICA SE A VARIAVEL EH DIFERENTE DE VAZIO
  if [ ! -z "$ALERTA" ]; then
  echo "ENTREI NA CONDICAO"

  /home/pentaho/scripts/SnakeMail.py -H "servidor de email" -p 25 -f pedromarquessaraiva@outlook.com -t "pedromarquessaraiva@outlook.com" -u "ALERTA DE ERRO DO LOG DO CRON DIA ${DATA} " -x "/home/pentaho/scripts/logCrontab/logCron.txt" -m "Segue o alerta de erro do log cron em anexo."
  fi
