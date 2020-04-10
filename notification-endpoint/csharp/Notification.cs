using System;
using Newtonsoft.Json;

namespace Microsoft.IndustryExperiences
{
    public class Notification
    {
        [JsonProperty("eventType")]
        public EventType EventType{get;set;}

        [JsonProperty("applicationId")]
        public string ApplicationId{get;set;}

        [JsonProperty("eventTime")]
        public DateTime EventTime{get;set;}

        [JsonProperty("provisioningState")]
        public ProvisioningState ProvisioningState{get;set;}

        [JsonProperty("applicationDefinitionId")]
        public string ApplicationDefinitionId{get;set;}

        [JsonProperty("error")]
        public NotificationError Error{get;set;}

        [JsonProperty("plan")]
        public PlanInfo Plan{get;set;}
    }
}

