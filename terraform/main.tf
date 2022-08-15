resource "random_string" "token" {
  length  = 13
  special = false
  upper   = false
}

locals {
  suffix = "logic-apps-iac-${random_string.token.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.suffix}"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                = substr(replace("stor${local.suffix}", "-", ""), 0, 24)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "storage_table" {
  name                 = "logicAppCalls"
  storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_resource_group_template_deployment" "api_connection" {
  name                = "deploy-api-connection"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  template_content    = file("apiConnectionArm.json")
}
