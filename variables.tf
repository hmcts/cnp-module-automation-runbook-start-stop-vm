variable "location" {
  type        = string
  description = "Location of Runbook"
  default     = "uksouth"
}
variable "env" {
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Runbook Tags"
}
## Azure Automation
variable "automation_account_name" {
  type        = string
  description = "automation account name"
}
variable "publish_content_link" {
  type        = string
  description = "source of ps1 script"
}
variable "azdo_pipe_to_change_vm_status" {
  description = "Should azdo pipeline change the status of the VMs"
  default     = false
}
variable "vm_resting_state_on" {
  description = "The desired resting state i.e. on/off for VMs"
}
variable "resource_group_id" {
  type        = string
  description = "resource group id"
}
variable "auto_acc_runbook_names" {
  default = {}
}
variable "runbook_schedule_times" {
  default = {}
}
