# Automation Runbook for Application secret recycling

This module is to setup a Azure Automation Runbook to start or stop VMs within an existing AUtomation Account.


## Example

Below is the standard example setup

```tfvars
# =================================================================
# =================        env tfvar         ======================
# =================================================================
product = "cvp"
env = "sbox"
automation_account_sku_name = "Basic"
script_name                   = "/.terraform/modules/vm_automation/vm-start-stop.ps1"
vm_resting_state_on           = false
azdo_pipe_to_change_vm_status = true
runbook_schedule_times = {
  "frequency" = "Day"
  "interval"  = 1
  "timezone"  = "Europe/London"
}
```

```terraform
# =================================================================
# =================    automation account    ======================
# =================================================================

resource "azurerm_automation_account" "vm-start-stop" {
  count = var.azdo_pipe_to_change_vm_status == true ? 1 : 0

  name                = "${var.product}-recordings-${var.env}-aa"
  location            = var.location
  resource_group_name = "${var.product}-recordings-${var.env}-rg"
  sku_name            = var.automation_account_sku_name

  identity {
    type         = "UserAssigned"
    identity_ids = [module.vm_automation[0].cvp_aa_mi_id]
  }

  tags = local.common_tags
}

# =================================================================
# ==========    vm shutdown/start runbook module    ===============
# =================================================================
module "vm_automation" {
  count = var.azdo_pipe_to_change_vm_status == true ? 1 : 0

  source                        = "github.com/hmcts/cnp-module-automation-runbook-start-stop-vm"
  automation_account_name       = azurerm_automation_account.vm-start-stop[0].name
  location                      = var.location
  env                           = var.env
  resource_group_id             = module.wowza.wowza_rg_id
  azdo_pipe_to_change_vm_status = var.azdo_pipe_to_change_vm_status
  vm_resting_state_on           = var.vm_resting_state_on
  runbook_schedule_times        = merge(var.runbook_schedule_times, { "start_time" = "${formatdate("YYYY-MM-DD", timestamp())}T19:00:00Z" })
  publish_content_link          = "https://raw.githubusercontent.com/hmcts/cnp-module-automation-runbook-start-stop-vm/master/vm-start-stop.ps1"
  tags                          = local.common_tags
  auto_acc_runbook_names = {
    resource_group_name         = "${var.product}-recordings-${var.env}-rg"
    runbook_name                = "${var.product}-recordings-VM-start-stop-${var.env}"
    schedule_name               = "${var.product}-recordings-schedule-${var.env}"
    job_schedule_name           = "${var.product}-recordings-schedule-${var.env}"
    user_assigned_identity_name = "${var.product}-recordings-automation-mi-${var.env}"
    role_definition_name        = "${var.product}-recordings-vm-control-${var.env}"
    script_name                 = "${path.module}${var.script_name}"
    vm_names                    = join(",", [module.wowza.vm1_name, module.wowza.vm2_name])
  }
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