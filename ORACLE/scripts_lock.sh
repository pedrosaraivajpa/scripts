#!/bin/bash -x

#export ORACLE_SID=$1
export ORACLE_SID=$1
#export ORACLE_UNQNAME=$(echo $ORACLE_SID| cut -d'1' -f 1)
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS'
export DATA=`date +%d%m%Y_%H%M`
#export LOG=/WiseDb/scripts/logs/Backup_Full_Inc0_${ORACLE_SID}_${DATA}.log
export PATH=$PATH:/u01/app/oracle/product/12.1.0/dbhome_1/bin:/usr/sbin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin

RETORNO=`sqlplus -s /nolog <<EOF
connect / as sysdba
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT
     OWNER, OBJECT_NAME, OBJECT_TYPE, INST_ID, SID, BLOCKING_SESSION, SERIAL#, STATUS, OSUSER, MACHINE, MODULE, TEMPO_MIN, INSTANCE_NAME,Count(1) AS QTD
FROM (
SELECT
      C.OWNER,
      C.OBJECT_NAME,
      C.OBJECT_TYPE,
      B.INST_ID,
      B.SID,
      B.BLOCKING_SESSION,
      B.SERIAL#,
      B.STATUS,
      B.OSUSER,
      B.MACHINE,
      B.MODULE,
      ROUND(B.SECONDS_IN_WAIT/60,0) AS TEMPO_MIN,
      (SELECT INSTANCE_NAME FROM GV\\\$INSTANCE I WHERE B.INST_ID = I.INST_ID ) AS INSTANCE_NAME
FROM  "GV\\\$LOCKED_OBJECT" A
INNER JOIN "GV\\\$SESSION" B ON B.SID = A.SESSION_ID
INNER JOIN "DBA_OBJECTS" C ON A.OBJECT_ID = C.OBJECT_ID
WHERE B.BLOCKING_SESSION IS NOT NULL
AND   B.SECONDS_IN_WAIT > 30 )
GROUP BY OWNER, OBJECT_NAME, OBJECT_TYPE, INST_ID, SID, BLOCKING_SESSION, SERIAL#, STATUS, OSUSER, MACHINE, MODULE, TEMPO_MIN, INSTANCE_NAME;

exit
EOF`


OWNER=`echo $RETORNO | awk '{print $1}'`
OBJECT_NAME=`echo $RETORNO | awk '{print $2}'`
OBJECT_TYPE=`echo $RETORNO | awk '{print $3}'`
INST_ID=`echo $RETORNO | awk '{print $4}'`
SID=`echo $RETORNO | awk '{print $5}'`
BLOCKING_SESSION=`echo $RETORNO | awk '{print $6}'`
SERIAL=`echo $RETORNO | awk '{print $7}'`
STATUS=`echo $RETORNO | awk '{print $8}'`
OSUSER=`echo $RETORNO | awk '{print $9}'`
MACHINE=`echo $RETORNO | awk '{print $10}'`
MODULE=`echo $RETORNO | awk '{print $11}'`
TEMPO_MIN=`echo $RETORNO | awk '{print $12}'`
INSTANCE_NAME=`echo $RETORNO | awk '{print $13}'`
QTD=`echo $RETORNO | awk '{print $13}'`

if [ ! -z "$QTD" ]; then

curl -X POST --data-urlencode "payload={\"channel\": \"teste\", \"username\": \"ALERTA LOCK - ORACLE\", \"text\":\"ATENCAO: Usuario $OWNER ESTA EM LOCK NO OBJECTO $OBJECT_NAME NA INSTANCIA: $INSTANCE_NAME COM SID: $SID  \", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/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

fi
[ora