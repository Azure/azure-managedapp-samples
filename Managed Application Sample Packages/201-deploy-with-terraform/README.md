# Deploy with Terraform

## Use case
You have a Terraform template which you would like to use to deploy your managed application. You can use this project to understand which pieces of the deployment must move to the ARM template and which pieces may stay in Terraform. The example here deploys an empty resource group. The template is optimized for a demonstration and deploys everything for a basic virtual network except for the virtual machine(s). This item builds off of [101-minimal-template](../101-minimal-template)

## Deploy this sample to your Service Catalog

### Deploy using Azure Portal

Clicking on the button below, will create the Managed Application definition to a Resource Group in your Azure subscription.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-managedapp-samples%2Fmaster%2FManaged%2520Application%2520Sample%2520Packages%2F201-deploy-with-terraform%2Fazuredeploy.json)

### Deploy using PowerShell

Modify the snippet below to deploy Managed Application definition to a Resource Group in your Azure subscription

````powershell
$rgname = "<yourRgName>"
$location = "<rgLocation>"
$authorization = "<userOrGroupId>:<RBACRoleDefinitionId>"
$uri = "https://raw.githubusercontent.com/scseely/azure-managedapp-samples/master/Managed Application Sample Packages/201-deploy-with-terraform/deploy-with-terraform.zip"

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
  --package-file-uri "https://raw.githubusercontent.com/scseely/azure-managedapp-samples/master/Managed Application Sample Packages/201-deploy-with-terraform/deploy-with-terraform.zip"
````

### Run the Terraform template

1. Update [variables.conf](./variables.conf) for your environment. The script does assume that you have created a Service Principal for managing your Managed Application or Service Catalog installations. Use the same identity as you used for the Authorization parameter for the Powershell call or teh authorizations parameter in the AzureCLI.

1. Run [deploy.sh](./deploy.sh) from a bash shell. This will also work under [WSL](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install).