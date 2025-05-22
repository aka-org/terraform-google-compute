module "service_account" {
  source         = "./modules/service_account"
  project_id     = var.project_id
  sa_id          = var.sa_id
  sa_description = var.sa_description
  sa_roles       = var.sa_roles

  count = var.sa_id != "" ? 1 : 0
}

locals {
  # Add sa email to vm_defaults
  vm_defaults = merge(
    var.vm_defaults,
    {
      sa_email = var.sa_id != "" ? module.service_account[0].sa_email : null
    }
  )
  # Merge defaults with individual vm configuration
  # overriding any of the defaults that is configured on both
  vms = [
    for vm in var.vms : merge(
      local.vm_defaults,
      {
        for k, v in vm : k => v if v != null
      }
    )
  ]
}

module "compute" {
  source     = "./modules/compute"
  project_id = var.project_id
  vms        = local.vms
  depends_on = [module.service_account]
}
