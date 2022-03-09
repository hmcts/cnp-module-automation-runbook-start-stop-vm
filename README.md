# Automation Runbook for Application secret recycling

This module is to setup a Azure Automation Runbook to start or stop VMs within an existing AUtomation Account.


## Example

Below is the standard example setup

```tfvars
# =================================================================
# =================        env tfvar         ======================
# =================================================================
product = "cvp"
env  = "sbox"
location = "uksouth"
auto_acc_runbooks = [
  {
    name        = "vm-on",
    frequency   = "Day"
    interval    = 1
    start_time  = "T06:00:00Z"
    vm_state_on = true
  },
  {
    name        = "vm-off",
    frequency   = "Day"
    interval    = 1
    start_time  = "T20:00:00Z"
    vm_state_on = false
  }
]
```


```terraform
# =================================================================
# =================    automation account    ======================
# =================================================================
resource "azurerm_automation_account" "vm-start-stop" {

  name                = "${var.product}-recordings-${var.env}-aa"
  location            = var.location
  resource_group_name = "${var.product}-recordings-${var.env}-rg"

  identity {
    type         = "UserAssigned"
    identity_ids = [module.vm_automation.cvp_aa_mi_id]
  }

  tags = var.common_tags
}

locals {
  source = "${path.module}/vm_automation"
}

# =================================================================
# ==========    vm shutdown/start runbook module    ===============
# =================================================================
#  vm shutdown/start runbook module
module "vm_automation" {
  source = "github.com/hmcts/cnp-module-automation-runbook-start-stop-vm"

  product                 = var.product
  env                     = var.env
  location                = var.location
  automation_account_name = azurerm_automation_account.vm-start-stop.name
  tags                    = var.common_tags
  auto_acc_runbooks       = var.auto_acc_runbooks
  resource_group_id       = azurerm_resource_group.rg.id
  resource_group_name     = azurerm_resource_group.rg.name
  vm_names                = join(",", [azurerm_linux_virtual_machine.vm1.name, azurerm_linux_virtual_machine.vm2.name])
}


```

## Requirements   

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.97.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_runbook.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_job_schedule.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_user_assigned_identity.cvp-automation-account-mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_role_definition.virtual-machine-control](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_assignment.cvp-auto-acct-mi-role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| automation_account_name | Automation account name | `string` | n/a | yes |   
| location | Location | `string` | uksouth | no |  
| env | Environment | `string` | n/a | yes |  
| resource_group_id | Resource group id | `string` | n/a | yes |  
| resource_group_name | Resource group name | `string` | n/a | yes |  
| vm_status | Object to describe desired state of VM for env and whether VM should be adjusted by automation account | `object` | n/a | yes |  
| runbook_schedule_times | Object to describe schedule times for automation account schedule | `object` | n/a | yes |  
| auto_acc_runbook_names | Object containg names for resource group, runbook, schedule, job schedule, user id name, role definition name, script name & VM names | `string` | n/a | yes |   
| tags | Runbook Tags | `map(string)` | n/a | yes |

## Outputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cvp_aa_mi_id | Automation account managed identity id | `string` | n/a | n/a |   