# Deploy a domain joined single VM that is connected to an ER network and registered with Azure Automation DSC pull server

This template allows you to deploy a single VM via appliance, joined to a domain, on an ER network, and register with an Azure Automation DSC pull server.

### User specific updates to project files and creating Appliance Definition

1.&nbsp;ApplianceDefinition.json

* Create an Azure Active Directory user group and get the object id and use it as principal id in appliance definitioncreation.
* Update the appliancedefinition.json file at this line to be the ObjectID of the AAD User group-
    ```
    "principalid" : "ObjectID of your AAD user group",
    ```
* Update the appliancedefinition file at this line to be the path to the ZIP file -  
    ```
    "PackageFileUri": "Path to your ZIP file"
    ```  
    (Refer to the "Create a zip from the following files and upload" section for creating zip file)  

    EG:  "https://{storagename}.blob.core.windows.net/{resourcegroupname}/SingleVMDef.zip"

2.&nbsp; mainTemplate.json

* Update this line to match the where you created the appliance defintion -  
    ```
    "applianceDefinitionId": "Please put the path to your definition in here"
    ```
    EG:  
    /subscriptions/5d68ee96-7272-4664-b122-9xxxxxxxxx/resourceGroups/resourcegroupname/providers/Microsoft.Solutions/applianceDefinitions/singleVM

3.&nbsp; Update paramaters file
* Refer to the mainTemplateExample.parameters.json file included within the project

4.&nbsp; Create a zip from the following files and upload -
* ApplianceCreateUIDefinition.json
* applianceMainTemplate.json
* appliancePackageManifest.json
* createUiDefinition.json

&nbsp;&nbsp;&nbsp;&nbsp; Upload the .zip file to an externally accessible URL such as a Azure storage blob.  
&nbsp;&nbsp;&nbsp;&nbsp; EG:  "https://{storagename}.blob.core.windows.net/{resourcegroupname}/SingleVMDef.zip"

5.&nbsp;Create the Appliance definition
* Example:
```  
armclient.exe PUT /subscriptions/5d68ee96-7272-4664-b122-9xxxxxxxxx/resourceGroups/{resourcegroupname}/providers/Microsoft.Solutions/applianceDefinitions/singleVM?api-version=2016-09-01-preview C:\repos\appliancedefinition.json
```

# Deploying from Powershell #

## Sample script with no warranty ##
```
# User Variables - update this section with your parameters

$subscriptionId = '5d68ee96-7272-4664-b122-xxxxxxx'
$depName ="Single-VM"
$resourceGroupName = "put your RG here"
$resourceGroupLocation = 'West Central US'
$parametersFilePath = "C:\repos\maintemplate.parameters.json"
$templateFilePath = "C:\repos\MainTemplate.json"

# Don't change from here below
# Sign in to azure

Write-Host 'Logging in...'
try{
    $context = Get-AzureRmContext -ErrorAction silentlycontinue
}catch{
}
if($context -eq $null)
{
    Add-AzureRmAccount;
}

# Select subscription

Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Create requested resource group

$exists = Get-AzureRmResourceGroup -Location $resourceGroupLocation | Where-Object {$_.ResourceGroupName -eq  $resourceGroupName}
if (!$exists) {
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRMResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Force
}else {
    Write-Host "Using existing resource group '$resourceGroupName'";
}


# Splatting parameters

$splat = @{'Name'=$depName;
    'ResourceGroupName'=$resourceGroupName;
    'TemplateFile'=$templateFilePath;
    'TemplateParameterFile'= $parametersFilePath
}

Write-Output "Starting Deployment"
New-AzureRmResourceGroupDeployment @splat -verbose
```