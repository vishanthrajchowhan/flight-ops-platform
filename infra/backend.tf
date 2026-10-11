terraform {
  backend "azurerm" {
    resource_group_name  = "rg-flightops-tfstate"
    storage_account_name = "sttfstatevishanth"
    container_name       = "tfstate"
    key                  = "flightops-dev.tfstate"
  }
}
