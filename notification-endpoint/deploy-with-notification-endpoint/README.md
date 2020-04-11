# Deploy with notification endpoint

If you have implemented [notifications](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/publish-notifications) for your managed application and want to deploy your application to the [Azure Service Catalog](https://docs.microsoft.com/azure/azure-resource-manager/managed-applications/publish-service-catalog-app) from the command line, you need to push an ARM template. This sample does exactly that, including populating the ARM template with your values. 

The sample script is written to be deployed from the command line or from a CI/CD environment. In a CI/CD environment, the contents of variables.conf should be in the environment and configured via the tooling. The values should not be checked into source control.

## Run the script
1. Update [variables.conf](./variables.conf) to values that are appropriate for your Azure environment. 
1. Run deploy.sh from a bash shell. This will work on Linux, macOS, and Windows via [WSL](https://docs.microsoft.com/windows/wsl/about).

## Use the item
You can then test the installation by deploying the managed application via the [portal](https://portal.azure.com/#blade/Microsoft_Azure_Appliance/ManagedAppsHubBlade/publishServiceCatalogAppDefinition).