# Resource Group
# =============================
resource "azurerm_resource_group" "raju_rg" {
  name     = "raju-rg"
  location = "Australia East"
}

# =============================
# Virtual Network
# =============================
resource "azurerm_virtual_network" "raju_vnet" {
  name                = "raju-vnet"
  location            = azurerm_resource_group.raju_rg.location
  resource_group_name = azurerm_resource_group.raju_rg.name
  address_space       = ["10.0.0.0/16"]
}

# =============================
# Subnet
# =============================
resource "azurerm_subnet" "raju_subnet" {
  name                 = "raju-subnet"
  resource_group_name  = azurerm_resource_group.raju_rg.name
  virtual_network_name = azurerm_virtual_network.raju_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =============================
# Network Security Group
# =============================
resource "azurerm_network_security_group" "raju_nsg" {
  name                = "raju-nsg"
  location            = azurerm_resource_group.raju_rg.location
  resource_group_name = azurerm_resource_group.raju_rg.name

  security_rule {
    name                       = "Allow-SSH"
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

# =============================
# Public IP
# =============================
resource "azurerm_public_ip" "raju_pip" {
  name                = "raju-public-ip"
  location            = azurerm_resource_group.raju_rg.location
  resource_group_name = azurerm_resource_group.raju_rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

# =============================
# Network Interface
# =============================
resource "azurerm_network_interface" "raju_nic" {
  name                = "raju-nic"
  location            = azurerm_resource_group.raju_rg.location
  resource_group_name = azurerm_resource_group.raju_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.raju_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.raju_pip.id
  }
}

# =============================
# NIC + NSG Association
# =============================
resource "azurerm_network_interface_security_group_association" "raju_nic_nsg" {
  network_interface_id      = azurerm_network_interface.raju_nic.id
  network_security_group_id = azurerm_network_security_group.raju_nsg.id
}

# =============================
# Linux Virtual Machine
# =============================
resource "azurerm_linux_virtual_machine" "raju_vm" {
  name                = "raju-linux-vm"
  resource_group_name = azurerm_resource_group.raju_rg.name
  location            = azurerm_resource_group.raju_rg.location
  size                = "Standard_D2s_v3"

  admin_username = "azureuser"
  admin_password = "Admin@1234"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.raju_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}