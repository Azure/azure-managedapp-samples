# Minimal Managed Application

## Use case
You may have an application which you would like to deploy using the benefits of managed applications
via the Service Catalog or Azure Marketplace. Your existing deployment consists of something like the 
following:
* [az CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) 
* [Azure PowerShell](https://docs.microsoft.com/powershell/azure/)
* [Terraform](https://www.terraform.io/docs/providers/azurerm/index.html)
* Or something else...

Instead of writing an ARM template, you want to get the simplest thing working which let's you create a resource group and nothing more. The UI template collects one parameter (though you can collect more) and feeds that to the ARM template. These parameters can be inspected via the Azure Portal, az cli, or PowerShell. You can then use this to see which features of your chosen feature set do and do not work post install. For example, one can deploy Azure Kubernetes Service via the ARM template, but this same action will fail when executed as a contributor or owner to the managed resource group. This testing will inform you which items to move to the ARM template for your managed application. 

An example including a Terraform template is in [201-deploy-with-terraform](../201-deploy-with-terraform).

>Note: This sample is for a minimal Managed Application in the Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](https://docs.microsoft.com/azure/managed-applications/publish-marketplace-app)

## Deploy this sample to your Service Catalog

### Deploy using Azure Portal

Clicking on the button below, will create the Managed Application definition to a Resource Group in your Azure subscription.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-managedapp-samples%2Fmaster%2FManaged%2520Application%2520Sample%2520Packages%2F101-minimal-template%2Fazuredeploy.json)

### Deploy using PowerShell

Modify the snippet below to deploy Managed Application definition to a Resource Group in your Azure subscription

````powershell
$rgname = "<yourRgName>"
$location = "<rgLocation>"
$authorization = "<userOrGroupId>:<RBACRoleDefinitionId>"
$uri = "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/Managed Application Sample Packages/101-minimal-template/minimal-template.zip"

New-AzureRmManagedApplicationDefinition -Name "MinimalTemplate" `
                                        -ResourceGroupName $rgname `
                                        -DisplayName "Minimal Template" `
                                        -Description "A minimal template" `
                                        -Location $location `
                                        -LockLevel ReadOnly `
                                        -PackageFileUri $uri `
                                        -Authorization $authorization `
                                        -Verbose
````

### Deploy using AzureCLI

Modify the snippet below to deploy the Managed Application definition to a Resource Group in your Azure subscription.

````azureCLI
az managedapp definition create \
  --name "MinimalTemplate" \
  --location <rgLocation> \
  --resource-group <yourRgName> \
  --lock-level ReadOnly \
  --display-name "Minimal Template" \
  --description "A minimal template" \
  --authorizations "<userOrGroupId>:<RBACRoleDefinitionId>" \
  --package-file-uri "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/Managed Application Sample Packages/101-minimal-template/minimal-template.zip"
````