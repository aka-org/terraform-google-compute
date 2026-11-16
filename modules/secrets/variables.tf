variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "secrets" {
  description = "List of Secret objects to be created"
  type = list(object({
    id          = string
    add_version = bool
    # Bump to store the value passed in secret_values as a new version:
    # the value itself is never kept in state, so Terraform can't see it
    # change.
    value_version = optional(number, 1)
  }))
}

variable "secret_values" {
  description = "Map of secret id to the value of its version. Ephemeral: used only to write the version, never stored in state or in a plan file"
  type        = map(string)
  sensitive   = true
  ephemeral   = true
  default     = {}
}
