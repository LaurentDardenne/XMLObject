#  Contient des fonctions d'aide à la construction et   
#  à la vérification de fichiers XML et XSD.

function Test-Xml { 
  [CmdletBinding()]
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
      [string]$FileName,
      
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
      [string]$SchemaFile,
        
        [Parameter(Position=1,Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [string] $targetNamespace,
         
    	[Parameter(Position=2)]
    	[ValidateNotNullOrEmpty()]
	  [String] $ValidationEventHandler
  ) 
  Begin {
    if (-not $PSBoundParameters.ContainsKey('ValidationEventHandler') )
     {
        #Code de l'eventHandler par défaut qui écrit sur la console via Write-Error
       $ValidationEventHandler=@'
         param($sender, $eventArgs)
    	   Write-Debug "Erreur validation"
           $Message=$eventArgs.Exception.InnerException.Message
           if ($null -eq $Message) 
           {$eventArgs.Exception.Message}
           Write-Error ("[{0}: {1},{2}] {3} - {4} " -F $eventArgs.Severity, $eventArgs.Exception.LineNumber, $eventArgs.Exception.LinePosition,$FileName, $eventArgs.Message)
           $script:isValid=$false
'@
    }
  }
  PROCESS { 
    if ( $DebugPreference -ne "SilentlyContinue")  
    {  
      Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) 
      Write-Debug "FileName : $FileName"
 	  Write-Debug "SchemaFile :  $SchemaFile" 
    }
    
    if (-not (Test-Path "$FileName"))
     { throw (new-Object ArgumentException("Le fichier XML n'existe pas : $FileName"))}
    elseif (-not (Test-Path "$SchemaFile"))
     { throw (new-object ArgumentException("Le fichier de sch�ma n'existe pas : $SchemaFile"))}

    $reader=$null
	$script:isValid=$true

    try {  
      $readerSettings = New-Object -TypeName System.Xml.XmlReaderSettings 
      $readerSettings.ValidationType = [System.Xml.ValidationType]::Schema 
      $readerSettings.ValidationFlags = [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessInlineSchema -bor 
          [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessSchemaLocation -bor  
          [System.Xml.Schema.XmlSchemaValidationFlags]::ReportValidationWarnings 
         
     [void]$readerSettings.Schemas.Add($targetNamespace,$SchemaFile)
      #A partir d'une string contenant du code, on crée un ScriptBlock afin d'utiliser le scope de ce module.
      #Sinon, dans le cas où on passe un ScriptBlock créé dans un autre module, on utiliserait le scope du module appelant.
     $SBValidation=[System.Management.Automation.ScriptBlock]::Create($ValidationEventHandler)
     $readerSettings.add_ValidationEventHandler( $SBValidation ) 
     $reader = [System.Xml.XmlReader]::Create($FileName, $readerSettings)
     while ($reader.Read()) { }
    } catch {
        #[System.Xml.Schema.XmlSchemaValidationException],[System.Xml.Schema.XmlSchemaException] {
       $script:isValid=$false
       Write-Error ("{0} - {1} " -F $FileName,$_.Exception.Message)
    } finally {
      if ( $DebugPreference -ne "SilentlyContinue")  
       { Write-Debug ("End : {0}" -F $MyInvocation.InvocationName) }         
      if ($reader -ne $null) 
       {
         $readerSettings.remove_ValidationEventHandler($SBValidation)
         $reader.Close() 
       }
       $script:isValid
    } 
  }#process
<#
.SYNOPSIS
    Valide un fichier XML à l'aide d'un schéma XSD. 
     
.DESCRIPTION
    La fonction Test-XML valide un fichier XML à l'aide d'un schéma XSD.
    Lors de la validation chaque erreur rencontrée ne bloque pas le pipeline,
    en revanche une fois l'intégralité des contrôles effectué Test-XML 
    déclenche  une exception.  

.PARAMETER XmlFile
    Nom du fichier XML à valider.     

.PARAMETER SchemaFile
    Nom du fichier XSD utilisé pour la validation.
    
.PARAMETER targetNamespace
    Définit l'URI (Uniform Resource Identifier) de l'espace de noms cible du schéma.    

.PARAMETER ValidationEventHandler
   Scriptblock optionnel exécuté lors d'une erreur de validation.

.EXAMPLE
    Test-Xml -XmlFile "TestNuget.nuspec" -SchemaFile "nuspec.2011.8.xsd" -targetNamespace "http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd"
    Description
    -----------
    Ces instructions valident le contenu du fichier XML "TestNuget.nuspec" à 
    l'aide du schema "nuspec.2011.8.xsd".
    La valeur du paramètre targetNamespace est identique à celle déclarée dans le xsd utilisé.
.
    Les possibles erreurs de validation sont affichées sur la console.
      

.EXAMPLE
    $sbValidation={
  	  param($sender, $eventArgs)
  	     Write-Debug "Erreur validation" 
         $Message=$eventArgs.Exception.InnerException.Message
         if ($null -eq $Message) 
         {$eventArgs.Exception.Message}
       	 $Logger.Error(("[{0}: {1},{2}] {3} - {4} "-F $eventArgs.Severity, $eventArgs.Exception.LineNumber, $eventArgs.Exception.LinePosition,$FileName, $eventArgs.Message)
         $isValid=$false     
    } 
    
    Test-Xml -XmlFile "Configuration.xml" -SchemaFile "Configuration.xsd" -targetNamespace 'http://Mydomain.org/namespace/Configuration.xsd' -ValidationEventHandler $sbValidation

    Description
    -----------
    Ces instructions valident le contenu du fichier XML "Configuration.xml" à 
    l'aide du schema "Configuration.xsd".
.
    Ici les possibles erreurs de validation ne sont pas affichées sur la console, 
    mais dans un fichier de log géré par Log4Net.
    Le code du scriptblock ValidationEventHandler est exécuté lors d'une erreur 
    de validation XSD. On y traite une instance de la classe XmlSchemaValidationException
    qui détaille l'erreur courante. 
    Le scriptblock doit affecter $true à la variable $isValid afin d'informer le code de la fonction Test-Xml d'une erreur de validation.  
 
.INPUTS
     System.String
     Vous pouvez diriger un objet fichier vers Test-XML.

.OUTPUTS
    System.Boolean 
     

.NOTES
    Vous pouvez consulter la documentation Française de la classe 
    XmlSchemaValidationExceptionsur via le lien suivant :
    
     http://msdn.microsoft.com/fr-fr/library/system.xml.schema.xmlschemavalidationexception(v=VS.80).aspx

.COMPONENT
    XML
    XSD
    
.ROLE
    Server Administrator
    Windows Administrator
    Power User
    Developper

.FUNCTIONALITY
    Global

.FORWARDHELPCATEGORY <Function>
#>  
} #Test-Xml
Export-ModuleMember Test-Xml

Function ConvertTo-Object { 
 #Crée une instance C# à partir d'un fichier XML.
 #Attention, cette méthode peut renvoyer un objet null.
 #Par exemple si le fichier xml est mal formé.
 
  [CmdletBinding()]
 param ( 
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string] $FileName,  
     
     [Parameter(Position=2, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string] $SchemaFile,
  
     [Parameter(Position=3,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string] $targetNamespace,     


    [Parameter(Position=4, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
   [Type] $SerializedType, #classe C# sérialisée cf. XSD.

  	[Parameter(Position=5)]
  	[ValidateNotNullOrEmpty()]
  [String] $ValidationEventHandler
 )
 
  if ( $DebugPreference -ne "SilentlyContinue")  
  { Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) }

   #Récupère la valeur dans la liste des paramétres liés. Bug PS v2 ?
 $_EA= $null
 [void]$PSBoundParameters.TryGetValue('ErrorAction',[REF]$_EA)
 if ($null -eq $_EA) 
  { $_EA=$ErrorActionPreference }
 
 #Si le paramètre n'est pas lié on ne le propage pas,
 #sinon PowerShell appliquera les régles de validation  
 if (-not $PSBoundParameters.ContainsKey('ValidationEventHandler') )
  { $isXmlValide= Test-xml -FileName $FileName -Schema $SchemaFile -targetNamespace $targetNamespace -ErrorAction $_EA }
 else
  { $isXmlValide= Test-xml -FileName $FileName -Schema $SchemaFile -targetNamespace $targetNamespace -ValidationEventHandler $ValidationEventHandler -ErrorAction $_EA}

 if ($isXmlValide)
 {
   try {
      #Crée une instance C#, de Type $SerializedType, à partir d'un fichier XML
     $StreamReader = New-Object System.IO.StreamReader($FileName)
     $xSerializer = new-object System.Xml.Serialization.XmlSerializer($SerializedType)
      #Récupère une instance de la classe $SerializedType 
     $xSerializer.Deserialize($StreamReader)
   } Finally { 
      #Libère la ressource
     $StreamReader.Close()
   }
 }
 if ( $DebugPreference -ne "SilentlyContinue")  
   { Write-Debug ("End : {0}" -F $MyInvocation.InvocationName) }
} #ConvertTo-Object
Export-ModuleMember ConvertTo-Object 

Function ConvertTo-XML {
 #Créé un fichier XML à partir d'une instance C#.
 #SerializedType est une classe C# sérialisée cf. XSD. 
  [CmdletBinding()]
 param ( 
     [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
     [ValidateNotNullOrEmpty()]
    $Object,
     [Parameter(Position=1, Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
     [ValidateNotNullOrEmpty()]
    $FileName,
     [Parameter(Position=2, Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
     [ValidateNotNullOrEmpty()]
    [Type] $SerializedType,
     
      [Parameter(Position=3, Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
     [string] $targetNamespace
 )    
   
    if ( $DebugPreference -ne "SilentlyContinue")  
     { Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) }
        
    try {
      $Serializer = new-Object System.Xml.Serialization.XmlSerializer($SerializedType)
      $ns = new-Object System.Xml.Serialization.XmlSerializerNamespaces
       #Avoid : xmlns:xsd xmlns:xsi      
      $ns.Add("", $targetNamespace ) 
       #Create an XmlTextWriter using a FileStream.
      $FileStream = new-Object System.IO.FileStream($Filename, [System.IO.FileMode]::Create);
      $Writer = new-Object System.Xml.XmlTextWriter($FileStream, [System.Text.Encoding]::UTF8)
       #Format le fichier XML
      $Writer.Formatting = [System.Xml.Formatting]::Indented
      $Writer.Indentation = 2
      
       #Serialize using the XmlTextWriter.
      $Serializer.Serialize($Writer, $Object,$ns)
    } Finally { 
       #Libére la ressource
      if ($Writer -ne $null) 
       {$Writer.Close() }
    }
   if ( $DebugPreference -ne "SilentlyContinue")  
   { Write-Debug ("End : {0}" -F $MyInvocation.InvocationName) }
} #ConvertTo-XML
Export-ModuleMember ConvertTo-XML  

function Test-XSDBusinessRules {
 #Valide des régles de gestion qu'un XSD ne peut pas prendre en charge
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
      $Datas,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [System.Collections.IDictionary] $Rules
  ) 
 if ( $DebugPreference -ne "SilentlyContinue")  
   { Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) }
  $ValidationErrors=0
  $Rules.GetEnumerator()|
  Foreach {
    #On lie explicitement le scriptblock dans la portée du module,
    #sinon la variable $Data est recherchée dans la port�e de l'appelant ce 
    #qui génèrerait une erreur : VariableIsUndefined    
    if ((&($MyInvocation.MyCommand.ScriptBlock.Module.NewBoundScriptBlock($_.Value))) -eq $false) 
    {
       Write-Error "Erreur de validation pour la r�gle : $($_.Key)"
       $ValidationErrors++
    } 
  }
   
 if ( $DebugPreference -ne "SilentlyContinue")  
   { Write-Debug ("End : {0}" -F $MyInvocation.InvocationName) }

 return $ValidationErrors -eq 0
} #Test-XSDBusinessRules
Export-ModuleMember Test-XSDBusinessRules

function Set-ParamAlias {
<#
.SYNOPSIS
Support for aliases with parameters binding. Check 'man Set-ParamAlias -Examples' for details.

.DESCRIPTION
Create functions from existing function with pre-binded parameter sets.

.EXAMPLE
Set-ParamAlias -Name l -Command ls -parametersBinding @{Recurse = '$true'; Force = '$true'}

.EXAMPLE
Set-ParamAlias -Name rmrf -Command rm -parametersBinding @{Recurse = '$true'; Force = '$true'}

.NOTES
To check source of the new function 'foo' use $function:foo
Author : https://github.com/vors/ParamAlias
#>  
    param 
    (
        [string]$Name,
        [string]$Command,
        [hashtable]$parametersBinding
    )

    function AddLine($ProxyCommand, $line) {
        $ProxyCommand -replace '(.*)(\$outBuffer = \$null)(.*)', "`$1`$2`n        $line`$3"
    }
    
    $metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command $Command)
    foreach ($b in $parametersBinding.GetEnumerator())
    {
        $null = $metadata.Parameters.Remove($b.Name)
    }
    $ProxyCommand = [System.Management.Automation.ProxyCommand]::Create($metadata)
    foreach ($b in $parametersBinding.GetEnumerator())
    {
        $ProxyCommand = AddLine $ProxyCommand "`$PSBoundParameters['$($b.Name)'] = $($b.Value)"
    }

    iex "function global:$Name { $ProxyCommand }"
}
Export-ModuleMember Set-ParamAlias