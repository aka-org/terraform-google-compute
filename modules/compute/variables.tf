variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "vms" {
  description = "List of VMs to be created with optional overrides"
  type = list(object({
    name                = string
    zone                = optional(string)
    sa_email            = optional(string)
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
}