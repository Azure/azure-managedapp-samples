# Transitioning to Marketplace Managed Application

When you have created and verified your Managed Application for Service Catalog, and want to transition to Azure Marketplace with your offering, you need to make the following changes to the *mainTemplate.json* file.

````json
"variables": {
    "applianceName": "ManagedApp",
    "managedRgId": "[concat(resourceGroup().id,'-',variables('applianceName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Solutions/appliances",
      "name": "[variables('applianceName')]",
      "apiVersion": "2016-09-01-preview",
      "location": "[resourceGroup().location]",
      "kind": "marketplace",
      "properties": {
        "managedResourceGroupId": "[variables('managedRgId')]",
        "publisherPackageId": "yourcompany.offerId-previewSkuId.1.0.0",
        "parameters": {
			...
		}
````

The example above shows that:
1. ````"kind": "marketplace"```` is declared at the resource property

2. ````"publisherPackageId": "yourCompany.offerId-previewSkuId.1.0.0"```` reflects the offer you make in the [Cloud Partner portal](https://cloudpartner.azure.com)

[Visit our public documentaiton for more details on how to publish to Marketplace](https://docs.microsoft.com/en-us/azure/azure-resource-manager/managed-application-author-marketplace)