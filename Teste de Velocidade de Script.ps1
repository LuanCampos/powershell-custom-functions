<#  Teste de Velocidade v2
    Luan Campos - 11/2018  #>

$script1 = "Nome do primeiro script"
$script2 = "Nome do segundo script"

#ambos os scripts precisam usar as mesmas máquinas para um resultado confiável
[array]$computers = Get-Content -Path C:\Temp\Computers.txt

[int]$numero = $computers.Length
[double]$seconds1 = 0
[double]$seconds2 = 0

echo "[$([DateTime]::Now)] ========================== Starting Log ==========================" >> "C:\Temp\Teste_de_Velocidade.log"
echo "[$([DateTime]::Now)] Teste referente a execução em $numero máquina(s)" >> "C:\Temp\Teste_de_Velocidade.log"
echo "[$([DateTime]::Now)] Iniciando o procedimento para teste: $script1" >> "C:\Temp\Teste_de_Velocidade.log"

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

& 'Caminho do primeiro script'

$stopwatch.Stop()
$seconds1 += $stopwatch.Elapsed.TotalSeconds

echo "[$([DateTime]::Now)] Tempo em segundos: $seconds1" >> "C:\Temp\Teste_de_Velocidade.log"
echo "[$([DateTime]::Now)] Iniciando o procedimento para teste: $script2" >> "C:\Temp\Teste_de_Velocidade.log"

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

& 'Caminho do segundo script'

$stopwatch.Stop()
$seconds2 += $stopwatch.Elapsed.TotalSeconds

echo "[$([DateTime]::Now)] Tempo em segundos: $seconds2" >> "C:\Temp\Teste_de_Velocidade.log"

if ($seconds2 -gt $seconds1) {
$seconds3 = $seconds2 / $seconds1
echo "[$([DateTime]::Now)] O primeiro script foi $seconds3 vezes mais rápido" >> "C:\Temp\Teste_de_Velocidade.log"
}

else {
$seconds3 = $seconds1 / $seconds2
echo "[$([DateTime]::Now)] O segundo script foi $seconds3 vezes mais rápido" >> "C:\Temp\Teste_de_Velocidade.log"
}

echo "[$([DateTime]::Now)] ========================== Ending Log ==========================" >> "C:\Temp\Teste_de_Velocidade.log"