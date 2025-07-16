resource "azurerm_resource_group" "terra2" {
  name     = "terra2"
  location = "East US"
}

resource "azurerm_resource_group" "storeterra" {
    name     = "example-resources2"
    location = "East US"
}

resource "azurerm_storage_account" "saterra" {
    name                     = "niha2582"
    resource_group_name      = azurerm_resource_group.storeterra2.name
    location                 = azurerm_resource_group.storeterra2.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
 
resource "azurerm_storage_container" "sacontainer" {
    name                  = "terra-container"
    storage_account_name  = azurerm_storage_account.saterra.name
    container_access_type = "private"
}

resource "azurerm_virtual_network" "terra2_vnet" {
    name                = "terra2-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.terra2.location
    resource_group_name = azurerm_resource_group.terra2.name
}
 
resource "azurerm_subnet" "subnet1" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.terra2.name
    virtual_network_name = azurerm_virtual_network.terra_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_subnet" "subnet2" {
    name                 = "subnet2"
    resource_group_name  = azurerm_resource_group.terra2.name
    virtual_network_name = azurerm_virtual_network.terra2_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terra_nic" {
  name                = "terra-nic"
  location            = azurerm_resource_group.terra2_vnet.location
  resource_group_name = azurerm_resource_group.terra2_vnet.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "terra_vm" {
  name                  = "terra-vm"
  location              = azurerm_resource_group.terra.location
  resource_group_name   = azurerm_resource_group.terra.name
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  admin_password        = "P@ssword1234!"  # Use a secure password in production
  network_interface_ids = [azurerm_network_interface.terra2_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
