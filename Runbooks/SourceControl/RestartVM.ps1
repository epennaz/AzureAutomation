<#
    .DESCRIPTION
       Restarts Azure VMs
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Resource Groups and their corresponding VM Names
$Resources = @{"Resourcegroup1"="VMname1";"Resourcegroup2"="VMname2"}

#Loop through the hash table and restart each VM
foreach($Resource in $Resources.GetEnumerator())
{
	Get-AzureRmVM -ResourceGroupName $Resource.Name -Name $Resource.Value | Restart-AzureRmVM 
}
