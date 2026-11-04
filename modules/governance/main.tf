# ---------------------------------------------------------------------------
# 1. Enterprise Resource Group Archetypes (Simulated Multi-Subscription CAF)
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "management" {
  name     = "rg-${var.project_prefix}-mgmt-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${var.project_prefix}-conn-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${var.project_prefix}-workload-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

# ---------------------------------------------------------------------------
# 2. FinOps $5 Kill-Switch Budget (Scoped to Workload RG)
# ---------------------------------------------------------------------------
resource "azurerm_consumption_budget_resource_group" "shoestring_guard" {
  name              = "budget-${var.project_prefix}-${var.environment}"
  resource_group_id = azurerm_resource_group.workload.id

  amount     = var.budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}

# ---------------------------------------------------------------------------
# 3. Azure Policy: Enforce Data Residency (centralindia only)
# ---------------------------------------------------------------------------
# Built-in Policy Definition ID for "Allowed locations"
locals {
  policy_def_allowed_locations = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  policy_def_require_tag       = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
}

resource "azurerm_resource_group_policy_assignment" "data_residency" {
  name                 = "pol-residency-${var.environment}"
  resource_group_id    = azurerm_resource_group.workload.id
  policy_definition_id = local.policy_def_allowed_locations
  display_name         = "HIPAA Data Residency: Restrict to ${var.location}"
  description          = "Blocks deployment of any clinical AI resource outside ${var.location}."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [var.location]
    }
  })
}

# ---------------------------------------------------------------------------
# 4. Azure Policy: Enforce Mandatory DataClassification Tag
# ---------------------------------------------------------------------------
resource "azurerm_resource_group_policy_assignment" "require_hipaa_tag" {
  name                 = "pol-req-tag-${var.environment}"
  resource_group_id    = azurerm_resource_group.workload.id
  policy_definition_id = local.policy_def_require_tag
  display_name         = "HIPAA Governance: Require DataClassification Tag"

  parameters = jsonencode({
    tagName = {
      value = "DataClassification"
    }
  })
}

# ---------------------------------------------------------------------------
# 5. Optional Management Lock (AZ-104 Exam Staple: CanNotDelete)
# ---------------------------------------------------------------------------
resource "azurerm_management_lock" "workload_lock" {
  count      = var.enable_delete_lock ? 1 : 0
  name       = "lock-hipaa-workload-${var.environment}"
  scope      = azurerm_resource_group.workload.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of HIPAA clinical enclave in production."
}
