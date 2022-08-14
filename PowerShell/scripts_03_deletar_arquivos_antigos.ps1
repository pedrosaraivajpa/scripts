# -------------------------------------------------------------------------------------------
# SCRIPT TO DELETE FILES (.TXT, .LOG AN SO ON.) OLDER THAN NDAYS
# -------------------------------------------------------------------------------------------
# SET $LOGPATH WITH THE PATH TO CHECK THE LOG FILES.
# YOU CAN COMBINE MORE THAN ONE LOG FOLDER: "C:\INETPUB\LOGS\,F:\LOGS"
$logPath = "\\destino_1\Pasta_1,\\destino_2\Pasta_2,\\destino_3\Pasta_3"
$listaDiretorios = $logPath.Split(',')

foreach($diretorio in $listaDiretorios) {

# -------------------------------------------------------------------------------------------
# SET $NDAYS WITH THE NUMBER OF DAYS TO KEEP IN LOG FOLDER.
$nDays		= 6
# -------------------------------------------------------------------------------------------
# SET $EXTENSIONS WITH THE FILE EXTENSION TO DELETE.
# YOU CAN COMBINE MORE THAN ONE EXTENSION: "*.LOG, *.TXT,"
$Extensions	= "*.txt"
# -------------------------------------------------------------------------------------------
# PAY ATTENTION! IF YOU COMBINE MORE THAN ONE LOG PATH AND EXTENSIONS,
# MAKE SURE THAT YOU ARE NOT REMOVING FILES THAT CANNOT BE DELETED 
# IN ALL FOLDERS!
# -------------------------------------------------------------------------------------------
$LogDate = (Get-Date).ToString("dd_MM_yyyy")

$Files = Get-Childitem $diretorio -Include $Extensions -Recurse | Where `
{$_.LastWriteTime -le (Get-Date).AddDays(-$nDays)}

foreach ($File in $Files) 
{
    if ($File -ne $NULL)
    {
        $Log = "The File " + $File + " has been deleted."
        $Log | Out-File -Append C:\Caminho_log\logs\DeleteLogFile_$LogDate.log
        ##Remove-Item $File.FullName | out-null
        echo $File.FullName
	}
}

}
