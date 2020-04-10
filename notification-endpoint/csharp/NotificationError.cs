using Newtonsoft.Json;

namespace Microsoft.IndustryExperiences
{
    public class NotificationError
    {
        [JsonProperty("code")]
        public string Code{get;set;}

        [JsonProperty("message")]
        public string Message{get;set;}

        [JsonProperty("details")]
        public NotificationErrorDetails[] Details{get;set;}
    }
}

