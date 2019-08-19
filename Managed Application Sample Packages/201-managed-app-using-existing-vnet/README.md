# Managed Application (Trial or Production) into a new or existing virtual network

This Managed Application supports demonstrates how you can create flexible deployment options for customers, using native ARM template language expressions, together with UI elements.

* New or Existing virtual network?

This managed application can either be deployed to a new virtual network the customer specifices, or plug into an existing virtual network.

* Trial or Production?

Let your customer explore the managed application using trial, where they will run an implementation with minimal cost and footprint. If they opt-in for production, they will get the optimized experienc which can have additional costs (vm size, additional resources for HA etc.)

>Note: This sample is for Managed Application in Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](https://docs.microsoft.com/en-us/azure/managed-applications/publish-marketplace-app)

## Deploy this sample to your Service Catalog

### Deploy using Azure Portal

Clicking on the button below, will create the Managed Application definition to a Resource Group in your Azure subscription.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-managedapp-samples%2Fmaster%2Fsamples%2F201-managed-app-using-existing-vnet%2Fazuredeploy.json)

### Deploy using PowerShell

Modify the snippet below to deploy Managed Application definition to a Resource Group in your Azure subscription

````powershell
$rgname = "<yourRgName>"
$location = "<rgLocation>"
$authorization = "<userOrGroupId>:<RBACRoleDefinitionId>"
$uri = "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-app-using-existing-vnet/managedAppVnet.zip"

New-AzureRmManagedApplicationDefinition -Name "ManagedWebApp" `
                                        -ResourceGroupName $rgname `
                                        -DisplayName "Managed Web App" `
                                        -Description "Managed Web App with Azure mgmt" `
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
  --name "ManagedWebApp" \
  --location <rgLocation> \
  --resource-group <yourRgName> \
  --lock-level ReadOnly \
  --display-name "Managed Web Application" \
  --description "Web App with Azure mgmt" \
  --authorizations "<userOrGroupId>:<RBACRoleDefinitionId>" \
  --package-file-uri "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-app-using-existing-vnet/managedAppVnet.zip"
````