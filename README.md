# XMLObject
Convert a xml file to a C# class and vice versa.

Need an xsd file and the dotnet tools xsd.exe.
```powershell
#First step
 cd c:\temp
 nuget install NuGet.Manifest.Schema
 $XsdFile='c:\temp\NuGet.Manifest.Schema.2.0.4\Content\nuspec.2011.8.xsd'
 &"C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\xsd.exe" $XsdFile /Classes /language:CS
 #Compile 'nuspec_2011_8.cs' to  NugetSchemas.dll 
 Add-type -path 'C:\temp\nuspec_2011_8.cs' -OutputAssembly 'C:\temp\NugetSchemas.dll' -OutputType Library -ReferencedAssemblies ([Xml].Assembly.Location)
 
# Second step
$XsdFile='G:\PS\Nuget\nuspec.2011.8.xsd'
$Filename='G:\PS\Nuget\TestNuget.nuspec'  
Add-type -path G:\PS\Nuget\NugetSchemas.dll

Import-Module XMLObject

 #XML file to a C# class
$Nuspec=ConvertTo-Object -Filename $FileName -SchemaFile $xsdFile -targetNamespace "http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd" -SerializedType 'NugetSchemas.package' 
 $Nuspec.metadata.title='Test'
 #A C# class to a XML file 
ConvertTo-XML -Object $Nuspec -Filename $FileName -SerializedType 'NugetSchemas.package' -targetNamespace "http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd"
```
