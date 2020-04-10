#!/bin/bash
echo "Running deploy.sh"
# Setup error handling
tempfiles=( )
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
#  az logout

  exit "${code}"
}
trap 'error ${LINENO}' ERR

# so repeat runs work, removing terraform state.
# in production, you'd want one terraform state location per deployment
if [[  -f "terraform.tfstate" ]]; then
    rm terraform.tfstate
fi
if [[  -f "terraform.tfstate.backup" ]]; then
    rm terraform.tfstate.backup
fi

# Load the config 
echo "Loading config"
. variables.conf
azure_subscription_id=$(IFS='/' read -r -a parts <<< \
                          "$managed_app_id" \
                          && echo "${parts[2]}")
az login --service-principal -u $service_principal_id -p $service_principal_secret --tenant $azure_ad_tenant_id
az account set -s $azure_subscription_id

# Login as the service principal
resource_group_location=$(az managedapp show --ids $managed_app_id \
                          --query location --output tsv)

managed_resource_group_id=$(az managedapp show --ids $managed_app_id \
                          --query managedResourceGroupId --output tsv)

managed_resource_group_name=$(IFS='/' read -r -a parts <<< \
                          "$managed_resource_group_id" \
                          && echo "${parts[-1]}")
echo $managed_resource_group_name

# Copy over the local azurerm provider
# cp $GOPATH/bin/terraform-provider-azurerm  ./.terraform/plugins/linux_amd64/terraform-provider-azurerm_v2.0.0_x5

echo "Checking terraform"
if [[ ! -d ".terraform" ]]; then
    terraform init
fi
random_end=$(head /dev/urandom | tr -dc a-z | head -c 5)
base_name=$(echo $base_name)$(echo $random_end)
stg_account_name=$(echo $base_name)stg
echo $base_name
terraform apply -auto-approve -var="azure_ad_tenant_id=$azure_ad_tenant_id" \
                              -var="azure_subscription_id=$azure_subscription_id" \
                              -var="service_principal_secret=$service_principal_secret" \
                              -var="service_principal_id=$service_principal_client_id" \
                              -var="resource_group_name=$managed_resource_group_name" \
                              -var="base_name=$base_name" \
                              -var="location=$resource_group_location" \
                              -var="stg_account_name=$stg_account_name"

#az logout