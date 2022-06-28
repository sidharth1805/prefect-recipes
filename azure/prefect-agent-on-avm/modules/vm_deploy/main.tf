
# Generate random text for a unique storage account name (optional)
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics (optional)
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = var.rg.location
  resource_group_name      = var.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the private .pem key locally
resource "local_file" "ssh_key" {
  filename = "${azurerm_linux_virtual_machine.prefectagentvm.name}.pem"
  content  = tls_private_key.example_ssh.private_key_pem
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "prefectagentvm" {
  name                  = "prefectAgentVM"
  location              = var.rg.location
  resource_group_name   = var.rg.name
  network_interface_ids = [var.publicnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  computer_name                   = "prefect-agentVM"
  admin_username                  = var.admin_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = "${azurerm_linux_virtual_machine.prefectagentvm.computer_name}-vmext"
  virtual_machine_id   = azurerm_linux_virtual_machine.prefectagentvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("vm_extension.sh.tpl", {
adminuser = var.admin_user, defaultqueue = var.default_queue, api_key = var.api_key, prefect_url = var.prefect_url }))}"
    }
  SETTINGS

}
