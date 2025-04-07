# variaveis
LOGFILE=/pasta/scripts/apaga_wals_antigos.log
 
echo "Inicio:" >>${LOGFILE}
(date +"%Y-%m-%d-%H.%M.%S") >>${LOGFILE}
echo "Relatorio de uso de disco:" >>${LOGFILE}
du -sh /pgarch >>${LOGFILE}
echo " " >>${LOGFILE}
echo "Arquivos que serao apagados:" >>${LOGFILE}
find /pgarch -mtime +3 -type f -printf '%t \t %p \n' >>${LOGFILE}
find /pgarch -mtime +3 -type f | xargs rm
echo " " >>${LOGFILE}
echo "Relatorio de uso de disco:" >>${LOGFILE}
du -sh /pgarch >>${LOGFILE}
echo " " >>${LOGFILE}
(date +"%Y-%m-%d-%H.%M.%S") >>${LOGFILE}
echo "Fim" >>${LOGFILE}
