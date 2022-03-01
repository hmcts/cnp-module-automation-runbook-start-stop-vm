############ automation account  + runbook #############
resource "azurerm_automation_runbook" "vm-start-stop" {
  name                    = var.auto_acc_runbook_names.runbook_name
  location                = var.location
  resource_group_name     = var.auto_acc_runbook_names.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.env == "prod" ? "false" : "true"
  log_progress            = "false"
  description             = "This is a powershell runbook used to stop and start cvp VMs"
  runbook_type            = "PowerShell"
  content                 = file(var.auto_acc_runbook_names.script_name)
  publish_content_link {
    uri = "https://raw.githubusercontent.com/hmcts/cvp-audio-ingress/VIH-8544/modules/automation-runbook-vm-shutdown/vm-start-stop.ps1"
  }

  tags = var.tags
}

################# automation schedule #################
resource "azurerm_automation_schedule" "vm-start-stop" {
  name                    = var.auto_acc_runbook_names.schedule_name
  resource_group_name     = var.auto_acc_runbook_names.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = var.runbook_schedule_times.frequency
  interval                = var.runbook_schedule_times.interval
  timezone                = try(var.runbook_schedule_times.timezone, "Europe/London")
  start_time              = try(var.runbook_schedule_times.start_time, null)
  description             = "This is a scheduled to stop or start VMs at ${var.runbook_schedule_times.start_time}"

  depends_on = [
    azurerm_automation_runbook.vm-start-stop
  ]
}

resource "azurerm_automation_job_schedule" "vm-start-stop" {
  resource_group_name     = var.auto_acc_runbook_names.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = var.auto_acc_runbook_names.job_schedule_name
  runbook_name            = azurerm_automation_runbook.vm-start-stop.name

  parameters = {
    mi_principal_id     = azurerm_user_assigned_identity.cvp-automation-account-mi.principal_id
    vmlist              = var.auto_acc_runbook_names.vm_names
    resourcegroup       = var.auto_acc_runbook_names.resource_group_name
    vm_resting_state_on = var.vm_status.vm_resting_state_on
    vm_change_status    = var.vm_status.vm_change_status
  }

  depends_on = [
    azurerm_automation_schedule.vm-start-stop
  ]
}