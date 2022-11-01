# Automation Runbook for Application secret recycling

This module is to setup a Azure Automation Runbook to start or stop VMs within an existing AUtomation Account.

Runbooks will be scheduled to begin the day after the pipeline is run. 

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
                        name        = "vm-on"
                        frequency   = "Day"
                        interval    = 1
                        run_time    = "06:00:00"
                        start_vm    = true
                      },
                      {
                        name        = "vm-off"
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

Below is an example of a mon-friday schedule

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
                        name        = "vm-on"
                        frequency   = "Week"
                        interval    = 1
                        run_time    = "06:00:00"
                        start_vm    = true
                        week_days   = ['Monday','Tuesday','Wednesday','Thursday','Friday']
                      },
                      {
                        name        = "vm-off"
                        frequency   = "Week"
                        interval    = 1
                        run_time    = formatdate("HH:mm:ss", timestamp())
                        start_vm    = false
                        week_days   = ['Monday','Tuesday','Wednesday','Thursday','Friday']
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

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
| schedules | Object containaing schedules name, frequency, interval, start time and desired state | `schedules object` | n/a | yes |  
| vm_names | Names of VMs to apply runbook to | `array` | [] | no |  
| timezone | timezone | `string` | Europe/London | no |  
| tags | Runbook Tags | `map(string)` | n/a | yes |

### Schedules object
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Schedule | `string` | n/a | yes |
| frequency | The frequency of the schedule. - can be either `OneTime`, `Day`, `Hour`, `Week`, or `Month`. | `string` | n/a | yes |
| interval | The number of frequencys between runs. Only valid when frequency is `Day`, `Hour`, `Week`, or `Month` and defaults to `1` | `string` | n/a | yes |
| run_time | Time the schedule should run | `string` | n/a | yes |
| start_vm | What action to be taken `true` to start VM, `false` to shutdown VM | `bool` | n/a | yes |
| week_days | List of days of the week that the job should execute on. Only valid when frequency is `Week` | `list` | n/a | no |
| month_days | List of days of the month that the job should execute on. Must be between `1` and `31`. `-1` for last day of the month. Only valid when frequency is `Month` | `list` | n/a | yes |
| monthly_occurrence | List of occurrences of days within a month | `monthly_occurrence object` | n/a | yes |

### monthly_occurrence object
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| day | Day of the occurrence. Must be one of `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday` | `string` | n/a | yes |
| occurrence | Occurrence of the week within the month. Must be between `1` and `5`. `-1` for last week within the month | `number` | n/a | yes |


## Outputs

n/a