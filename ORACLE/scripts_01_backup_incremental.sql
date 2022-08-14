#!/bin/sh

#################################################################
#                Rotina de Backup Fisico                        #
#                                                               #
# Desenvolvida por:  Pedro Saraiva                              #
# Tipo de Backup:    BACKUP FULL INCREMENTAL LEVEL 1            #
#                                                               #
#################################################################

PATH=$PATH:$HOME/bin

export PATH

DATA=`date '+%d_%m_%Y_%H_%M'`

source /home/oracle/.bash_profile

ORACLE_UNQNAME=DB_TEST
TNS_ADMIN=${ORACLE_HOME}/network/admin/${ORACLE_UNQNAME}
RMAN=${ORACLE_HOME}/bin/rman
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${ORACLE_HOME}/bin
PATHBACKUP=/acfs01/fast_recovery_area/DB_TEST/rman/incremental
FILECONTROL=/tmp/exec_rman_inc_DB_TEST.flag
SPOOL=/home/oracle/netbackup_logs/${HOSTNAME}_oracle_${ORACLE_SID}_inc-$DATA.log
LOG=/home/oracle/netbackup_logs/backup_inc-$DATA.log
BACKUP_TAG=${ORACLE_SID}_INC_${DATA}

if ! [ -f $FILECONTROL ]; then

  echo "#############################"`date` >> ${LOG}
  echo "Inicio do Backup $ORACLE_SID - INC :  `date`" >> ${LOG}

  touch $FILECONTROL

$ORACLE_HOME/bin/rman TARGET / msglog $SPOOL <<EOF
configure backup optimization off;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE ENCRYPTION ALGORITHM 'AES256';
configure controlfile autobackup off;
RUN {
ALLOCATE CHANNEL ch1 TYPE DISK ;
ALLOCATE CHANNEL ch2 TYPE DISK ;
ALLOCATE CHANNEL ch3 TYPE DISK ;
ALLOCATE CHANNEL ch4 TYPE DISK ;
ALLOCATE CHANNEL ch5 TYPE DISK ;
ALLOCATE CHANNEL ch6 TYPE DISK ;
ALLOCATE CHANNEL ch7 TYPE DISK ;
ALLOCATE CHANNEL ch8 TYPE DISK ;
ALLOCATE CHANNEL ch9 TYPE DISK ;
crosscheck backup of database;
crosscheck backup of controlfile;
crosscheck archivelog all;
backup incremental level 1 AS COMPRESSED BACKUPSET SKIP INACCESSIBLE format '${PATHBACKUP}/Bkp_LVL1_%d_%c-%p_%T_%t_%s.bak' database;
backup current controlfile format '${PATHBACKUP}/Bkp_LVL1_%d_%c-%p_%T_%t_%s.ctl';
RELEASE CHANNEL ch1;
RELEASE CHANNEL ch2;
RELEASE CHANNEL ch3;
RELEASE CHANNEL ch4;
RELEASE CHANNEL ch5;
RELEASE CHANNEL ch6;
RELEASE CHANNEL ch7;
RELEASE CHANNEL ch8;
RELEASE CHANNEL ch9;
}
configure backup optimization on;
EOF

  rm -f /tmp/exec_rman_inc_DB_TEST.flag

  echo "Fim do Backup $ORACLE_SID - INC :    `date`" >> ${LOG}
  echo "#############################"`date` >> ${LOG}

fi

exit
