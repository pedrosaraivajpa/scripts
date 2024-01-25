#!/bin/bash -x

#################################################################
#                Rotina de Backup Fisico                        #
#                                                               #
# Desenvolvida por:  Pedro Saraiva                              #
# Tipo de Backup:    BACKUP FULL PG_BASEBACKUP                  #
# Arquivo config:    /pgbackup/backup_full.sh                   #
#################################################################
# variaveis
export AGORA=$(date +%Y-%m-%d)
#export AGORA=$(date -d "$(date +%Y-%m-%d) - 8 days" +%Y-%m-%d)
export HORA=$(date +%H:%M:%S)

# Criacao do arquivo de log
LOGFILE=/pgbackup/log/backup_full_$AGORA.log

# Verifica se o diretorio de log existe e cria caso nao exista
[ ! -d "$LOGFILE" ] && touch "$LOGFILE"

# Diretorio local
DIRETORIO_LOCAL="/pgbackup/$AGORA"

# Verificar se o diretorio de backup existe e cria caso nao exista
[ ! -d "$DIRETORIO_LOCAL" ] && mkdir -p "$DIRETORIO_LOCAL"

# Prefixo no S3
PREFIXO_NO_S3="softplan-prd/backup"

echo "---------Inicio da rotina de backup $HORA---------" >> $LOGFILE

echo "Relatorio de uso do disco de backup:" >>$LOGFILE
du -sh /pgbackup >>$LOGFILE
echo " " >>$LOGFILE

pg_basebackup --format=tar --checkpoint=fast --gzip --verbose --progress --pgdata /pgbackup/$AGORA >> $LOGFILE 2>&1

if [ $? -eq 0 ]
  then

  echo "Executando a sincronia com s3" >>$LOGFILE
  # Itera sobre os arquivos no diretório
    for ARQUIVO_LOCAL in "$DIRETORIO_LOCAL"/*; do
      if [ -f "$ARQUIVO_LOCAL" ]; then
        # Calcula o checksum MD5 antes de enviar
        echo "Calcula o checksum MD5 antes de enviar" >>$LOGFILE
        MD5_LOCAL_BEFORE=$(md5sum "$ARQUIVO_LOCAL" | awk '{print $1}')

        # Envia o arquivo para o S3
        echo "Enviando o arquivo para o S3" >>$LOGFILE
        aws s3 cp $DIRETORIO_LOCAL/$(basename "$ARQUIVO_LOCAL") s3://$PREFIXO_NO_S3/$AGORA/

        # Calcula o checksum MD5 depois de enviar
        echo "Calculado o checksum MD5 depois de enviar" >>$LOGFILE
        MD5_LOCAL_AFTER=$(aws s3 cp "s3://$PREFIXO_NO_S3/$AGORA/$(basename "$ARQUIVO_LOCAL")" - | md5sum | awk '{print $1}')

        # Compara os checksums antes e depois do envio
        echo "Compara os checksums antes e depois do envio" >>$LOGFILE
        if [ "$MD5_LOCAL_BEFORE" == "$MD5_LOCAL_AFTER" ]; then

          echo "Checksums correspondem O arquivo ($ARQUIVO_LOCAL) foi transmitido com sucesso para o S3" >>$LOGFILE

          # Verifica se o tamanho do arquivo local eh igual ao remoto
          echo "Verifica se o tamanho do arquivo local eh igual ao remoto tamanho local" >>$LOGFILE
          TAMANHO_LOCAL=$(stat --printf="%s" "$ARQUIVO_LOCAL")

          echo "Verifica se o tamanho do arquivo local eh igual ao remoto tamanho remoto" >>$LOGFILE
          TAMANHO_REMOTO=$(aws s3 ls "s3://$PREFIXO_NO_S3/$AGORA/$(basename "$ARQUIVO_LOCAL")" | awk '{print $3}')

          # Verifica se tamanho local maior que zero tamanho local igual a tamanho remoto e tamanho remoto eh maior que zero
          if [ "$TAMANHO_LOCAL" -gt 0 ] && [ "$TAMANHO_LOCAL" == "$TAMANHO_REMOTO" ] && [ "$TAMANHO_REMOTO" -gt 0 ]; then

            echo "Tamanhos dos arquivos local e remoto são iguais Removendo o arquivo local após a transmissão bem-sucedida" >>$LOGFILE
            rm "$ARQUIVO_LOCAL"

            else
              echo "Erro: Tamanhos dos arquivos local e remoto são diferentes. O arquivo ($ARQUIVO_LOCAL) pode não ter sido transmitido corretamente" >>$LOGFILE
          fi

        else
          echo "Erro: Checksums não correspondem O arquivo ($ARQUIVO_LOCAL) pode não ter sido transmitido corretamente" >>$LOGFILE
        fi
      fi
    done

  else
    echo "Erro ao realizar o backup" >>$LOGFILE
fi

echo " " >>$LOGFILE
echo "Relatorio de uso de disco:" >>$LOGFILE
du -sh /pgbackup >>$LOGFILE
echo " " >>$LOGFILE
echo "---------Fim da rotina de backup$HORA---------" >>$LOGFILE
