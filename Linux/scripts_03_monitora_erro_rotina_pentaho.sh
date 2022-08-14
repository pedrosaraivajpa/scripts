#!/bin/bash

HOST=$(hostname)
DIR=/home/pentaho/scripts/log
DATA=$(date +"%d-%m-%Y")

echo "${DATA} Executado"

echo "LISTA SOH OS ARQUIVOS QUE FORAM ALTERADOS NAS ULTIMAS 12HRS"

#ALERTA=$(find $(crontab -l | grep .log |  awk -F '>' '{print $2}' | awk -F ' ' '{print $1}') -mtime -0,5)
#echo $ALERTA > /home/pentaho/scripts/log/ArquivoText.log | '\n'
#echo $ALERTA
touch /home/pentaho/scripts/log/jobsComErro-${DATA}.log
touch /home/pentaho/scripts/log/jobsComErroEmail-${DATA}.log

find $(crontab -l | grep .log |  awk -F '>' '{print $2}' | awk -F ' ' '{print $1}') -mtime -0,5 > /home/pentaho/scripts/log/jobsComErro-${DATA}.log

while read line
do

   ##PROCURA NO LOOP SE TEM ALGUMA PALAVRA COM ERRO
   ALERTA=$(cat $line | egrep "Errors|ERROR|Error")

 ##SOH ENTRA NO IF SE A VARIAVEL FOR DIFERENTE DE VAZIO
 if [ ! -z "$ALERTA" ]; then

   ##Envia o nome do arquivo que deu erro para o anexo no email
   echo "$line" >> /home/pentaho/scripts/log/jobsComErroEmail-${DATA}.log

 fi

done < /home/pentaho/scripts/log/jobsComErro-${DATA}.log

  ##SOH ENVIA EMAIL SE A VARIAVEL FOR DIFERENTE DE VAZIO
  if [ ! -z "/home/pentaho/scripts/log/jobsComErroEmail.log" ]; then
   /home/pentaho/scripts/SnakeMail.py -H "servidore-mail.email.com.br" -p 25 -f pedromarquessaraiva@outlook.com -t "pedromarquessaraiva@outlook.com" -u "JOBS DO CRONTAB PENTAHO COM ERRO ${DATA} " -x "/home/pentaho/scripts/log/jobsComErroEmail-${DATA}.log" -m "Segue os JOBS agendados na crontab que tiveram erro."
   fi

##APAGA OS ARQUIVOS UTILIZADOS
rm -f /home/pentaho/scripts/log/jobsComErro-${DATA}.log
rm -f /home/pentaho/scripts/log/jobsComErroEmail-${DATA}.log
