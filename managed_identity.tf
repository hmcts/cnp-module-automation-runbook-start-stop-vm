################## VM Automation account managed identity ##################
# Create a user-assigned managed identity
resource "azurerm_user_assigned_identity" "cvp-automation-account-mi" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  resource_group_name = "${var.product}-recordings-${var.env}-rg"
  location            = var.location
  name                = "${var.product}-automation-mi-${var.env}-${index(var.auto_acc_runbooks, each.value) + 1}"
  tags                = var.tags

}

output "cvp_aa_mi_ids" {
  description = "user assigned id"
  value       = values(azurerm_user_assigned_identity.cvp-automation-account-mi)[*].id
}

# Create a custom, limited role for our managed identity
resource "azurerm_role_definition" "virtual-machine-control" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  name        = "${var.product}-vm-control-${var.env}-${index(var.auto_acc_runbooks, each.value) + 1}"
  scope       = var.resource_group_id
  description = "Custom Role for controlling virtual machines"
  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
    ]
    not_actions = []
  }
  assignable_scopes = [
    var.resource_group_id,
  ]
}
# Assign the new role to the user assigned managed identity
resource "azurerm_role_assignment" "cvp-auto-acct-mi-role" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  scope              = var.resource_group_id
  role_definition_id = azurerm_role_definition.virtual-machine-control[each.value.name].role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.cvp-automation-account-mi[each.value.name].principal_id

  depends_on = [
    azurerm_role_definition.virtual-machine-control # Required otherwise terraform destroy will fail
  ]
}
