
#!/bin/sh

#################################################################
#                Rotina de Backup Fisico                        #
#                                                               #
# Desenvolvida por:  Pedro Saraiva                              #
# Tipo de Backup:    ARCHIVES                                   #
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
PATHBACKUP=/acfs01/fast_recovery_area/DB_TEST/rman/archives
FILECONTROL=/tmp/exec_rman_archive_DB_TEST.flag
SPOOL=/home/oracle/netbackup_logs/${HOSTNAME}_oracle_${ORACLE_SID}_arc-$DATA.log
LOG=/home/oracle/netbackup_logs/backup_archive-$DATA.log
BACKUP_TAG=${ORACLE_SID}_ARC_${DATA}


if ! [ -f $FILECONTROL ]; then

  echo "#############################"`date` >> ${LOG}
  echo "Inicio do Backup $ORACLE_SID - ARCHIVELOG :  `date`" >> ${LOG}

  touch $FILECONTROL

$ORACLE_HOME/bin/rman TARGET / msglog $SPOOL <<EOF
RUN {
configure backup optimization off;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE ENCRYPTION ALGORITHM 'AES256';
ALLOCATE CHANNEL c1 TYPE DISK ;
ALLOCATE CHANNEL c2 TYPE DISK ;
ALLOCATE CHANNEL c3 TYPE DISK ;
ALLOCATE CHANNEL c4 TYPE DISK ;
backup as compressed backupset archivelog all not backed up 2 times FORMAT '${PATHBACKUP}/Bkp_ARCH_%d_%c-%p_%T_%t_%s.arc';
RELEASE CHANNEL c1;
RELEASE CHANNEL c2;
RELEASE CHANNEL c3;
RELEASE CHANNEL c4;
configure backup optimization on;
}
EOF

  rm -f /tmp/exec_rman_archive_DB_TEST.flag

  echo "Fim do Backup $ORACLE_SID - ARCHIVELOG :    `date`" >> ${LOG}
  echo "#############################"`date` >> ${LOG}

fi

exit
