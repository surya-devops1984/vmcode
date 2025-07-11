resource "azurerm_resource_group" "rg" {
  name = "rg-vm-agra2"
  location = "West US 3"
}

resource "azurerm_virtual_network" "vnet2" {
    depends_on = [ azurerm_resource_group.rg ]
  name = "vnet-vm-agra2"
  location = "West US 3"
  resource_group_name = "rg-vm-agra2"
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
    depends_on = [ azurerm_virtual_network.vnet2 ]
  name = "subnet-vm-agra1"
  resource_group_name = "rg-vm-agra2"
  virtual_network_name = "vnet-vm-agra2"
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-agra" {
    depends_on = [ azurerm_subnet.subnet ]
  name = "pip-agra"
  location = "West US 3"
  resource_group_name = "rg-vm-agra2"
  allocation_method = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  depends_on = [ azurerm_subnet.subnet ]
  name = "nsg-vm"
  location = "West US 3"
  resource_group_name = "rg-vm-agra2"
}

resource "azurerm_network_security_rule" "nsg-rule" {
   name                        = "nsg-rule-vm"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = ["22","80"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-vm-agra2"
  network_security_group_name = azurerm_network_security_group.nsg.name
  
}


resource "azurerm_network_interface" "nic-agra" {
    depends_on = [ azurerm_public_ip.pip-agra ]
    name = "nic-vm-agra"
    location = "West US 3"
    resource_group_name = "rg-vm-agra2"
    ip_configuration {
      name = "internal"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.pip-agra.id
      subnet_id = azurerm_subnet.subnet.id
    }
  }

resource "azurerm_linux_virtual_machine" "linux-vm" {
  depends_on = [ azurerm_network_interface.nic-agra ]
  name = "linux-vm-agra"
  location = "West US 3"
  resource_group_name = "rg-vm-agra2"
  size = "Standard_F2"
  admin_username      = "todo-front-agra"
  admin_password      = "Admin@123456"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-agra.id, 
    ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 source_image_reference {
   publisher = "canonical"                  #Publisher ID
   offer = "ubuntu-24_04-lts"   #Product ID
   sku = "ubuntu-pro-gen1"                    #Plan ID
   version = "latest"
 }
}
resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.nic-agra.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_resource_group" "rg3" {
  name = "rg-vm-agra3"
  location = "West US 3"
}