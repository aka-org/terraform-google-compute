resource "google_compute_instance" "vms" {
  for_each = { for vm in var.vms : vm.name => vm }

  project      = var.project_id
  zone         = each.value.zone
  name         = each.value.name
  machine_type = each.value.machine_type

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.disk_size
      type  = each.value.disk_type
    }
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
    subnetwork_project = var.project_id
    access_config {}
  }

  dynamic "service_account" {
    for_each = each.value.sa_email != null ? [1] : []
    content {
      email  = each.value.sa_email
      scopes = ["cloud-platform"]
    }
  }

  labels = each.value.labels

  metadata = merge(
    {
      ssh-keys = join("\n", each.value.admin_ssh_keys)
    },
    each.value.cloud_init != "" ? {
      "user-data" = templatefile(
        each.value.cloud_init,
        each.value.cloud_init_data
      )
    } : {}
  )

  metadata_startup_script = (
    try(each.value.startup_script, "") != ""
    ? templatefile(
      each.value.startup_script,
      each.value.startup_script_data
    ) : null
  )

  lifecycle {
    ignore_changes = [network_interface[0].alias_ip_range]
  }

  tags = each.value.tags
}
