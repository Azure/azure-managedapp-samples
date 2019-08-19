# Managed Azure Storage Account (without Ui Definition)

>Note: This sample is for Managed Application in Service Catalog. For Marketplace, please see these instructions:
[**Marketplace Managed Application**](/1-contribution-guide/marketplace.md#transitioning-to-marketplace)

## How to try out this Azure Managed Application

Step 1: Create an ARM template (Use the applianceMainTemplate.json)

Step 2: Create a ManagedApp template (User the mainTemplate.json)

Step 3: Create create ui definition file (Use applianceCreateUiDefinition.json)

Step 4: Zip the files above (Use managed_singlestorageaccount.zip) and upload to public blob storage or upload to public github accout and get the URL.

       e.g. if you have upload to azure storage blob it would look something like  https://<storageaccountname>.blob.core.windows.net/<containername>/managed_singlestorageaccount.zip)
	   Please make sure that you copy paste this URL in browser and see if you see zip file is being downloaded. If this doesn't happen change container's access to "public ReadOnly"

Step 5: Create ManagedApp Definition

1. Get principal id:

	Create user group (From Azure Portal Go to "Azure Active Directory" -> "All groups" -> "New group" ->Create a new group and add other than your azure account in the group)
	Copy paste "Object Id" of the user group and use it as principal id

2. For the demo use roleDefinitionId as 8e3af657-a8ff-443c-a75c-2fe8c4bcb635 (This is built in role definition for the "Owner")

3. Go to Azure Portal (portal.azure.com) -> from the top right corner select "Cloud Shell" and run following commmand:

		az managedapp definition create --display-name HelloManagedAppDef --description "A simple managedApp definition consist of a storage account" -a "<principal id>:8e3af657-a8ff-443c-a75c-2fe8c4bcb635" -l westcentralus --lock-level ReadOnly -g appdefRG -n helloManagedAppDef --package-file-uri https://<storageaccountname>.blob.core.windows.net/<containername>/managed_singlestorageaccount.zip

Step 6: Create ManagedApp

Create managed app using managed app definition created above

	az managedapp create --location westcentralus --kind serviceCatalog --managed-rg-id /subscriptions/<subscription id>/resourceGroups/helloManagedByRG --name helloworldmanagedApp --resource-group helloManagedApp --managedapp-definition-id  "/subscriptions/<subscription id>/resourceGroups/appdefRG/providers/Microsoft.Solutions/applianceDefinitions/helloManagedAppDef"

After this you should be able to see two resource group appdefRG and helloManagedByRG.
appdefRG should have helloManagedAppDef resource
helloManagedByRG resource group should have a storage account 

Now if you have selected other than your storage account in the user group you won't be able to delete or modify any thing on the helloManagedByRG and the storage account underneath. User part of the principal id (user group) an even do all the operation on the storage account