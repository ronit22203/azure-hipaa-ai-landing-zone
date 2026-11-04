output "rg_management_name" {
  value = azurerm_resource_group.management.name
}

output "rg_connectivity_name" {
  value = azurerm_resource_group.connectivity.name
}

output "rg_workload_name" {
  value = azurerm_resource_group.workload.name
}

output "rg_workload_id" {
  value = azurerm_resource_group.workload.id
}

output "location" {
  value = var.location
}
