#
# Manifeste de module pour le module "XMLObject"
#
# Généré le : 10/01/2011
#
@{
  Author="Laurent Dardenne"
  Copyright="CopyLeft"
  Description="Module de gestion des fichiers XML et XSD"
  
  GUID = 'a7f98809-b178-45fd-bca1-69a8a51352f2'
  ModuleToProcess="XMLObject.psm1" 
  
  ModuleVersion="1.1.0"
  CLRVersion="2.0"
  PowerShellVersion="2.0"   

  FileList = 'XMLObject.psm1'
  
  FunctionsToExport = @(
     'Test-Xml',
     'Test-XSDBusinessRules',
     'Set-ParamAlias',
     'ConvertTo-Object',
     'ConvertTo-XML'
  )
  # Private data to pass to the module specified in RootModule/ModuleToProcess. 
  PrivateData = @{
    
     # PSData data to pass to the Publish-Module cmdlet
    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        #Tags = @(')

        # A URL to the license for this module.
        LicenseUri = 'https://creativecommons.org/licenses/by-nc-sa/4.0'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/LaurentDardenne/Nuspec'

        # A URL to an icon representing this module.
        IconUri = 'https://github.com/LaurentDardenne/MeasureLocalizedData/blob/master/Icon/Nuspec.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'Initial version.'
    } # End of PSData hashtable
} # End of PrivateData hashtable

}
