import os
import glob
import time
import pathlib
import datetime
import shutil
from pathlib import Path

# pega o dia de hoje
var_dia_executado = datetime.date.today()
var_hora_executado = datetime.datetime.now()
# criar o arquivo do dia, caso exista ele abri o arquivo e inseri os arquivos deletados dentro do arquivo de log #

if os.path.exists(r"C:\python\routine-move-files-logs-to-homolog.loc"):
    print("Rotina ainda em andamento...")
else:
    var_exits = open(r"C:\python\routine-move-files-logs-to-homolog" + ".loc", "w")
    var_exits.close()
    arquivo_log = open(r"C:\python\logs/logExecucao_" + str(var_dia_executado) + ".txt", "a")
    arquivo_log.write("Inicio da Rotina " + str(var_hora_executado) + "\n")
    source = r'C:\arquivos'
    destination = r'C:\arquivos2'
    files = list(pathlib.Path(source).glob('*.trm'))

    ###loop para os arquivos de logs
    for file in files:
        #new_path = shutil.move(f"{source}/{file}", destination)
        new_path = shutil.move(f"{file}", destination)
        new_path = new_path + "\n"
        arquivo_log.write(new_path)
    os.remove(r"C:\python\routine-move-files-logs-to-homolog.loc")
    arquivo_log.write("Fim da Rotina " + str(var_hora_executado))
