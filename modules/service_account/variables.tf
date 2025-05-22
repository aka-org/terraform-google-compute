variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
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