# Deploy a domain joined single VM that is connected to an ER network and registered with Azure Automation DSC pull server

This template allows you to deploy a single VM via appliance, joined to a domain, on an ER network, and register with an Azure Automation DSC pull server.

### User specific updates to project files ###

**ApplianceDefinition.json**

1. Create an Azure Active Directory user group and get the object id and use it as principal id in appliance definition creation. This will go in the appliancedefinition.json file in this line:                 "principalId" : "ObjectID of your AAD user group",
2.  Update this line to be the path to the ZIP file:         "PackageFileUri": "Path to your ZIP file", (publish all the files as the last step as you will be making updates)
3. Create the Appliance definition.  Example syntax: 
armclient.exe PUT /subscriptions/5d68ee96-7272-4664-b122-9xxxxxxxxx/resourceGroups/tdrapp48/providers/Microsoft.Solutions/applianceDefinitions/singleVM?api-version=2016-09-01-preview @C:\repos\appliancedefinition.json

**mainTemplate.json**
1. Update this line to match the where you created the appliance defintion. 
        "applianceDefinitionId": "Please put the path to your definition in here",
        Example from above would be: /subscriptions/5d68ee96-7272-4664-b122-9xxxxxxxxx/resourceGroups/tdrapp48/providers/Microsoft.Solutions/applianceDefinitions/singleVM

**Upload modified files**
1. Load all json files into a ZIP file (except ApplianceDefinition.json) and publish to an externally accessible URL such as a Azure storage blob. 

### Deploying from Powershell ###

#Sample script with no warranty
#Variables - update this section with your parameters
$subscriptionId = '5d68ee96-7272-4664-b122-xxxxxxx'
$depName ="Single-VM"
$resourceGroupName = "put your RG here"
$resourceGroupLocation = 'West Central US'
$parametersFilePath = "C:\repos\maintemplate.parameters.json"
$templateFilePath = "C:\repos\MainTemplate.json"

#Don't change from here below
# sign in
Write-Host 'Logging in...'
try{
$context = Get-AzureRmContext -ErrorAction silentlycontinue
}
catch{}
if($context -eq $null)
{
	Add-AzureRmAccount;
}
# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;


# Create requested resource group
$exists = Get-AzureRmResourceGroup -Location $resourceGroupLocation | Where-Object {$_.ResourceGroupName -eq $resourceGroupName}
if (!$exists) {
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRMResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Force
}else {
    Write-Host "Using existing resource group '$resourceGroupName'";
}


#Splatting parameters
$splat = @{'Name'=$depName;
        'ResourceGroupName'=$resourceGroupName;
        'TemplateFile'=$templateFilePath;
        'TemplateParameterFile'= $parametersFilePath
          }

Write-Output "Starting Deployment"
New-AzureRmResourceGroupDeployment @splat -verbose

 