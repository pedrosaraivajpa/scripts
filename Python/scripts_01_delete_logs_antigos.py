import os
import glob
import time
import datetime
'''
Scripts Criado para deletar arquivos por externsao, baseando em periodo de tempo, o scripts abaixo arquivos com extensao .trm com mais de 7 dias.
'''
#pega o dia de hoje
var_dia_executado = datetime.date.today()
# pega a hora em segundos
now = time.time()
#criar o arquivo do dia, caso exista ele abri o arquivo e inseri os arquivos deletados dentro do arquivo de log #
arquivo_log = open(r"C:\python\logs/logExecucao_" + str(var_dia_executado) + ".txt", "a")

py_files = glob.glob(r'C:\python\arquivos/*.trm')

###loop para os arquivos de logs
for py_file in py_files:
    var_arquivo = py_file
    if os.stat(var_arquivo).st_mtime < (now - 604800) and os.path.isfile(var_arquivo):
        os.remove(var_arquivo)
        var_arquivo = var_arquivo + "\n"
        arquivo_log.write(var_arquivo)
        #print(var_arquivo)
