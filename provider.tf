terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.29.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "4c09d51a-2dd9-421f-bff0-ca616d92ca42"
}