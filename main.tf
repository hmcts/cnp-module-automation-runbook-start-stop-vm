####################### locals ########################
locals {
  #### main ###
  resource_group_name = var.auto_acc_runbook_names.resource_group_name
  runbook_name        = var.auto_acc_runbook_names.runbook_name
  schedule_name       = var.auto_acc_runbook_names.schedule_name
  job_schedule_name   = var.auto_acc_runbook_names.job_schedule_name
  script_name         = var.auto_acc_runbook_names.script_name
  vm_names            = var.auto_acc_runbook_names.vm_names
  start_time          = try(var.runbook_schedule_times.start_time, null)
  timezone            = try(var.runbook_schedule_times.timezone, "Europe/London")
  #### managed identity ###
  user_assigned_identity_name = var.auto_acc_runbook_names.user_assigned_identity_name
  role_definition_name        = var.auto_acc_runbook_names.role_definition_name
}

############ automation account  + runbook #############
resource "azurerm_automation_runbook" "vm-start-stop" {
  name                    = local.runbook_name
  location                = var.location
  resource_group_name     = local.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.env == "prod" ? "false" : "true"
  log_progress            = "false"
  description             = "This is a powershell runbook used to stop and start cvp VMs"
  runbook_type            = "PowerShell"
  content                 = file(local.script_name)
  publish_content_link {
    uri = var.publish_content_link
  }

  tags = var.tags
}

################# automation schedule #################
resource "azurerm_automation_schedule" "vm-start-stop" {
  name                    = local.schedule_name
  resource_group_name     = local.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = var.runbook_schedule_times.frequency
  interval                = var.runbook_schedule_times.interval
  timezone                = local.timezone
  start_time              = local.start_time
  description             = local.start_time == null ? "This is a schedule to stop or start VMs" : "This is a scheduled to stop or start VMs at ${local.start_time}"

  depends_on = [
    azurerm_automation_runbook.vm-start-stop
  ]
}

resource "azurerm_automation_job_schedule" "vm-start-stop" {
  resource_group_name     = local.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = local.job_schedule_name
  runbook_name            = azurerm_automation_runbook.vm-start-stop.name

  parameters = {
    mi_principal_id               = azurerm_user_assigned_identity.cvp-automation-account-mi.principal_id
    vmlist                        = local.vm_names
    resourcegroup                 = local.resource_group_name
    vm_resting_state_on           = var.vm_status.vm_resting_state_on
    azdo_pipe_to_change_vm_status = var.vm_status.azdo_pipe_to_change_vm_status
  }

  depends_on = [
    azurerm_automation_schedule.vm-start-stop
  ]
}