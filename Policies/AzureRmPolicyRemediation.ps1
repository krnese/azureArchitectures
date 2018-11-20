function New-AzureRmPolicyRemediation {
    <#
        .Synopsis
        Remediates one or more policies with DeployIfNotExists.

        .Example
        New-AzureRmPolicyRemediation -PolicyAssignmentId <id> -Scope <Scope> -Locations <locations>
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $PolicyAssignmentId,

        [string] $Scope,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Locations
    )
    begin {
        $currentContext = Get-AzureRmContext
        $token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id -and $_.displayableId -eq $currentContext.Account.id}
    }
    process {
    
    if ([string]::IsNullOrEmpty($Scope))
    {
      Write-Verbose "No Scope provided; we will attempt remediation at current scope; '$($currentContext.Subscription.Id)"
    
    # Verifying that policy with deployIfNotExists is assigned at scope
    $PolicyId = Get-AzureRmPolicyAssignment -Id $PolicyAssignmentId
    if ($PolicyId.subscriptionId -ne $currentContext.Subscription.Id)
    {
        Write-Output "'$($policyId)' is not found at Scope '$($CurrentContext.Subscription.Id)'"
    }
    else {

$body = @"
{
    "properties": {
        "policyAssignmentId": $($PolicyAssignmentId | ConvertTo-Json)
    }
    
}
"@
    $remediationName = (Get-Random)
    $iwrArgs = @{
        Uri = "https://management.azure.com/subscriptions/$($currentContext.Subscription.Id)/providers/Microsoft.PolicyInsights/remediations/$($remediationName)?api-version=2018-07-01-preview"
        Headers = @{
            Authorization = "Bearer $($token[0].AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'PUT'
        Body = $body
        UseBasicParsing = $true
    }
    $result = Invoke-WebRequest @iwrArgs
    #pretty print
    [Newtonsoft.Json.Linq.JObject]::Parse($result.Content).ToString()
    }
}
    else
    {
        Write-Verbose "We're gonna party on Scope: '$Scope'"
}

    }
} 