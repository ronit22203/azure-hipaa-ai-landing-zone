variable "project_prefix" {
  description = "Short prefix for naming resources"
  type        = string
  default     = "hipaa-ai"
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "location" {
  description = "Enforced Azure region for HIPAA data residency"
  type        = string
  default     = "centralindia"
}

variable "budget_amount" {
  description = "Monthly hard budget cap in USD"
  type        = number
  default     = 5.0
}

variable "budget_start_date" {
  description = "First day of the current month in YYYY-MM-01T00:00:00Z format"
  type        = string
  default     = "2026-11-01T00:00:00Z"
}

variable "alert_email" {
  description = "Email address for budget alerts (50%/80% actual, 100% forecasted)"
  type        = string
}

variable "enable_delete_lock" {
  description = "Enable CanNotDelete management lock on workload RG (true for prod, false for ephemeral dev)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Mandatory governance tags applied to all resources"
  type        = map(string)
}
