# Create randomized resource group name in your designated region
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_group_name}-${var.env_tier}"
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "prefectnetwork" {
  name                = var.vnet_name
  address_space       = var.vnet_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet in  myVnet
resource "azurerm_subnet" "prefectsubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.subnet_id
}

#Create public IPs if public acccess is needed; this IS publicly exposed.
resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = var.default_nsg.name
    priority                   = var.default_nsg.priority
    direction                  = var.default_nsg.direction
    access                     = var.default_nsg.access
    protocol                   = var.default_nsg.protocol
    source_port_range          = var.default_nsg.source_port_range
    destination_port_range     = var.default_nsg.destination_port_range
    source_address_prefix      = var.default_nsg.source_address_prefix
    destination_address_prefix = var.default_nsg.destination_address_prefix
  }
}

# Create network interface ; assigned to the subnet, with the output of Public IP
resource "azurerm_network_interface" "publicnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.prefectsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.publicnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

