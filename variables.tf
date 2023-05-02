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
variable "schedules" {
  type = list(object({
    name       = string
    frequency  = string
    interval   = number
    run_time   = string
    start_vm   = bool
    week_days  = optional(list(string))
  }))
  default = []

  validation { # Check no interval for OneTime
    condition = alltrue(flatten([
      for s in var.schedules : can(s.interval) == false
      if s.frequency == "OneTime"
    ]))
    error_message = "Cannot provide an interval when using 'oneTime'"
  }

  validation { # Check for valid frequency
    condition = alltrue([
      for s in var.schedules : contains(["OneTime", "Day", "Hour", "Week"], s.frequency)
    ])
    error_message = "'frequency' must be one of the following: 'OneTime', 'Day', 'Hour'or 'Week'."
  }

  validation { #Check for valid time format
    condition = alltrue([
      for s in var.schedules : can(regex("^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$", s.run_time))
    ])
    error_message = "'run_time' must be be in the format 'HH:MM:SS'."
  }

}
variable "resource_group_name" {
  type = string
}
variable "automation_account_name" {
  type        = string
  description = "automation account name"
}
variable "timezone" {
  type    = string
  default = "Europe/London"
}
variable "vm_names" {
  type    = list(string)
  default = []
}
variable "mi_principal_id" {
  type    = string
  default = "Managed identity principle id"
}
