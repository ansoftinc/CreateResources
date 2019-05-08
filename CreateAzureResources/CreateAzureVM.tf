locals {
  admin_username       = "testadmin"
  admin_password       = "Password1234!"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "CICD" {
    name     = "${var.prefix}rg"
    location = "${var.location}"

    tags {
        environment = "${var.environment}"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "CICD" {
    name                = "${var.prefix}Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.CICD.name}"

    tags {
        environment = "${var.environment}"
    }
}

# Create subnet
resource "azurerm_subnet" "CICD" {
    name                 = "${var.prefix}Subnet"
    resource_group_name  = "${azurerm_resource_group.CICD.name}"
    virtual_network_name = "${azurerm_virtual_network.CICD.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "CICD" {
    name                         = "${var.prefix}PIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.CICD.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "${var.environment}"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "CICD" {
    name                = "${var.prefix}NSG"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.CICD.name}"
    
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

    security_rule {
        name                       = "Port_8080"
        priority                   = 102
        access                     = "Allow"
        protocol                   = "*"
        direction                  = "Inbound"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Docker_Port"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "2376"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    tags {
        environment = "${var.environment}"
    }
}

# Create network interface
resource "azurerm_network_interface" "CICD" {
    name                      = "${var.prefix}NIC"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.CICD.name}"
    network_security_group_id = "${azurerm_network_security_group.CICD.id}"

    ip_configuration {
        name                          = "${var.prefix}NicConfig"
        subnet_id                     = "${azurerm_subnet.CICD.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.CICD.id}"
    }

    tags {
        environment = "${var.environment}"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.CICD.name}"
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "CICD" {
    name                        = "${var.prefix}${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.CICD.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "${var.environment}"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "CICD" {
    name                  = "${var.prefix}mastervm"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.CICD.name}"
    network_interface_ids = ["${azurerm_network_interface.CICD.id}"]
    vm_size               = "Standard_DS1_v2"
    delete_os_disk_on_termination = "true"

    storage_os_disk {
        name              = "${var.prefix}OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.prefix}vm"
        admin_username = "${local.admin_username}"
        //admin_password = "${local.admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${local.admin_username}/.ssh/authorized_keys"
            key_data = "${var.ssh_keys}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.CICD.primary_blob_endpoint}"
    }

    tags {
        environment = "${var.environment}"
    }

    connection{
        type="ssh"
        user="${local.admin_username}"
        private_key = "${file ("../.ssh/id_rsa")}"
    }
    provisioner "file"{
        source="Docker"
        destination="/tmp"
    }

    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/Docker/DockerInstall.sh",
      "sudo sh /tmp/Docker/DockerInstall.sh ${local.admin_username}",
    ]
  }
}

/* provider "docker" {
    host = "unix://localhost/var/run/docker.sock"
    //host="tcp://localhost:2376"
    //host="tcp://${azurerm_virtual_machine.CICD.ip_address}:2376"
}

resource "docker_container" "container" {
  name  = "jenkins_image"
  image = "${docker_image.jenkins.lts}"
  depends_on = ["azurerm_virtual_machine.CICD"]
  ports {
      internal = 80
      external = 80
  }
}

# Find the latest Jenkins precise image.
resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:lts"
}
*/