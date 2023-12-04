data "azurerm_resource_group" "rg01" {
  name = var.rg_name
}

resource "azurerm_subnet" "example" {
  #count = length(var.subnet_name)
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.rg01.name
  virtual_network_name = var.vnet-name
  address_prefixes     = [var.subnet_CIDR]
}

output "sub_id" {
  value = azurerm_subnet.example.id
}