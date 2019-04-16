provider "azurerm" {
}
resource "azurerm_resource_group" "rg" {
        name = "${var.rgname}_rg"
        location = "${var.location}"
}