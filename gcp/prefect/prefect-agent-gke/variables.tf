# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
}

variable "service_account_name" {
  description = "The name of the custom service account. This parameter is limited to a maximum of 28 characters."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "The description of the custom service account."
  type        = string
  default     = ""
}

variable "service_account_roles" {
  description = "Additional roles to be added to the service account."
  type        = list(string)
  default     = []
}

variable "min_master_version" {
  default = "1.21.5-gke.1302"

}
variable "cluster_cidr" {
  description = "CIDR Block for cluster resources"
  default     = "10.10.2.0/28"
  type        = string
}
variable "enable_private_endpoint" {
  default     = false
  type        = bool
  description = "Boolean to set private vs public cluster endpoint"
}