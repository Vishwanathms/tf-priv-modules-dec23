provider "azurerm" {
      features {}
}

module "sub1" {
    source = "./subnet"
    subnet_name = "sub1"
    subnet_CIDR = "10.0.1.0/24"
    rg_name = "rg01-b1"
    vnet-name = "example-network"
}

module "VM-01" {
    source = "./vm-template"
    rg_name = "rg01-b1"
    nic_name = "nic1"
    tag_env = "Dev"
    vm_name = "VM01"
    vm_size = "Standard_DS1_v2"
    os_disk_name = "myosdisk1"
    computer_name  = "hostname"
    admin_username = "testadmin"
    vm_pwd = "Password1234!"
    region = "East US"  
    subnet_id = module.sub1.sub_id 
}

module "VM-02" {
    source = "./vm-template"
    rg_name = "rg01-b1"
    nic_name = "nic2"
    tag_env = "Dev"
    vm_name = "VM02"
    vm_size = "Standard_DS1_v2"
    os_disk_name = "myosdisk2"
    computer_name  = "hostname"
    admin_username = "testadmin"
    vm_pwd = "Password1234!"
    region = "East US"  
    subnet_id = module.sub1.sub_id
}