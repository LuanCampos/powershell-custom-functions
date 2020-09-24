<#  Softwares Consulta
    Luan Campos - 11/2018  #>

#Faz a leitura do arquivo com os Ativos em que o Script atuará
$computers = Get-Content -Path C:\Temp\Computers.txt

Write "" [$([DateTime]::Now)]" Inicio do script..."
echo "[$([DateTime]::Now)] =========== Starting Log ===========" >> "C:\Temp\Softwares_Consulta.log"

[array]$novoArquivo = @()
[array]$excel = @()

#Cria o laço que será repetido para cada Ativo
foreach ($machine in $computers) {
    write "" "Procurando $machine..."

    #Testa a conexão
    if(Test-Connection $machine -Count 1 -Quiet){
   
    Write-Host " - Iniciando a busca de softwares..."
    echo "[$([DateTime]::Now)] - $machine - Conectado" >> "C:\Temp\Softwares_Consulta.log"

    #Começa o job
    Start-Job -ScriptBlock { param ($machine)
        $b = New-PSSession $machine
        $app = Invoke-Command -Session $b -FilePath "C:\Temp\Get-Software.ps1" | Where-Object {$_.name -notlike "*Update For*" -and $_.name -notlike "*Segurity Update*" -and $_.name -notlike "*Definition Update*" -and $_.name -notlike "*hotfix*"}
        return $app
    } -ArgumentList $machine | Out-Null

    }
    else {
    write "Sem Conexão"
    echo "[$([DateTime]::Now)] - $machine - Offline (Warning)" >> "C:\Temp\Softwares_Consulta.log"
    $novoArquivo += $machine
    }

}

Write "" [$([DateTime]::Now)]" Esperando as buscas serem finalizadas..."
echo "[$([DateTime]::Now)] === Waiting for the running jobs ===" >> "C:\Temp\Softwares_Consulta.log"
Wait-Job * | Out-Null

Write "" "Coletando resultados..."

#Processa os resultados
foreach($job in Get-Job){
$result = Receive-Job $job
$excel += $result
$machine = $result.ComputerName[0]
echo "[$([DateTime]::Now)] - $machine - Sucesso" >> "C:\Temp\Softwares_Consulta.log"
}

Remove-Job -State Completed

Write "Gerando arquivo..."
$excel | Export-Csv C:\Temp\Softwares.csv
#Remove-Item C:\Temp\Computers.txt -Force -Recurse
#$novoArquivo >> C:\Temp\Computers.txt
echo "[$([DateTime]::Now)] =========== Ending Log ===========" >> "C:\Temp\Softwares_Consulta.log"
Write "" [$([DateTime]::Now)]" Fim do Script."