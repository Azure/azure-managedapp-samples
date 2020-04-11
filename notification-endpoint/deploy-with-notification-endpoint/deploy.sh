#!/bin/bash
echo "Running deploy.sh"
# Setup error handling
tempfiles=( )

. variables.conf
zip_file=simpleApp.zip

azlogin() {
    az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
    az account set -s $azure_subscription_id
}

azlogout() {
    az logout
}

cleanup() {
  rm -f "${tempfiles[@]}"
}
trap cleanup 0

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  azlogout

  exit "${code}"
}
trap 'error ${LINENO}' ERR


zip_files() {
    echo "Creating zip file"

    rm $zip_file
    zip $zip_file createUiDefinition.json mainTemplate.json
}

initialize_environment() {
    echo "Checking for resource group $managed_app_resource_group"
    resource_group_exists=$(az group exists --name $managed_app_resource_group)
    if [[ $resource_group_exists == "false" ]]; then
      echo "Creating resource group $managed_app_resource_group"
      az group create --name $managed_app_resource_group --location $resource_group_location
    fi

    echo "Checking for storage account $storage_account"
    storage_account_exists=$(az storage account check-name --name $storage_account --query nameAvailable --output tsv)
    if [[ $storage_account_exists == "false" ]]; then
        echo "Creating storage account $storage_account"
        az storage account create --name $storage_account \
          --location $resource_group_location \
          --kind StorageV2 \
          --resource-group $managed_app_resource_group \
          --sku Standard_LRS
    fi

    echo "Checking for storage container $storage_container"
    storage_connection_string=$(az storage account show-connection-string --name $storage_account --query connectionString --output tsv)
    container_exists=$(az storage container exists --name $storage_container --connection-string $storage_connection_string)

    if [[ $container_exists == "false" ]]; then
        echo "Creating storage container $storage_container"
        az storage container create --name $storage_container --connection-string $storage_connection_string
    fi
}

upload_file() {
    storage_connection_string=$(az storage account show-connection-string --name $storage_account --query connectionString --output tsv)
    blob_exists=$(az storage blob exists --container-name $storage_container --connection-string $storage_connection_string --name $zip_file --output tsv)
    #echo "Blob exists: $blob_exists"
    if [[ blob_exists == "True" ]]; then
        az storage blob delete --container-name $storage_container --connection-string $storage_connection_string --name $zip_file 
    fi

    az storage blob upload -f $zip_file --container-name $storage_container --connection-string $storage_connection_string -n $zip_file
}

create_managed_app() {
    if [[ $(az managedapp definition list --resource-group $managed_app_resource_group --output tsv | grep $managed_app_name | wc -c) != 0 ]]; then
      echo "Deleting managed app definition $managed_app_name"
      az managedapp definition delete --resource-group $managed_app_resource_group --name $managed_app_name
    fi

    package_location="https://$storage_account.blob.core.windows.net/$storage_container/$zip_file"

    parameters_file=$(cat ./managed-app-definition/parameters.json)
    parameters_file=$(echo "${parameters_file/__APPNAME__/$managed_app_name}")
    parameters_file=$(echo "${parameters_file/__LOCATION__/$resource_group_location}")
    parameters_file=$(echo "${parameters_file/__DESCRIPTION__/$managed_app_description}")
    parameters_file=$(echo "${parameters_file/__DISPLAY_NAME__/$managed_app_display_name}")
    parameters_file=$(echo "${parameters_file/__PACKAGE_FILE_URI__/$package_location}")
    parameters_file=$(echo "${parameters_file/__PRINCIPAL_ID__/$managed_app_principal_id}")
    parameters_file=$(echo "${parameters_file/__ROLE_DEFINITION_ID__/$managed_app_role_definition_id}")
    parameters_file=$(echo "${parameters_file/__NOTIFICATION_ENDPOINT__/$managed_app_notification_endpoint}")
    echo $parameters_file > ./parameters.json
    echo "Deploying the managed app definition $managed_app_name"
    az deployment group create -g $managed_app_resource_group --template-file ./managed-app-definition/template.json --parameters @parameters.json
}

zip_files
azlogin
initialize_environment
upload_file
create_managed_app

azlogout
