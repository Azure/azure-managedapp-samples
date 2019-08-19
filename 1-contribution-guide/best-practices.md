# Best practices

## In general..

+ It is a good practice to pass your Managed Application templates and UiDefinition through a JSON linter to remove extraneous commas, parenthesis, brackets that may break the deployment. Try http://jsonlint.com/ or a linter package for your favorite editing environment (Visual Studio Code, Atom, Sublime Text, Visual Studio etc.)
+ It's also a good idea to format your JSON for better readability. You can use a JSON formatter package for your local editor or [format online using this link](https://www.bing.com/search?q=json+formatter).

## The following guidelines are relevant to the Managed Application Resource Manager templates.

* Template parameters should follow **camelCasing**

Example:
````json
	"parameters": {	
		"storagePrefixName": {
			"type": "string",				
			"metadata": {
			"description": "Specify the prefix of the storage account name"
			}
		}
	 }
````

* Minimize parameters whenever possible, this allows for a good "hello world" experience where the user doesn't have to answer a number of questions to complete a deployment.  If you can use a variable or a literal, do so.  
 
* Only provide parameters for:

	* Things that are globally unique (e.g. website name).  These are usually the endpoints the user will interact with post deployment, and need to be aware of. However, in many cases a unique name can be generated automatically by using the [uniqueString()](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/#uniquestring) template language function.
	* Other things a user must know to complete a workflow (e.g. admin user name on a VM)
	* Secrets (e.g. admin password on a VM)
	* Every template **must** include a parameter that specifies the location of the resources, and the *defaultValue* should be *resourceGroup().location*
	* If you must include a parameter, define a defaultValue, unless the parameter is used for a passwords, storage account name prefix, or domain name label
	 
* Every parameter in the template should have the **lower-case description** tag specified using the metadata property. This looks like below

````json
		"parameters": {
		  "storageAccountType": {
		    "type": "string",
		    "metadata": {
		    "description": "The type of the new storage account created to store the VM disks"
		    }
		  }
		}
````

* Template parameters **must not** include *allowedValues* for the following parameter types
	* Vm Size
	* Location


>**Note**:Use *createUiDefinition.json* for this purpose

* When nested templates or scripts are being used, the *mainTemplate.json* **must** include a variable with the uri() function with deployment().properties.templateLink.uri - to automatically resolve the URL for nested templates and scripts. The variable(s) would look similar to this:

````json
		"variables": {
		    "nestedTemplateUrl": "[uri(deployment().properties.templateLink.uri, 'nestedtemplates/mytemplate.json')]",
		    "scriptsUrl": "[uri(deployment().properties.templateLink.uri, 'scripts/myscript.ps1')]"
		}
````

* Template parameters **must not** include default values for parameters that represents the following types
	* Storage Account Name prefix
	* Domain Name Label

>**Note**: Use *createUiDefinition.json* for this purpose, to avoid conflict

* Do not create a parameter for a **storage account name**, but specify it is for **storage account name prefix**. Storage account names need to be lower case and can't contain hyphens (-) in addition to other domain name restrictions. A storage account has a limit of 24 characters. They also need to be globally unique. To prevent any validation issue configure a variables (using the expression **uniqueString** and a static value **storage**). Storage accounts with a common prefix (uniqueString) will not get clustered on the same racks.

Example:

````json	
    "parameters": {
        "storageAccountNamePrefix": {
            "type": "string",
            "metadata": {
                "description": "Prefix for the storage account name"
            }
        }
    },
    "variables": {
        "storageAccountName": "[concat(parameters('storageAccountNamePrefix'), uniqueString('storage'))]"
    },
````


* Passwords **must** be passed into parameters of type **securestring**. Do not specify a defaultValue for a parameter that is used for a password or an SSH key. Passwords must also be passed to **customScriptExtension** using the **commandToExecute** property in protectedSettings.

````json
		 "properties": {
		 	"publisher": "Microsoft.Azure.Extensions",
		 	"type": "CustomScript",
			"version": "2.0",
			"autoUpgradeMinorVersion": true,
		 	"settings": {
		 		"fileUris": [
		 			"[concat(variables('template').assets, '/lamp-app/install_lamp.sh')]"
		 		]
		 	},
		 	"protectedSettings": {
		 		"commandToExecute": "[concat('sh install_lamp.sh ', parameters('mySqlPassword'))]"
		 	}
		 }
````

>**Note**: In order to ensure that secrets which are passed as parameters to virtualMachines/extensions are encrypted, the protectedSettings property of the relevant extensions must be used.
 
* Using tags to add metadata to resources allows you to add additional information about your resources. A good use case for tags is adding metadata to a resource for billing detail purposes.

* You can group variables into complex objects. You can reference a value from a complex object in the format variable.subentry (e.g. `"[variables('storage').storageAccounts.type]"`). Grouping variables helps you keep track of related variables and improves readability of the template.

>**Note**: A complex object cannot contain an expression that references a value from a complex object. Define a separate variable for this purpose.

* If you include Azure management services to your Managed Application, such as Log Analytics, Azure Automation, Backup and Site Recovery, you **must** **not** use additional parameters for these resource locations. Instead, use the following pattern using variables, to place those services in the closest available Azure region to the Resource Group

````json
        "logAnalyticsLocationMap": {
            "eastasia": "southeastasia",
            "southeastasia": "southeastasia",
            "centralus": "westcentralus",
            "eastus": "eastus",
            "eastus2": "eastus",
            "westus": "westcentralus",
            "northcentralus": "westcentralus",
            "southcentralus": "westcentralus",
            "northeurope": "westeurope",
            "westeurope": "westeurope",
            "japanwest": "southeastasia",
            "japaneast": "southeastasia",
            "brazilsouth": "eastus",
            "australiaeast": "australiasoutheast",
            "australiasoutheast": "australiasoutheast",
            "southindia": "southeastasia",
            "centralindia": "southeastasia",
            "westindia": "southeastasia",
            "canadacentral": "eastus",
            "canadaeast": "eastus",
            "uksouth": "westeurope",
            "ukwest": "westeurope",
            "westcentralus": "westcentralus",
            "westus2": "westcentralus",
            "koreacentral": "southeastasia",
            "koreasouth": "southeastasia",
            "eastus2euap": "eastus"
        },
        "logAnalyticsLocation": "[variables('logAnalyticsLocationMap')[parameters('location')]]"
````

>**NOTE**: To find the available Azure regions for a Resource Provider, you can use the following PowerShell cmdlet:
>```Get-AzureRmResourceProvider -ProviderNamespace Microsoft.OperationalInsights | select -ExpandProperty Locations```

The domainNameLabel property for publicIPAddresses **must** be **unique**. domainNameLabel is required to be between 3 and 63 characters long and to follow the rules specified by this regular expression ^[a-z][a-z0-9-]{1,61}[a-z0-9]$. As the uniqueString function will generate a string that is 13 characters long in the example below it is presumed that the dnsPrefixString prefix string has been checked to be no more than 50 characters long and to conform to those rules.

>**Note**: The recommended approach for creating a publicIPAddresses is to use the Microsoft.Network.PublicIpAddressCombo in createUIDefinition.json which will validate the input and make sure the domainNameLabel is available, however if a Managed Application creates new publicIPAddresses in a template without using this element to provide parameters then it should ensure that the domainNameLabel properties used for them are unique

````json	
		 "parameters": {
		 	"dnsPrefixString": {
		 		"type": "string",
		 		"maxLength": 50,
				"metadata": {
		 			"description": "DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error."
		 		}
		 	}
		 },
		 "variables": {
		 	"dnsPrefix": "[concat(parameters('dnsPrefixString'),uniquestring(resourceGroup().id))]"
		 }
````

* For the public endpoints the user will interact with, you **must** provide this information in the **output** section in the templates, so it can be easily retrieved post deployment

````json
	    "outputs": {
	        "vmEndpoint": {
	            "type": "string",
	            "value": "[reference(concat(parameters('vmName'), 'IP')).dnsSettings.fqdn]"
	        }
	    }
````

* If using *nested templates*, ensure you are referencing the outputs from the nested templates into the *mainTemplate.json*

````json
	    "outputs": {
	        "vmEndpoint": {
	            "type": "string",
	            "value": "[reference('nestedDeployment').outputs.vmEndpoint.value]"
	        }
	    }
````

* To set the managed application resource name, you must use ````"applicationResourceName"```` in the ````createUiDefinition.json```` file. If not, the application will automatically get a GUID for this resource.
Example usage:

````json
        "outputs": {
            "vmName": "[steps('appSettings').vmName]",
            "trialOrProduction": "[steps('appSettings').trialOrProd]",
            "userName": "[steps('vmCredentials').adminUsername]",
            "pwd": "[steps('vmCredentials').vmPwd.password]",
            "applicationResourceName": "[steps('appSettings').vmName]"
        }
````
