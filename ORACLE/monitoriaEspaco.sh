
#!/bin/bash

PATH=$PATH:$HOME/bin

source /home/oracle/.bash_profile

export PATH
export ORACLE_SID=$1

DATA_ATUAL=$(date +"%d%m%Y")

if [ -f "/u01/app/oracle/monitoria-espaco-Oracle-Diario.loc" ];
then
echo "Rotina ainda em andamento..."
exit

else
##cria o arquivo de loc da rotina
touch /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario.loc
chown oracle:oinstall /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario.loc

##cria o arquivo de log diario
touch /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
chown oracle:oinstall /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log

echo "----------INICIO DA ROTINA--------------$(date +"%d/%m/%Y %H:%M:%S")" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
echo "" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log

echo "----------MONITORIA DA INSTANCIA $ORACLE_SID---------" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
echo "" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log

echo "-----------COLETA DO TAMANHO DAS PARTICOES---------" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
df -h >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
echo "" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log

echo "----------COLETA DO TAMANHO DAS TABLESPACES-----------" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log
coleta_tablespace=`sqlplus -s /nolog <<EOF
connect / as sysdba
set pagesize 50000
set linesize 450
set long 1000
set null '-'
set wrap off
set echo on
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD-HH24.MI.SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD-HH24.MI.SS';
column nuprocesso format 999999999999
set sqlblanklines on
set echo off
set heading off
set feedback off
set heading on
set feedback on
set echo on


SELECT
       TABLESPACE_NAME,
       TAMANHO_ATUAL,
       TAMANHO_MAXIMO,
       TAMANHO_LIVRE,
       PCUSE
  FROM (
        SELECT
              TABLESPACE_NAME,
              Round(SUM(BYTES)/1024/1024/1024,2) AS TAMANHO_ATUAL,
              Round(SUM(MAXBYTES)/1024/1024/1024,2) AS tamanho_maximo,
              Round(SUM(MAXBYTES)/1024/1024/1024,2) - Round(SUM(BYTES)/1024/1024/1024,2) AS TAMANHO_LIVRE,
              Round(Round(SUM(BYTES)/1024/1024/1024,2) / Round(SUM(MAXBYTES)/1024/1024/1024,2) * 100,1) PCUSE
        FROM DBA_DATA_FILES
        GROUP BY TABLESPACE_NAME
       ) A ORDER BY 2 DESC;

exit
EOF`

echo "$coleta_tablespace" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log


echo "---------FIM DA ROTINA-----------$(date +"%d/%m/%Y %H:%M:%S")" >> /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario_${DATA_ATUAL}_${ORACLE_SID}.log

rm -f /home/oracle/scripts/logs/monitoria-espaco-Oracle-Diario.loc
fi
