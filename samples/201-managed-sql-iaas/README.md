# Managed SQL 2017 IaaS with automated patching and backup

>Note: This sample is for Managed Application in Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](https://docs.microsoft.com/en-us/azure/managed-applications/publish-marketplace-app)

## Deploy this sample to your Service Catalog

### Deploy using Azure Portal

Clicking on the button below, will create the Managed Application definition to a Resource Group in your Azure subscription.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-managedapp-samples%2Fmaster%2Fsamples%2F201-managed-sql-iaas%2Fazuredeploy.json)

### Deploy using PowerShell

Modify the snippet below to deploy Managed Application definition to a Resource Group in your Azure subscription

````powershell
$rgname = "<yourRgName>"
$location = "<rgLocation>"
$authorization = "<userOrGroupId>:<RBACRoleDefinitionId>"
$uri = "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-sql-iaas/managedSql.zip"

New-AzureRmManagedApplicationDefinition -Name "ManagedSql" `
                                        -ResourceGroupName $rgname `
                                        -DisplayName "Managed SQL IaaS" `
                                        -Description "Managed SQL IaaS with automated patching and backup" `
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
  --name "ManagedSql" \
  --location <rgLocation> \
  --resource-group <yourRgName> \
  --lock-level ReadOnly \
  --display-name "Managed SQL IaaS" \
  --description "Managed SQL IaaS with automated patching and backup" \
  --authorizations "<userOrGroupId>:<RBACRoleDefinitionId>" \
  --package-file-uri "https://raw.githubusercontent.com/Azure/azure-managedapp-samples/master/samples/201-managed-sql-iaas/managedSql.zip"
````