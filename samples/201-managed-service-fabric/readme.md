# Managed Service Fabric with Azure management services

>Note: This sample is for Managed Application in Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](/1-contribution-guide/marketplace.md#transitioning-to-marketplace)

## Deploy this sample to your Service Catalog

Clicking on the button below, will create the Managed Application definition to a Resource Group in your Azure subscription.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-managedapp-samples%2Fmaster%2Fsamples%2F201-managed-service-fabric%2Fazuredeploy.json)

### Deploy using PowerShell

````powershell
$rgname = "<yourRgName>"
$location = "rgLocation"
$authorization = "<userOrGroupId>:<RBACRoleDefinitionId>"
$uri = "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-service-fabric/managedservicefabric.zip"

New-AzureRmManagedApplicationDefinition -Name "ManagedServiceFabric" `
                                        -ResourceGroupName $rgname `
                                        -DisplayName "Managed Service Fabric" `
                                        -Description "Managed Service Fabric with Azure mgmt." `
                                        -Location $location `
                                        -LockLevel ReadOnly `
                                        -PackageFileUri $uri `
                                        -Authorization $authorization `
                                        -Verbose
````

### Deploy using AzureCLI

Modify the snippet below to deploy Managed Application definition to a Resource Group in your Azure subscription

````azureCLI
az managedapp definition create \
  --name "ManagedServiceFabric" \
  --location <rgLocation> \
  --resource-group <yourRgName> \
  --lock-level ReadOnly \
  --display-name "Managed Service Fabric" \
  --description "Managed Service Fabric with Azure mgmt." \
  --authorizations "<userOrGroupId>:<RBACRoleDefinitionId>" \
  --package-file-uri "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-service-fabric/managedservicefabric.zip"
````

![alt text](images/appliance.png "Azure Managed Application")