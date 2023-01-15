terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = var.azurerm_resource_group
  location = "West Europe"
}

resource "azurerm_virtual_network" "azurerm_virtual_network-01" {
  name                = var.azurerm_virtual_network
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "azurerm_subnet-01" {
  name                 = var.azurerm_subnet
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network-01.name
  address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "azurerm_public_ip-01" {
  name                = var.azurerm_public_ip
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "azurerm_network_interface-01" {
  name                      = var.azurerm_network_interface
  location                  = "West Europe"
  resource_group_name       = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "test-configuration"
    subnet_id                     = azurerm_subnet.azurerm_subnet-01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azurerm_public_ip-01.id
  }
}

resource "azurerm_network_security_group" "azurerm_network_security_group-01" {
  name                = var.azurerm_network_security_group
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = var.azurerm_virtual_machine
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.azurerm_network_interface-01.id]
  vm_size               = "Standard_D1_v2"

  storage_os_disk {
    name              = "test-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "test-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
}

