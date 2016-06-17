<#
    .DESCRIPTION
       Resizes AF VMs to Standard_A6
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


$ResourceGroupNameA = "ResourceGroupA" 
$VMNameA = "VMA" 
$NewVMSizeA = "Standard_A6"

$vmA = Get-AzureRmVM -ResourceGroupName $ResourceGroupNameA -Name $VMNameA 
$vmA.HardwareProfile.vmSize = $NewVMSizeA 
Update-AzureRmVM -ResourceGroupName $ResourceGroupNameA -VM $vmA

$ResourceGroupNameB = "ResourceGroupAB" 
$VMNameB = "VMB" 
$NewVMSizeB = "Standard_A6"

$vmB = Get-AzureRmVM -ResourceGroupName $ResourceGroupNameB -Name $VMNameB
$vmB.HardwareProfile.vmSize = $NewVMSizeB 
Update-AzureRmVM -ResourceGroupName $ResourceGroupNameB -VM $vmB
