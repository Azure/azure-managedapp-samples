# Managed Web Application (IaaS) with Azure management services and Key Vault

>Note: This sample is for Managed Application in Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](https://docs.microsoft.com/en-us/azure/managed-applications/publish-marketplace-app)

## Deploy this sample to your Service Catalog

This sample needs to be downloaded and modified, before initialized to your Service Catalog.
As this sample is using an existing KeyVault and secret, you must update the *id* and *secretName*:

````json
                    "administratorLoginPassword": {
                        "reference": {
                            "keyVault": {
                                "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.KeyVault/vaults/{keyVaultName}"
                            },
                            "secretName": "appsecret"
                        }
                    },
````

Once completed, you can put the templates into a .zip, upload to your storage account, and initialize the Managed Application offering.

## Post-requirements

Grant the Appliance Resource Provider access to your KeyVault resource, referenced in the template