#!/bin/bash

#Get all applicationDefinitions at subscription scope
resourceDefinitions=$(az resource list --resource-type "Microsoft.Solutions/applicationDefinitions" --output tsv --query [].resourceGroup)

for resourceDefinition in $resourceDefinitions
do

  #Get template link for each application definition  
  applicationDefinitions=$(az managedapp definition list --resource-group $resourceDefinition --query [].artifacts[0].uri) 
	
	for applicationDefinition in $appDefinitions
	do
	  echo "${appDefinition/applicationResourceTemplate/mainTemplate}"	 
	done
   
done