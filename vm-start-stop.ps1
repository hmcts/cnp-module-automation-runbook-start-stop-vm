Param(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
    [String] 
    $mi_principal_id,
    [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[string]
    $vmlist,
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
    [String] 
    $resourcegroup,    
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
    [bool] 
    $start_vm
)

Write-Output "Script started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null
# Connect to Azure with user-assigned managed identity
# Don't do what Microsoft say - they use Client_Id here but it needs to be
# the managed_identity_principal_id
$AzureContext = (Connect-AzAccount -Identity -AccountId $mi_principal_id).context
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
# Separate our vmlist into an array we can iterate over
$VMssplit = $vmlist.Split(",") 
[System.Collections.ArrayList]$VMs = $VMssplit

# Loop through one or more VMs which will be passed in from the terraform as a list
# If the list is empty it will skip the block
foreach ($VM in $VMs){
    try { # Get status of VM
    $status = (Get-AzVM -ResourceGroupName $resourcegroup -Name $VM -Status -DefaultProfile $AzureContext).Statuses[1].Code
    Write-Output "Initial VM status for '$VM'= $status"
    } catch {
        $ErrorMessage = $_.Exception.message
        Write-Error ("Error getting the VM status of '$VM'  " + $ErrorMessage)
        Break
    }

    if ( $start_vm -eq $false -and "PowerState/running","PowerState/starting","PowerState/unknown" -contains $status) {
        Write-Output "The vm will be turned off" 
        try{
            Stop-AzVM -Name $VM -ResourceGroupName $resourcegroup -DefaultProfile $AzureContext -Force
        } catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error stopping the VM $VM : " + $ErrorMessage)
            Break
        }
    } elseif( $start_vm -eq $true -and "PowerState/deallocated","PowerState/deallocating","PowerState/stopped","PowerState/stopping","PowerState/unknown" -contains $status) {
        Write-Output "The vm will be turned on" 
        try{
            Start-AzVM -Name $VM -ResourceGroupName $resourcegroup -DefaultProfile $AzureContext
            $ScriptToRun = "/home/wowza/runcmd.sh"
            Out-File -InputObject $ScriptToRun -FilePath script.sh
            Invoke-AzVMRunCommand -ResourceGroupName $resourcegroup -VMName $VM -CommandId 'RunShellScript' -ScriptPath script.sh
        } catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error starting the VM $VM : " + $ErrorMessage)
            Break
        }
    } else {
        Write-Output "The VM $VM is in the desired state"
    }
    $status = (Get-AzVM -ResourceGroupName $resourcegroup -Name $VM -Status -DefaultProfile $AzureContext).Statuses[1].Code
    Write-Output "Final $VM VM status: $status"
    Write-Output "`r`n"
}


Write-Output "Script ended at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

