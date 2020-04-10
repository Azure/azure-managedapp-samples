using Newtonsoft.Json;

namespace Microsoft.IndustryExperiences
{
    public class PlanInfo
    {   
        [JsonProperty("name")]
        public string Name{get;set;}

        [JsonProperty("product")]
        public string Product{get;set;}

        [JsonProperty("publisher")]
        public string Publisher{get;set;}

        [JsonProperty("version")]
        public string Version {get;set;}
    }
}

