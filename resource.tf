resource "azurerm_resource_group" "terra2" {
  name     = "terra2"
  location = "East US"
}

resource "azurerm_virtual_network" "terra_vnet" {
  name                = "terra-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terra2.location
  resource_group_name = azurerm_resource_group.terra2.name
}

resource "azurerm_subnet" "terra_subnet" {
  name                 = "terra-subnet"
  resource_group_name  = azurerm_resource_group.terra2.name
  virtual_network_name = azurerm_virtual_network.terra_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "terra_nic" {
  name                = "terra-nic"
  location            = azurerm_resource_group.terra2.location
  resource_group_name = azurerm_resource_group.terra2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terra_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "terra_vm" {
  name                = "terra-winvm"
  resource_group_name = azurerm_resource_group.terra2.name
  location            = azurerm_resource_group.terra2.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "AdminPassword123!" # Change this to a secure password
  network_interface_ids = [
    azurerm_network_interface.terra_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
