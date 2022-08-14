#!/bin/sh

#################################################################
#                Rotina de Backup Fisico                        #
#                                                               #
# Desenvolvida por:  Pedro Saraiva                              #
# Tipo de Backup:    BACKUP FULL INCREMENTAL LEVEL 0            #
#                                                               #
#################################################################

PATH=$PATH:$HOME/bin

export PATH

DATA=`date '+%d_%m_%Y_%H_%M'`

source /home/oracle/.bash_profile

ORACLE_SID=DB_TEST1
ORACLE_UNQNAME=DB_TEST
TNS_ADMIN=${ORACLE_HOME}/network/admin/${ORACLE_UNQNAME}
RMAN=${ORACLE_HOME}/bin/rman
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${ORACLE_HOME}/bin
PATHBACKUP=/acfs01/fast_recovery_area/DB_TEST/rman/full
FILECONTROL=/tmp/exec_rman_full_DB_TEST.flag
SPOOL=/home/oracle/netbackup_logs/${HOSTNAME}_oracle_${ORACLE_SID}_full-$DATA.log
LOG=/home/oracle/netbackup_logs/backup_full-$DATA.log

if ! [ -f $FILECONTROL ]; then

  echo "#############################"`date` >> ${LOG}
  echo "Inicio do Backup $ORACLE_SID - FULL :  `date`" >> ${LOG}

  touch $FILECONTROL

$ORACLE_HOME/bin/rman TARGET / msglog $SPOOL <<EOF
RUN {
configure backup optimization off;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE ENCRYPTION ALGORITHM 'AES256';
ALLOCATE CHANNEL ch1 TYPE DISK ;
ALLOCATE CHANNEL ch2 TYPE DISK ;
ALLOCATE CHANNEL ch3 TYPE DISK ;
ALLOCATE CHANNEL ch4 TYPE DISK ;
ALLOCATE CHANNEL ch5 TYPE DISK ;
ALLOCATE CHANNEL ch6 TYPE DISK ;
backup incremental level 0 AS COMPRESSED BACKUPSET SKIP INACCESSIBLE format '${PATHBACKUP}/Bkp_LVL0_%d_%c-%p_%T_%t_%s.bak' database;
backup current controlfile format '${PATHBACKUP}/Bkp_LVL0_%d_%c-%p_%T_%t_%s.ctl';
RELEASE CHANNEL ch1;
RELEASE CHANNEL ch2;
RELEASE CHANNEL ch3;
RELEASE CHANNEL ch4;
RELEASE CHANNEL ch5;
RELEASE CHANNEL ch6;
configure backup optimization on;
}
EOF

  rm -f /tmp/exec_rman_full_DB_TEST.flag

  echo "Fim do Backup $ORACLE_SID - FULL :    `date`" >> ${LOG}
  echo "#############################"`date` >> ${LOG}

fi

exit
