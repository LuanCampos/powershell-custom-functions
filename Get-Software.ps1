Function Get-Software{

<#
.SYNOPSIS 
  Exibe todos os softwares de uma m�quina.

.DESCRIPTION
  Usa as chaves de registro de software (32 e 64bit) para listar "name", "version", "vendor", e "uninstall string" para cada um dos softwares de um computador.

.NOTES
  Version:        1.0.2
  Author:         Luan Campos
  Creation:  	  25/10/2018
  Updated:  	  05/11/2018
  Purpose/Change: Desenvolvimento de fun��o que agilize o processo de busca de softwares

.EXAMPLE
  ."C:\Temp\Get-Software.ps1"

Description
  Isso mostra todos os softwares instalados na m�quina local.
  >>(Em todos os exemplos, arquivo Get-Software.ps1 estar� na Temp de quem executa o Script)<<

.EXAMPLE
  ."C:\Temp\Get-Software.ps1" | Where-Object {$_.vendor -notlike "*Microsoft*"}

Description
  Isso mostra os softwares instalados na m�quina local cujo Vendor n�o � Microsoft.

.EXAMPLE
  Invoke-Command -ComputerName NB62736 -FilePath "C:\Temp\Get-Software.ps1"

Description
  Isso mostra todos os softwares instalados no ativo NB62736.

.EXAMPLE
  $app = Invoke-Command -Session $b -FilePath "C:\Temp\Get-Software.ps1" | Where-Object {$_.name -like "*Java*"}

Description
  Isso pega todas as vers�es de Java no ativo da Sess�o $b e guarda na vari�vel $app.

.EXAMPLE
  Write " - Procurando vers�o obsoleta do Java..."
  $app = Invoke-Command -Session $b -FilePath "C:\Temp\Get-Software.ps1" | Where-Object {$_.name -like "*Java*" -and $_.version -lt "8.0.1810.13" -and $_.name -notlike "*JavaScript*"}

  if ($app){
  Write " - Vers�o obsoleta do Java encontrada..."

  Invoke-Command -Session $b -ArgumentList (,$app) -ScriptBlock { param ([array]$app)
  ForEach ($stw in $app) {
  If ($stw.UninstallString) {
      $appName = $stw.Name
      $uninst = $stw.UninstallString
      Write " - Desinstalando $appName..."
      Start-Process cmd -ArgumentList "/c $uninst /quiet /norestart" -NoNewWindow -PassThru -Wait
      }
      }
  }

Description
  Isso procura vers�es do Java que s�o inferiores a "8.0.1810.13" e as desinstala da m�quina cuja Sess�o � $b.
#>

Process {

    #Abre a base remota
    $reg = [microsoft.win32.registrykey]:: OpenRemoteBaseKey('LocalMachine', $env:computername)

    #Procura pelas chaves de registro
    $keyRootSoftware = $reg.OpenSubKey("SOFTWARE")
    [bool]$is64 = ($keyRootSoftware.GetSubKeyNames() | ? {$_ -eq 'WOW6432Node'} | Measure-Object).Count
    $keyRootSoftware.Close()

    #Coloca todos os registros numa lista
    $softwareKeys = @()

    if ($is64){
        $pathUninstall64 = "SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
        $keyUninstall64 = $reg.OpenSubKey($pathUninstall64)
        $keyUninstall64.GetSubKeyNames() | % { $softwareKeys += $pathUninstall64 + "\\" + $_ }
        $keyUninstall64.Close()
        }

    $pathUninstall32 = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $keyUninstall32 = $reg.OpenSubKey($pathUninstall32)
    $keyUninstall32.GetSubKeyNames() | % { $softwareKeys += $pathUninstall32 + "\\" + $_ }
    $keyUninstall32.Close()

    #Pega informa��es de todos os registros e as organiza nos objetos
    $softwareKeys | % {
    $subkey=$reg.OpenSubKey($_)

    if ($subkey.GetValue("DisplayName")){
        $installDate = $null

        if ($subkey.GetValue("InstallDate") -match "/") {$installDate = Get-Date -Format d $subkey.GetValue("InstallDate")}
        elseif ($subkey.GetValue("InstallDate").length -eq 8) {$installDate = Get-Date -Format d $subkey.GetValue("InstallDate").Insert(6,".").Insert(4,".")}

        New-Object PSObject -Property @{
            ComputerName = $env:computername
            Name = $subkey.GetValue("DisplayName")
            Version = $subKey.GetValue("DisplayVersion")
            Vendor = $subkey.GetValue("Publisher")
            UninstallString = $subkey.GetValue("UninstallString")
            InstallDate = $installDate
            }

        }

        $subkey.Close()
        }

    $reg.Close()
    }

}

#Chama a fun��o
Get-Software