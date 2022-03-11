# Automation Runbook for Application secret recycling

This module is to setup a Azure Automation Runbook to start or stop VMs within an existing AUtomation Account.


## Example

Below is the standard example setup

```terraform
# =================================================================
# ==========    vm shutdown/start runbook module    ===============
# =================================================================
#  vm shutdown/start runbook module
module "vm_automation" {
  source = "git::https://github.com/hmcts/cnp-module-automation-runbook-start-stop-vm"

  product                 = "xyz"
  env                     = "sbox"
  location                = "uksouth"
  automation_account_name = "xyz-sbox-aa"
  schedules       = [
                              {
                                frequency   = "Day"
                                interval    = 1
                                run_time    = "06:00:00"
                                start_vm    = true
                              },
                              {
                                frequency   = "Day"
                                interval    = 1
                                run_time    = formatdate("HH:mm:ss", timestamp())
                                start_vm    = false
                              }
                            ]
  resource_group_name     = "xyz-sbox-rg"
  vm_names                = ["xyz-sbox-vm1", "xyz-sbox-vm2"]
  tags                    = var.common_tags
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| product | Product name | `string` | n/a | yes |  
| env | Environment | `string` | n/a | yes |  
| location | Location | `string` | uksouth | no |  
| automation_account_name | Automation account name | `string` | n/a | yes |   
| resource_group_name | Resource group name | `string` | n/a | yes |  
| schedules | Object containaing schedules name, frequency, interval, start time and desired state | `object` | n/a | yes |  
| vm_names | Names of VMs to apply runbook to | `string` | "" | no |  
| timezone | timezone | `string` | Europe/London | no |  
| tags | Runbook Tags | `map(string)` | n/a | yes |

## Outputs

n/a