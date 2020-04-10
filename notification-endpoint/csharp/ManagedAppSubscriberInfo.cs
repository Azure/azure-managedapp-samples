using System;
using System.Net;
using Newtonsoft.Json;

namespace Microsoft.IndustryExperiences
{
    public class ManagedAppSubscriberInfo
    {
        public static ManagedAppSubscriberInfo FromNotification(Notification notification)
        {
            var retval = new ManagedAppSubscriberInfo()
            {
                Plan = notification.Plan.Name,
                Product = notification.Plan.Product,
                Version = notification.Plan.Version,
                ApplicationId = notification.ApplicationId,
                InstallTime = notification.EventTime,
                LastUpdateTime = DateTime.MinValue,
            };

            return retval;
        }

        [JsonProperty]
        public string Plan { get; set; }

        [JsonProperty]
        public string Product { get; set; }

        [JsonProperty]
        public string Version { get; set; }

        [JsonIgnore]
        public string ApplicationId
        {
            get;set;
        }

        [JsonProperty(PropertyName = "id")]
        public string Id { get
            {
                return WebUtility.UrlEncode(ApplicationId);
            }
            set
            {
                ApplicationId = WebUtility.UrlDecode(value);
            }
        }

        [JsonProperty]
        public DateTime InstallTime { get; set; }

        [JsonProperty]
        public DateTime LastUpdateTime { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}

