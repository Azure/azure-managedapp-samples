## Best practices

#### Best practices for Resource Manger templates for Azure Managed Application

+ It is a good practice to pass your Managed Application templates and UiDefinition through a JSON linter to remove extraneous commas, parenthesis, brackets that may break the deployment. Try http://jsonlint.com/ or a linter package for your favorite editing environment (Visual Studio Code, Atom, Sublime Text, Visual Studio etc.)
+ It's also a good idea to format your JSON for better readability. You can use a JSON formatter package for your local editor or [format online using this link](https://www.bing.com/search?q=json+formatter).

### The following guidelines are relevant to the Managed Application Resource Manager templates.

* Template parameters should follow **camelCasing**.
1. Minimize parameters whenever possible, this allows for a good "hello world" experience where the user doesn't have to answer a number of questions to complete a deployment.  If you can use a variable or a literal, do so.  
 
	+ Only provide parameters for:

	 + Things that are globally unique (e.g. website name).  These are usually the endpoints the user will interact with post deployment, and need to be aware of. However, in many cases a unique name can be generated automatically by using the [uniqueString()](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/#uniquestring) template language function.
	 + Other things a user must know to complete a workflow (e.g. admin user name on a VM)
	 + Secrets (e.g. admin password on a VM)
	 + Every template **must** include a parameter that specifies the location of the resources, and the *defaultValue* should be *resourceGroup().location*
	 + If you must include a parameter, define a defaultValue, unless the parameter is used for a password
	 
+  Every parameter in the template should have the **lower-case description** tag specified using the metadata property. This looks like below


		"parameters": {
		  "storageAccountType": {
		    "type": "string",
		    "metadata": {
		    "description": "The type of the new storage account created to store the VM disks"
		    }
		  }
		}

+	Template parameters **must not** include *allowedValues* for the following parameter types
	+	Vm Size
	+	Location


+ Use *applianceCreateUiDefinition.json* for this purpose
4. When nested templates or scripts are being used, the *applianceMainTemplate.json* **must** include a variable with the uri() function with deployment().properties.templateLink.uri - to automatically resolve the URL for nested templates and scripts. The variable(s) would look similar to this:

	"variables": {
	    "nestedTemplateUrl": "[uri(deployment().properties.templateLink.uri, 'nestedtemplates/mytemplate.json')]",
	    "scriptsUrl": "[uri(deployment().properties.templateLink.uri, 'scripts/myscript.ps1')]"
	}

+ Template parameters **must not** include default values for parameters that represents the following types
	+ Storage Account Name
	+ Domain Name Labe

+ Use *applianceCreateUiDefinition.json* for this purpose, to avoid conflict

1. Do not create a parameter for a **storage account name**. Storage account names need to be lower case and can't contain hyphens (-) in addition to other domain name restrictions. A storage account has a limit of 24 characters. They also need to be globally unique. To prevent any validation issue configure a variables (using the expression **uniqueString** and a static value **storage**). Storage accounts with a common prefix (uniqueString) will not get clustered on the same racks.
	
 ```
 "variables": {
 	"storageAccountName": "[concat(uniqueString(resourceGroup().id),'storage')]"
 }
 ```
 
 >Note: Templates should consider storage accounts throughput constraints and deploy across multiple storage accounts where necessary. Templates should distribute virtual machine disks across multiple storage accounts to avoid platform throttling.

+  If you use a **public endpoint** in your template (e.g. blob storage public endpoint), **do not hardcode** the namespace. Use the **reference** function to retrieve the namespace dynamically. This allows you to deploy the template to different public namespace environments, without the requirement to change the endpoint in the template manually. Use the following reference to specify the osDisk. Define a variable for the storageAccountName (as specified in the previous example), a variable for the vmStorageAccountContainerName and a variable for the OSDiskName. Set the apiVersion to the same version you are using for the storageAccount in your template.

		
		"osDisk": {"name": "osdisk","vhd": {"uri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/', 
		variables('storageAccountName')), '2015-06-15').primaryEndpoints.blob, variables('vmStorageAccountContainerName'),
		'/',variables('OSDiskName'),'.vhd')]"}}


+  If you have other values in your template configured with a public namespace, change these to reflect the same reference function. For example the storageUri property of the virtual machine diagnosticsProfile. Set the apiVersion to the same version you are using for the corresponding resource in your template.


		"diagnosticsProfile": {"bootDiagnostics": {"enabled": "true","storageUri":
		"[reference(concat('Microsoft.Storage/storageAccounts/', variables('storageAccountName')), 
		'2015-06-15').primaryEndpoints.blob]"}}

 
+  **Passwords** must be passed into parameters of type **securestring**. Do not specify a defaultValue for a parameter that is used for a password or an SSH key. Passwords must also be passed to **customScriptExtension** using the **commandToExecute** property in protectedSettings.


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

 >Note: In order to ensure that secrets which are passed as parameters to virtualMachines/extensions are encrypted, the protectedSettings property of the relevant extensions must be used.
 
+  Using tags to add metadata to resources allows you to add additional information about your resources. A good use case for tags is adding metadata to a resource for billing detail purposes. 

+  You can group variables into complex objects. You can reference a value from a complex object in the format variable.subentry (e.g. `"[variables('storage').storageAccounts.type]"`). Grouping variables helps you keep track of related variables and improves readability of the template.

 ```
 "variables": {
 	"storage": {
 		"storageAccounts": {
 		"name": "[concat(uniqueString(resourceGroup().id),'storage')]",
 		"type": "Standard_LRS"
 		}
 	}
 },
 "resources": [
	 {
	 "type": "Microsoft.Storage/storageAccounts",
	 "name": "[variables('storage').storageAccounts.name]",
	 "apiVersion": "[2015-06-15]",
	 "location": "[resourceGroup().location]",
	 "properties": {
	 	"accountType": "[variables('storage').storageAccounts.type]"
	 }
 	 }
 ]
 ```

 Note: A complex object cannot contain an expression that references a value from a complex object. Define a separate variable for this purpose.

13. The **domainNameLabel** property for publicIPAddresses must be **unique**. domainNameLabel is required to be between 3 and 63 characters long and to follow the rules specified by this regular expression ^[a-z][a-z0-9-]{1,61}[a-z0-9]$. As the uniqueString function will generate a string that is 13 characters long in the example below it is presumed that the dnsPrefixString prefix string has been checked to be no more than 50 characters long and to conform to those rules.

	
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


+  If a template creates any new **publicIPAddresses** then it should have an **output** section that provides details of the IP address and fully qualified domain created to easily retrieve these details after deployment. 

		 "outputs": {
		 "fqdn": {
		 	"value": "[reference(resourceId('Microsoft.Network/publicIPAddresses',parameters('publicIPAddressName')),'2016-10-01').dnsSettings.fqdn]",
		 	"type": "string"
		 },
		 "ipaddress": {
		 	"value": "[reference(resourceId('Microsoft.Network/publicIPAddresses',parameters('publicIPAddressName')),'2016-10-01').dnsSettings.fqdn]",
		  	"type": "string"
		 }
		}


+  publicIPAddresses assigned to a Virtual Machine instance should only be used when these are required for application purposes, for connectivity to the resources for debug, management or administrative purposes either inboundNatRules, virtualNetworkGateways or a jumpbox should be used.


### Nested templates design for more advanced scenarios

When you decide to decompose your template design into multiple nested templates, the following guidelines will help to standardize the design. These guidelines are based on the [best practices for designing Azure Resource Manager templates](https://azure.microsoft.com/en-us/documentation/articles/best-practices-resource-manager-design-templates/) documentation.
For this guidance a deployment of a SharePoint farm is used as an example. The SharePoint farm consists of multiple tiers. Each tier can be created with high availability. The recommended design consists of the following templates.

+ **Main template** (azuredeploy.json). Used for the input parameters.
+ **Shared resources template**. Deploys the shared resources that all other resources use (e.g. virtual network, availability sets). The expression dependsOn enforces that this template is deployed before the other templates.
+ **Optional resources template**. Conditionally deploys resources based on a parameter (e.g. a jumpbox)
+ **Member resources templates**. Each within an application tier within has its own configuration. Within a tier different instance types can be defined. (e.g. first instance creates a new cluster, additional instances are added to the existing cluster). Each instance type will have its own deployment template.
+ **Scripts**. Widely reusable scripts are applicable for each instance type (e.g. initialize and format additional disks). Custom scripts are created for specific customization purpose are different per instance type.

![alt text](images/nestedTemplateDesign.png "Nested templates design")
 
The **main template** is stored in the **root** of the folder, the **other templates** are stored in the **nestedtemplates** folder. The scripts are stored in the **scripts** folder.
