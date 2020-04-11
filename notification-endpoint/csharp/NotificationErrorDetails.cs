using Newtonsoft.Json;

namespace Microsoft.IndustryExperiences
{
    public class NotificationErrorDetails
    {
        [JsonProperty("code")]
        public string Code{get;set;}

        [JsonProperty("message")]
        public string Message{get;set;}        
    }
}

