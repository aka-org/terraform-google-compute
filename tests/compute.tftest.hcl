# Runs the module against mocked providers: no credentials, no API calls.
# Run with `terraform test` from the repository root.
#
# The first runs apply the whole module (the mocks invent every value a
# real provider would return); the runs with a `module` block plan one
# submodule and check its resources.

mock_provider "google" {
  # The provider checks the shape of a service account's email where it
  # is used, so the mock returns a realistic one.
  mock_resource "google_service_account" {
    defaults = {
      email = "vm-1a2b3c4d@example-project.iam.gserviceaccount.com"
    }
  }
}
mock_provider "random" {}

variables {
  project_id = "example-project"
  # Set even when empty: `terraform test` refuses to apply with an
  # ephemeral variable left unset.
  secret_values = {}
  vm_defaults = {
    zone                = "europe-west1-b"
    network             = "main"
    subnetwork          = "nodes"
    image               = "debian-cloud/debian-12"
    machine_type        = "e2-small"
    disk_size           = 20
    disk_type           = "pd-balanced"
    labels              = { env = "test" }
    cloud_init          = ""
    cloud_init_data     = {}
    startup_script      = ""
    startup_script_data = {}
    admin_ssh_keys      = ["admin:ssh-ed25519 AAAA admin"]
    tags                = ["vm"]
  }
}

run "nothing_without_vms_or_a_service_account" {
  assert {
    condition     = output.sa_email == null && output.sa_id == null && output.sa_name == null
    error_message = "No service account is created unless sa_id is set."
  }
  assert {
    condition     = length(local.vms) == 0
    error_message = "No VM is created unless asked for."
  }
}

run "a_vm_takes_the_defaults_and_its_own_overrides" {
  variables {
    vms = [
      { name = "one" },
      { name = "two", machine_type = "e2-medium", tags = ["vm", "bastion"] },
    ]
  }

  assert {
    condition     = local.vms[0].machine_type == "e2-small" && local.vms[0].zone == "europe-west1-b"
    error_message = "A VM without overrides is built from vm_defaults."
  }
  assert {
    condition     = local.vms[1].machine_type == "e2-medium" && local.vms[1].tags == tolist(["vm", "bastion"])
    error_message = "A VM's own fields replace the defaults."
  }
  assert {
    condition     = local.vms[1].image == "debian-cloud/debian-12"
    error_message = "Fields a VM leaves unset still come from vm_defaults."
  }
  assert {
    condition     = local.vms[0].sa_email == null
    error_message = "Without sa_id the VMs run without a service account."
  }
}

run "service_account_is_shared_by_the_vms" {
  variables {
    sa_id    = "vm"
    sa_roles = ["roles/logging.logWriter"]
    vms      = [{ name = "one" }]
  }

  assert {
    condition     = startswith(output.sa_id, "vm-")
    error_message = "The service account's id is sa_id with a random suffix."
  }
  assert {
    condition     = local.vms[0].sa_email == output.sa_email
    error_message = "Each VM runs as the module's service account."
  }
}

run "vm_resource_from_its_settings" {
  command = plan

  module {
    source = "./modules/compute"
  }

  variables {
    vms = [{
      name                = "one"
      zone                = "europe-west1-b"
      network             = "main"
      subnetwork          = "nodes"
      image               = "debian-cloud/debian-12"
      machine_type        = "e2-small"
      disk_size           = 20
      disk_type           = "pd-balanced"
      labels              = { env = "test" }
      cloud_init          = ""
      cloud_init_data     = {}
      startup_script      = ""
      startup_script_data = {}
      admin_ssh_keys      = ["admin:ssh-ed25519 AAAA admin", "ops:ssh-ed25519 BBBB ops"]
      tags                = ["vm"]
      sa_email            = null
    }]
  }

  assert {
    condition     = google_compute_instance.vms["one"].boot_disk[0].initialize_params[0].size == 20
    error_message = "The boot disk has the size given."
  }
  assert {
    condition     = google_compute_instance.vms["one"].metadata["ssh-keys"] == "admin:ssh-ed25519 AAAA admin\nops:ssh-ed25519 BBBB ops"
    error_message = "The admin keys go into the ssh-keys metadata, one per line."
  }
  assert {
    condition     = !contains(keys(google_compute_instance.vms["one"].metadata), "user-data")
    error_message = "No user-data without a cloud-init file."
  }
  assert {
    condition     = length(google_compute_instance.vms["one"].service_account) == 0
    error_message = "No service account block without a service account."
  }
}

run "secret_without_a_version" {
  command = plan

  module {
    source = "./modules/secrets"
  }

  variables {
    secrets = [{ id = "api-key", add_version = false, value_version = 1 }]
  }

  assert {
    condition     = length(google_secret_manager_secret.secret) == 1
    error_message = "The secret entry is created."
  }
  assert {
    condition     = length(google_secret_manager_secret_version.secret_version) == 0
    error_message = "add_version = false creates the entry only; its value is added outside Terraform."
  }
}

run "secret_version_follows_value_version" {
  command = plan

  module {
    source = "./modules/secrets"
  }

  variables {
    secrets       = [{ id = "api-key", add_version = true, value_version = 3 }]
    secret_values = { "api-key" = "not-a-real-secret" }
  }

  assert {
    condition     = google_secret_manager_secret_version.secret_version["api-key"].secret_data_wo_version == 3
    error_message = "The version resource follows value_version, which is what makes Terraform write a new value."
  }
}
