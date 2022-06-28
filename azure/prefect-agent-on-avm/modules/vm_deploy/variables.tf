variable "rg" {
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "publicnic" {
  description = "Public Interface to be assigned to the VM Module"
}

variable "prefect_url" {
}

variable "api_key" {
}

variable "source_image" {
  description = "Standard configuration Azure VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

variable "admin_user" {
  type        = string
  default     = "azureuser"
  description = "The default user for the configured azure vm"
}

variable "default_queue" {
  type        = string
  default     = "default"
  description = "The default work queue used to start and configure the prefect agent"
}