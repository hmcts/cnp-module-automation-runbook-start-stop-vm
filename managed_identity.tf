################## VM Automation account managed identity ##################
# Create a user-assigned managed identity
resource "azurerm_user_assigned_identity" "cvp-automation-account-mi" {
  resource_group_name = var.auto_acc_runbook_names.resource_group_name
  location            = var.location
  name                = var.auto_acc_runbook_names.user_assigned_identity_name
  tags                = var.tags
}

output "cvp_aa_mi_id" {
  description = "user assigned id"
  value       = azurerm_user_assigned_identity.cvp-automation-account-mi.id
}

# Create a custom, limited role for our managed identity
resource "azurerm_role_definition" "virtual-machine-control" {
  name        = var.auto_acc_runbook_names.role_definition_name
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
  scope              = var.resource_group_id
  role_definition_id = azurerm_role_definition.virtual-machine-control.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.cvp-automation-account-mi.principal_id

  depends_on = [
    azurerm_role_definition.virtual-machine-control # Required otherwise terraform destroy will fail
  ]
}
