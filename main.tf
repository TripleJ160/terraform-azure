terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "jjj-rg" {
  name     = "jjj-resources"
  location = "East US"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "jjj-vnet" {
  name                = "jjj-network"
  resource_group_name = azurerm_resource_group.jjj-rg.name
  location            = azurerm_resource_group.jjj-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "jjj-subnet" {
  name                 = "jjj-subnet"
  resource_group_name  = azurerm_resource_group.jjj-rg.name
  virtual_network_name = azurerm_virtual_network.jjj-vnet.name
  address_prefixes     = ["10.123.1.0/24"]

}

resource "azurerm_network_security_group" "jjj-sg" {
  name                = "jjj-sg"
  location            = azurerm_resource_group.jjj-rg.location
  resource_group_name = azurerm_resource_group.jjj-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "jjj-dev-rule" {
  name                        = "jjj-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jjj-rg.name
  network_security_group_name = azurerm_network_security_group.jjj-sg.name
}

resource "azurerm_subnet_network_security_group_association" "jjj-sga" {
  subnet_id                 = azurerm_subnet.jjj-subnet.id
  network_security_group_id = azurerm_network_security_group.jjj-sg.id
}

resource "azurerm_public_ip" "jjj-ip" {
  name                = "jjj-ip"
  resource_group_name = azurerm_resource_group.jjj-rg.name
  location            = azurerm_resource_group.jjj-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "jjj-nic" {
  name                = "jjj-nic"
  location            = azurerm_resource_group.jjj-rg.location
  resource_group_name = azurerm_resource_group.jjj-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jjj-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jjj-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "jjj-vm" {
  name                  = "jjj-vm"
  resource_group_name   = azurerm_resource_group.jjj-rg.name
  location              = azurerm_resource_group.jjj-rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.jjj-nic.id]


  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/jjj/mtcazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}