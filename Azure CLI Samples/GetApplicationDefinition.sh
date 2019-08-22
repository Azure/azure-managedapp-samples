#!/bin/bash

#counter for iterating through definitions
counter=0

#Get all applicationDefinitions names at subscription scope
for scdn in $(az resource list --resource-type "Microsoft.Solutions/applicationDefinitions" --output tsv --query [].name); do 

#get resource group of the definition
scdrg=$(az resource list --resource-type "Microsoft.Solutions/applicationDefinitions" --output tsv --query [$counter].resourceGroup)

#get the path to the mainTemplate file
uriPath=$(az managedapp definition show --name $scdn --resource-group $scdrg --query artifacts[0].uri)

#output the path to the Service Catalog Definition
az managedapp definition show --name $scdn --resource-group $scdrg --query id

#output the uri to the ARM template the service catalog definition contains
echo "${uriPath/applicationResourceTemplate/mainTemplate}"	
echo
let counter+=1
done