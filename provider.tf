 terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.56.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "sepret-rg-sc"
    storage_account_name = "merasa"
    container_name       = "container"
    key                  = "terraform.tfstate"
  }
 }

provider "azurerm" {
  features {}

  subscription_id = "ea872ece-8f69-42eb-a86b-4677126a740f"
  # tenant_id       = "f8f2c9c1-b251-47a7-9e0e-dcbedb89265a"
}
