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
variable "vm_status" {
  default = {}
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
