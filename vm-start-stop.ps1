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
    $vm_resting_state_on,
    [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[bool]
    $auto_acc_change_vm_status
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
if ( $auto_acc_change_vm_status -eq $true){
    foreach ($VM in $VMs){
        try { # Get status of VM
        $status = (Get-AzVM -ResourceGroupName $resourcegroup -Name $VM -Status -DefaultProfile $AzureContext).Statuses[1].Code
        Write-Output "Initial VM status for '$VM'= $status"
        } catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error getting the VM status of '$VM'  " + $ErrorMessage)
            Break
        }

        if ( $vm_resting_state_on -eq $false -and "PowerState/running","PowerState/starting","PowerState/unknown" -contains $status) {
            Write-Output "The vm will be turned off" 
            try{
                Stop-AzVM -Name $VM -ResourceGroupName $resourcegroup -DefaultProfile $AzureContext -Force
            } catch {
                $ErrorMessage = $_.Exception.message
                Write-Error ("Error stopping the VM $VM : " + $ErrorMessage)
                Break
            }
        } elseif( $vm_resting_state_on -eq $true -and "PowerState/deallocated","PowerState/deallocating","PowerState/stopped","PowerState/stopping","PowerState/unknown" -contains $vm.powerState) {
            Write-Output "The vm will be turned on" 
            try{
                Start-AzVM -Name $VM -ResourceGroupName $resourcegroup -DefaultProfile $AzureContext
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
} 
else{
	Write-Output "The status of the VMs in this subscription are not meant to change"
}

Write-Output "Script ended at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

