# Powershell example:

# Make sure the `azurescript` collector is assigned to the asset
# and both the `backup` and `agent` check are enabled before running this script

# Asset ID
$assetId = 123  # REPLACE WITH YOUR ASSET ID

# Agent Token
$token = 'xxxxxxxxxxxxxxxxxxx'  # REPLACE WITH YOUR TOKEN

# Version and info for the agent (Version must be greater than 0.1.0, info is free format)
$version = '1.0.0'  # REPLACE WITH YOUR VERSION
$info = 'Azure Scripts by PowerShell'  # REPLACE WITH YOUR INFO

# InfraSonar Uri for inserting check data (both backup and agent check)
$uriBackup = 'https://api.infrasonar.com/asset/{0}/collector/azurescript/check/backup' -f $assetId
$uriAgent = 'https://api.infrasonar.com/asset/{0}/collector/azurescript/check/agent' -f $assetId

# Connect to Azure account
# Set the Azure subscription ID
$subscriptionId = "xxx"  # REPLACE WITH YOUR SUBSCRIPTION ID

# Set the Azure AD tenant ID
$tenantId = "xxx"  # REPLACE WITH YOUR TENANT ID

# Set the client ID (application ID)
$clientID = "xxx"  # REPLACE WITH YOUR APPLICATION ID

# Set the client secret (application password)
$clientSecret = "xxx"  # REPLACE WITH YOUR CLIENT SECRET

# Set the Name and ID of the backup vault
$backupVaultName = "My-Backup-Vault"  # REPLACE WITH YOUR BACKUP VAULT NAME
$backupVaultID= '/subscriptions/.../providers/microsoft.recoveryservices/Vaults/{0}' -f $backupVaultName  # REPLACE WITH YOUR BACKUP VAULT ID

# Create a secure string for the client secret
$secureClientSecret = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force

# Create the Azure credentials
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($clientID, $secureClientSecret)

# Connect to Azure with the service principal
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId -Subscription $subscriptionId | Out-null

# Get the backup vault
$backupVault = Get-AzRecoveryServicesVault | Where-Object {$_.Name -eq $backupVaultName}

# Get the latest jobs
$latestJobs  = Get-AzRecoveryServicesBackupJob -VaultId $backupVaultID | Sort-Object -Property name, @{Expression="properties.startTime";Descending=$true} | Group-Object -Property WorkLoadName | ForEach-Object { $_.Group | Select-Object -First 1 }

$items = @()
foreach ($job in $latestJobs) {
    $items += @{
        name = $job.WorkloadName  #  <--- let op, 'name' is verplicht en moet uniek zijn
        Status = $job.Status
        StartTime = [int64]([DateTimeOffset]$job.StartTime.ToUniversalTime()).ToUnixTimeSeconds()
        EndTime =  [int64]([DateTimeOffset]$job.EndTime.ToUniversalTime()).ToUnixTimeSeconds()
        Duration = $job.Duration.TotalSeconds
        BackupManagentmentType = $job.BackupManagentmentType
    }
}

$headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer {0}' -f $token
}

$body = @{
    data = @{
        jobs = $items
    }
    version = $version
} | ConvertTo-Json -Compress -Depth 5

Invoke-RestMethod -Uri $uriBackup -Method Post -Headers $headers -Body $body

# Finally, write the `agent` check

$agent = @{
    name = 'azure'
    info = $info
    version = $version
}

$body = @{
    data = @{
        agent = @($agent)
    }
    version = $version
} | ConvertTo-Json -Compress -Depth 5

Invoke-RestMethod -Uri $uriAgent -Method Post -Headers $headers -Body $body
