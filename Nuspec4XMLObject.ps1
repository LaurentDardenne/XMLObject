
nuspec 'XMLObject' '1.0.0.0' {
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
        releaseNotes=''
        tags=$null
   }
   
   files {
    file -src "G:\PS\XMLObject\XMLObject.psd1"
    file -src "G:\PS\XMLObject\XMLObject.psm1"
   }
}|Save-Nuspec -FileName "$XMLObjectDelivery\XMLObject.nuspec" -nobom
