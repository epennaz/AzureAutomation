workflow Invoke-AzureVMCommand
{
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
	
	
	InlineScript 
    {  
        # Get the Azure certificate for remoting into this VM 
        $winRMCert = (Get-AzureRmVM -ResourceGroupName "XXXXXX" -Name "XXXXXX" | select -ExpandProperty vm).DefaultWinRMCertificateThumbprint    
         
        $AzureX509cert = Get-AzureCertificate -ServiceName 'trial-brisebois' -Thumbprint $winRMCert -ThumbprintAlgorithm sha1 
               
        # Add the VM certificate into the LocalMachine 
        if ((Test-Path Cert:\LocalMachine\Root\$winRMCert) -eq $false) 
        { 
            Write-Progress "VM certificate is not in local machine certificate store - adding it"
            $certByteArray = [System.Convert]::fromBase64String($AzureX509cert.Data) 
            $CertToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList (,$certByteArray) 
            $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
            $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite) 
            $store.Add($CertToImport) 
            $store.Close() 
        } 
    }   
	
	#WinRM
	#Get the credentials of the machine
	$cred = Get-AutomationPSCredential -Name 'PowerFactorsAdministrator'
	#Connect to your Azure Account
    $Account = Add-AzureAccount -Credential $creds
       
	   
	# Build the connection URI with the WinRM port configured on the VM: here is a test URI         
	$uri = 'XXXXXX:5986'
	              
	# Run a command on the Azure VM 
	InlineScript {         
	    Invoke-command -ConnectionUri $uri -credential $cred -ScriptBlock { 
	        
	        # This script executes on the remote VM
	        $ModuleName = "PSWindowsUpdate"
			$Path = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
			$PathToModule = "$Path\$ModuleName"
			#Install the PS Windows Update Module if it does not exist
			if(-Not (Test-Path $PathToModule))
			{
				Save-Module -Name PSWindowsUpdate -Path $Path
				Install-Module -Name $ModuleName
			}
	    } 
	}
}




