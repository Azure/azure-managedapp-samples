using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Cosmos;

namespace Microsoft.IndustryExperiences
{

    public static class ManagedAppWebHook
    {
        // The Azure Cosmos DB endpoint for running this sample.
        private static readonly string EndpointUri = Environment.GetEnvironmentVariable("CosmosEndpointUri");
        // The primary key for the Azure Cosmos account.
        private static readonly string PrimaryKey = Environment.GetEnvironmentVariable("CosmosKey");

        private static readonly string DatabaseId = "ManagedApps";
        private static readonly string ContainerId = "Subscribers";

        [FunctionName("resource")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            ActionResult result = new OkResult();

            try
            {
                var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                log.LogInformation(requestBody);
                var data = JsonConvert.DeserializeObject<Notification>(requestBody);

                log.LogInformation(requestBody);
                switch(data.ProvisioningState){
                    case ProvisioningState.Accepted:
                        break;
                    case ProvisioningState.Failed:
                        break;
                    case ProvisioningState.Deleted:
                        await RemoveSubscriber(data, log);
                        break;
                    case ProvisioningState.Succeeded:
                        await SaveSubscriberAsync(data, log);
                        break;
                }
            }
            catch(Exception ex)
            {   
                log.LogError(-1, ex, "Exception occurred during processing");
                result = new StatusCodeResult(500);
            }

            return result;
        }

        private static async Task<Container> GetContainerAsync()
        {
            var client = new CosmosClient(EndpointUri, PrimaryKey);
            Database database = await client.CreateDatabaseIfNotExistsAsync(DatabaseId);
            Container container = await database.CreateContainerIfNotExistsAsync(
                ContainerId, $"/{nameof(ManagedAppSubscriberInfo.Product)}");

            return container;
        }

        private static async Task<bool> RemoveSubscriber(Notification data, ILogger log)
        {
            try
            {
                var container = await GetContainerAsync();
                var record = ManagedAppSubscriberInfo.FromNotification(data);
                await container.DeleteItemAsync<ManagedAppSubscriberInfo>(record.Id, new PartitionKey(record.Product));

                return true;
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Issue saving subscription info");
                return false;
            }
        }

        private static async Task<ManagedAppSubscriberInfo> SaveSubscriberAsync(Notification data, ILogger log)
        {
            try
            {
                var container = await GetContainerAsync();
                var record = ManagedAppSubscriberInfo.FromNotification(data);
                await container.UpsertItemAsync<ManagedAppSubscriberInfo>(record, new PartitionKey(record.Product));
                return record;
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Issue saving subscription info");
                return null;
            }
        }
    }
}

