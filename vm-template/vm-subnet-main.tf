data "azurerm_resource_group" "rg01" {
  name = var.rg_name
}

resource "azurerm_public_ip" "example" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = data.azurerm_resource_group.rg01.name
  location            = data.azurerm_resource_group.rg01.location
  allocation_method   = "Static"

  tags = {
    environment = var.tag_env
  }
}

resource "azurerm_network_interface" "main" {
  name                = var.nic_name
  location            = data.azurerm_resource_group.rg01.location
  resource_group_name = data.azurerm_resource_group.rg01.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = var.vm_name
  location              = data.azurerm_resource_group.rg01.location
  resource_group_name   = data.azurerm_resource_group.rg01.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.os_disk_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.vm_pwd

  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.tag_env
  }
}

resource "null_resource" "copy-file" {

  triggers = {
    always_run = timestamp()
  }
  provisioner "file" {
    source = "test1.txt"
    destination = "test1.txt"

    connection {
      type = "ssh"
      user = var.admin_username
      password = var.vm_pwd
      host = azurerm_public_ip.example.ip_address
    }
  }
}

resource "null_resource" "remote-command" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    #scripts = "[cp test1.txt test2.txt]"
    inline = [ 
      "cp test1.txt test2.txt"
     ]

    connection {
      type = "ssh"
      user = var.admin_username
      password = var.vm_pwd
      host = azurerm_public_ip.example.ip_address
    }
  }
  depends_on = [ null_resource.copy-file ]
}
