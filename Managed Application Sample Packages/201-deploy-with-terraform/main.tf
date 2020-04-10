# Configure the Microsoft Azure Provider
provider "azurerm" {
    version         = "=2.0.0"
    subscription_id = var.azure_subscription_id
    #client_id       = var.service_principal_id
    #client_secret   = var.service_principal_secret
    #tenant_id       = var.azure_ad_tenant_id 
    skip_provider_registration = true
    features{}
}

# Create virtual network
resource "azurerm_virtual_network" "network" {
    name                = "${var.base_name}Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name

    tags = {
        environment = "${var.base_name} Managed App"
    }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "${var.base_name}Subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.network.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
    name                         = "${var.base_name}IP"
    location                     = var.location
    resource_group_name          = var.resource_group_name
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.base_name} Managed App"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
    name                = "${var.base_name}Nsg"
    location            = var.location
    resource_group_name = var.resource_group_name
    
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

    tags = {
        environment = "${var.base_name} Managed App"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    name                      = "${var.base_name}Nic"
    location                  = var.location
    resource_group_name       = var.resource_group_name
    #network_security_group_id = azurerm_network_security_group.nsg.id

    ip_configuration {
        name                          = "${var.base_name}NicConfiguration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip.id
    }

    tags = {
        environment = "${var.base_name} Managed App"
    }
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diag" {
    name                        = var.stg_account_name
    resource_group_name         = var.resource_group_name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    account_kind                = "BlobStorage"

    tags = {
        environment = "${var.base_name} Managed App"
    }
}

