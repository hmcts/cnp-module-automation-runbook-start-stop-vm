variable "location" {
  type        = string
  description = "Location of Runbook"
  default     = "uksouth"
}
variable "env" {
  type = string
}
variable "product" {
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Runbook Tags"
}
## Azure Automation
variable "auto_acc_runbooks" {
  default = []
}
variable "resource_group_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "automation_account_name" {
  type        = string
  description = "automation account name"
}
variable "script_name" {
  type        = string
  description = "runbook script name"
  default     = "/vm-start-stop.ps1"
}
variable "timezone" {
  type    = string
  default = "Europe/London"
}
variable "vm_names" {
  type    = string
  default = ""
}
variable "mi_principal_id"{
  type    = string  
  default = "Managed identity principle id"
}