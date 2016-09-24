
if(! (Test-Path variable:XMLObjectVcs))
{
  throw "The project configuration is required, see the 'XMLObject_ProjectProfile.ps1' script." 
}
$ModuleVersion=(Import-ManifestData "$XMLObjectVcs\XMLObject.psd1").ModuleVersion

$Result=nuspec 'XMLObject' $ModuleVersion {
   properties @{
        Authors='Dardenne Laurent'
        Description="Management of class linked to an XSD schema."
        title='XMLObject'
        summary='Transforms an XML file into a class C# and vice versa.'
        copyright='Copyleft'
        language='en-US'
        licenseUrl='https://creativecommons.org/licenses/by-nc-sa/4.0/'
        projectUrl='https://github.com/LaurentDardenne/XMLObject'
        iconUrl='https://github.com/LaurentDardenne/XMLObject/blob/master/icon/XMLObjects.png'
        releaseNotes="$(Get-Content "$XMLObjectVcs\CHANGELOG.md" -raw)"
        tags='XML XSD'
   }
   
   files {
    file -src "G:\PS\XMLObject\XMLObject.psd1"
    file -src "G:\PS\XMLObject\XMLObject.psm1"
   }
}

$Result|
  Push-nupkg -Path $XmlObjectDelivery -Source 'https://www.myget.org/F/ottomatt/api/v2/package'
