variable "project_id" {
  description = "The id of the host project"
  type        = string
}

variable "sa_id" {
  description = "The id of the VM service account"
  type        = string
  default     = ""
}

variable "sa_description" {
  description = "Description of the VM service account"
  type        = string
  default     = ""
}

variable "sa_roles" {
  description = "List of roles to be assigned to the VM service account"
  type        = list(string)
  default     = []
}

variable "vm_defaults" {
  description = "DRY config of VMs"
  type = object({
    zone                = string
    network             = string
    subnetwork          = string
    image               = string
    machine_type        = string
    disk_size           = number
    disk_type           = string
    labels              = map(string)
    cloud_init          = string
    cloud_init_data     = map(string)
    startup_script      = string
    startup_script_data = map(string)
    admin_ssh_keys      = list(string)
    tags                = list(string)
  })
}

variable "vms" {
  description = "List of VMs to be created with optional overrides"
  type = list(object({
    name                = string
    zone                = optional(string)
    network             = optional(string)
    subnetwork          = optional(string)
    image               = optional(string)
    machine_type        = optional(string)
    disk_size           = optional(number)
    disk_type           = optional(string)
    labels              = optional(map(string))
    cloud_init          = optional(string)
    cloud_init_data     = optional(map(string))
    startup_script      = optional(string)
    startup_script_data = optional(map(string))
    tags                = optional(list(string))
    admin_ssh_keys      = optional(list(string))
  }))
  default = []
}