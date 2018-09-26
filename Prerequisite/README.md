# Prerequisite

If you have an existing environment, use the sample Resource Graph queries to understand - and determine the policies needed for the target Azure Architecture.

<placeholder>

Get an overview of all resources within the Azure tenant

>Note: This assumes the signed in user has the appropriate permission at scope, across subscriptions.

````
az graph query --q "summarize count()"
```` 

Get an overview of all resource types, summarized by count

````
az graph query --q "summarize count() by tostring(type)"
````

Get an overview of the top 10 regions with most resources

````
````

Get an overview of Linux vs Windows usage

````
az graph query --q "where type =~ 'Microsoft.Compute/virtualMachines' | extend os = properties.storageProfile.osDisk.osType | summarize count() by tostring(os)"
````

Get an understanding of usage - and distribution of tags

````
az graph query --q "where tags != '' | project name, type, tags, resourceGroups"
````

See if any Azure mgmt services are deployed

````
az graph query --q "where type =~ 'Microsoft.OperationalInsights/workspaces' or type =~ 'Microsoft.Automation/automationAccounts' or type =~ 'Microsoft.RecoveryServices/vaults' | project name, location, resourceGroup, type, subscriptionId"
````

