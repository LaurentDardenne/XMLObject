Param (
 # Specific to the development computer
 [string] $VcsPathRepository=''
) 

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{
  $VcsPathRepository=$env:APPVEYOR_BUILD_FOLDER
}

if (!(Test-Path $VcsPathRepository))
{
  Throw 'Configuration error, the variable $VcsPathRepository should be configured.'
}

#Variable commune à tous les postes
#todo ${env:Name with space}
if ( $null -eq [System.Environment]::GetEnvironmentVariable("ProfileXMLObject","User"))
{ 
 [Environment]::SetEnvironmentVariable("ProfileXMLObject",$VcsPathRepository, "User")
  #refresh the environment Provider
 $env:ProfileXMLObject=$VcsPathRepository 
}

 # Variable spécifiques au poste de développement
$XMLObjectDelivery= "${env:temp}\Delivery\XMLObject"   
$XMLObjectLogs= "${env:temp}\Logs\XMLObject" 

 # Variable communes à tous les postes, leurs contenu est spécifique au poste de développement
$XMLObjectBin= "$VcsPathRepository\Bin"
$XMLObjectHelp= "$VcsPathRepository\Documentation\Helps"
$XMLObjectSetup= "$VcsPathRepository\Setup"
$XMLObjectVcs= "$VcsPathRepository"
$XMLObjectTests= "$VcsPathRepository\Tests"
$XMLObjectTools= "$VcsPathRepository\Tools"
$XMLObjectUrl= 'https://github.com/LaurentDardenne/XMLObject.git'

 #PSDrive sur le répertoire du projet 
$null=New-PsDrive -Scope Global -Name XMLObject -PSProvider FileSystem -Root $XMLObjectVcs 

Write-Host "Settings of the variables of XMLObject project." -Fore Green

rv VcsPathRepository

