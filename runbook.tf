############ automation account  + runbook #############
resource "azurerm_automation_runbook" "vm-start-stop" {
  name                    = "${var.product}-vm-status-change-${var.env}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.env == "prod" ? "false" : "true"
  log_progress            = "false"
  description             = "This is a powershell runbook used to stop and start ${var.product} VMs"
  runbook_type            = "PowerShell"
  content                 = file("${path.module}${var.script_name}")

  tags = var.tags
}

################# automation schedule #################
resource "azurerm_automation_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  name                    = "${var.product}-schedule-${each.value.name}-${var.env}"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = each.value.frequency
  interval                = each.value.interval
  timezone                = var.timezone
  start_time              = each.value.start_time == null ? "${formatdate("YYYY-MM-DD",timeadd(timestamp(), "24h"))}T19:00:00Z" : "${formatdate("YYYY-MM-DD",timeadd(timestamp(), "24h"))}${each.value.start_time}"
  description             = each.value.start_time == null ? "This is a schedule to ${each.value.name} at ${formatdate("YYYY-MM-DD", timestamp())}T19:00:00Z" : "This is a scheduled to ${each.value.name} at ${each.value.start_time}"

  depends_on = [
    azurerm_automation_runbook.vm-start-stop
  ]
}

resource "azurerm_automation_job_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = "${var.product}-schedule-${each.value.name}-${var.env}"
  runbook_name            = azurerm_automation_runbook.vm-start-stop.name

  parameters = {
    mi_principal_id = azurerm_user_assigned_identity.cvp-automation-account-mi.principal_id
    vmlist          = var.vm_names
    resourcegroup   = var.resource_group_name
    vm_state_on     = each.value.vm_state_on
  }

  depends_on = [
    azurerm_automation_schedule.vm-start-stop
  ]
}