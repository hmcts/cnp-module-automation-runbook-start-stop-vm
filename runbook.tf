############ automation account  + runbook #############
resource "azurerm_automation_runbook" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  name                    = "${var.product}-VM-start-stop-${var.env}-${index(var.auto_acc_runbooks, each.value) + 1}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.env == "prod" ? "false" : "true"
  log_progress            = "false"
  description             = "This is a powershell runbook used to stop and start ${var.product} VMs"
  runbook_type            = "PowerShell"
  content                 = var.script_name == "" ? "Update ps1 location" : file("${path.module}${var.script_name}")
  # publish_content_link {
  #   uri = var.publish_content_link
  # }

  tags = var.tags
}

################# automation schedule #################
resource "azurerm_automation_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  name                    = "${var.product}-recordings-schedule-${var.env}-${index(var.auto_acc_runbooks, each.value) + 1}"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = each.value.frequency
  interval                = each.value.interval
  timezone                = var.timezone
  start_time              = each.value.start_time == null ? "${formatdate("YYYY-MM-DD", timestamp())}T19:00:00Z" : each.value.start_time
  description             = each.value.start_time == null ? "This is a schedule to stop or start VMs at ${formatdate("YYYY-MM-DD", timestamp())}T19:00:00Z" : "This is a scheduled to stop or start VMs at ${each.value.start_time}"

  depends_on = [
    azurerm_automation_runbook.vm-start-stop
  ]
}

resource "azurerm_automation_job_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = "${var.product}-recordings-schedule-${var.env}-${index(var.auto_acc_runbooks, each.value) + 1}"
  runbook_name            = azurerm_automation_runbook.vm-start-stop[each.value.name].name

  parameters = {
    mi_principal_id     = azurerm_user_assigned_identity.cvp-automation-account-mi[each.value.name].principal_id
    vmlist              = var.vm_names
    resourcegroup       = var.resource_group_name
    vmStateOn           = each.value.vmStateOn
  }

  depends_on = [
    azurerm_automation_schedule.vm-start-stop
  ]
}