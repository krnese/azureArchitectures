## Replace the variables below to reflect your environment(s)
# Defining global deployment variables
 
$mgmtSubscriptionId = "09e8ed26-7d8b-4678-a179-cfca8a0cef5c"
$userSubscriptionId = "155c4768-b71c-4e4b-a990-97407f43edda"
 
$mgmtSubscriptionTemplateUri = "https://raw.githubusercontent.com/krnese/azureArchitectures/master/Templates/Mgmt/mgmtSubscription.json"
$userSubscriptionTemplateUri = "https://raw.githubusercontent.com/krnese/azureArchitectures/master/Templates/User/userSubscription.json"
 
# Set subscription context to mgmt subscription
 
Select-AzureRmSubscription -SubscriptionId $mgmtSubscription
 
# Defining variables for mgmt subscription deployment
 
$mgmtRgName = "sharedMgmt"
$rgsLocation = "eastus"
$nwRgName = "hubNetwork"
$userPrincipalName = "krnese@microsoft.com"
$principalId = (Get-AzureRmADUser -UserPrincipalName $userPrinciaplName).id
$roleDefinitionId = (Get-AzureRmRoleDefinition -Name Owner).id
$deniedLocation = "northeurope" #optional
$deploymentName = "shared"
$deploymentLocation = "eastus"
$enableResourceLocks = "Yes" #optional
 
# Deploying mgmt subscription template
 
New-AzureRmDeployment -Name $deploymentName `
                      -Location $deploymentLocation `
                      -TemplateUri $mgmtSubscriptionTemplateUri `
                      -principalId $principalId `
                      -roleDefinitionId $roleDefinitionId `
                      -rgsLocation $rgsLocation `
                      -mgmtRgName $mgmtRgName `
                      -nwRgName $nwRgName `
                      -enableResourceLocks $enableResourceLocks `
                      -Verbose
 
# Fetching resourceId from the previous deployment
 
$logAnalyticsId = (Get-AzureRmResource -ResourceType Microsoft.OperationalInsights/workspaces -ResourceGroupName $mgmtRgName).ResourceId
 
# Switching deployment context to user subscription
 
Select-AzureRmSubscription -SubscriptionId $userSubscriptionId
 
# Defining variables for user subscription deployment
 
$userRgsLocation = "eastus"
$userNwRgName = "spokeNetwork"
$userPrincipalName = "krnese@microsoft.com"
$userPrincipalId = (Get-AzureRmADUser -UserPrincipalName $userPrincipalName).id
$userRoleDefinitionId = (Get-AzureRmRoleDefinition -Name Owner).id
$userDeniedLocation = "northeurope" #optional
$userDeploymentName = "user"
$userDeploymentLocation = "eastus"
$userEnableResourceLocks = "Yes"
$mgmtSubId = $mgmtSubscriptionId
$mgmtNwRgName = $nwRgName
$logAnalyticsId = $logAnalyticsId
 
# Deploying user subscription template
 
New-AzureRmDeployment -Name $userDeploymentName `
                      -Location $userDeploymentLocation `
                      -TemplateUri $userSubscriptionTemplateUri `
                      -principalId $userPrincipalId `
                      -roleDefinitionId $userRoleDefinitionId `
                      -rgsLocation $userRgsLocation `
                      -nwRgName $userNwRgName `
                      -enableResourceLocks $userEnableResourceLocks `
                      -logAnalyticsId $logAnalyticsId `
                      -mgmtNwRgName $mgmtNwRgName `
                      -Verbose
 
# Defining variables for vm workload deployment
 
$vmNamePrefix = "uservm10"
$production = "Yes"
$platform = "Linux"
$workloadTemplateUri = "https://raw.githubusercontent.com/krnese/azureArchitectures/master/Templates/Workload/vmCondition.json"
$userName = "azureadmin"
$rgDeploymentName = "workload"
$location = "eastus"
$rgName = (New-AzureRmResourceGroup -Name $vmNamePrefix -Location $location).ResourceGroupName
 
# Deploy worklaod to user subscription
 
New-AzureRmResourceGroupDeployment -Name $rgDeploymentName `
                                   -ResourceGroupName $rgName `
                                   -TemplateUri $workloadTemplateUri `
                                   -userName $userName `
                                   -platform $platform `
                                   -production $production `
                                   -vmNamePrefix $vmNamePrefix `
                                   -Verbose
 
# The end                                   