# Powershell Script to deploy a ManagedApp

When working with ManagedApps, you might find yourself publishing over and over the definition till you get it as you want it; in order to simplify the process, this script helps you to deploy the definition and creates a storage account/blob (if it doesn't exists) according to the requirements.

## The Files

1.&nbsp;Public-ManagedApp.ps1

*Note: CreateUiDefinition.json and mainTemplate.json must exists in the same location as the ps1.*

Powershell script to deploy the managed app. It will create, if it doesn't exist, a Storage Account and a container (with Blob security) in order to deploy the ManagedApp definition. Parameters:

* SubscriptionId: GUID with the subscription you want to deploy the definition.
* Location: Azure DC where you want to publish the managed app. This is where the resource group will be created. (Default: westcentralus)
* ResourceGroupName: Self-explanatory
* Name: ManagedApp Name
* DisplayName: ManagedApp Display Name
* Description: ManagedApp Description
* PrincipalId: Azure AD GUID of the group/user you want to grant access to the managed resource group
* RoleDefinitionId: Azure RBAC role to be granted to PrincipalId in the managed resource group (Default: "8e3af657-a8ff-443c-a75c-2fe8c4bcb635" => Owner)
* StorageAccountName: Self-explanatory
* StorageContainerName: Self-explanatory
* LockLevel: User access level to the managed resource group. (Default: ReadOnly)

2.&nbsp; managedAppTemplate.json

This file is required in the same location as the PS1 since it will be used to do the actual deployment to Azure