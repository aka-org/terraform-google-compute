# terraform-google-compute

## Overview

This module provisions Google Compute Engine (GCE) instances and related resources, including optional service accounts. It is designed to be used after creating a GCP project and enabling required APIs/service accounts (such as with the [terraform-google-project](https://github.com/aka-org/terraform-google-project) module).

## Table of Contents
- Requirements
- Usage
- Module Variables
- Outputs
- APIs and Service Account Prerequisites
- Changelog
- License

## Requirements
- Terraform: >= 1.11.4
- Provider: hashicorp/google version 6.8.0
- Prerequisites:
  - A GCP project must already exist.
  - Required APIs must be enabled (Compute Engine API at minimum).
  - A VPC network and subnetwork(s) must already exists.
  - A service account with sufficient permissions must be available.

## Usage
```hcl
module "compute" {
  source  = "aka-org/compute/google"
  version = "0.1.0"

  project_id   = var.project_id
  sa_id        = "my-vm-sa" # optional, creates a service account if set
  sa_roles     = ["roles/compute.viewer"] # optional
  sa_description = "My VM Service Account" # optional

  vm_defaults = {
    zone                = "us-central1-a"
    network             = "default"
    subnetwork          = "default"
    image               = "debian-cloud/debian-12"
    machine_type        = "e2-micro"
    disk_size           = 10
    disk_type           = "pd-standard"
    labels              = {}
    cloud_init          = ""
    cloud_init_data     = {}
    startup_script      = ""
    startup_script_data = {}
    admin_ssh_keys      = ["user:ssh-rsa AAAA..."]
    tags                = ["ssh"]
  }

  vms = [
    {
      name = "vm-1"
      # Optionally override any vm_defaults fields here
    },
    # ... more VMs ...
  ]
}
```

## Module Variables
| Name            | Description                                      | Type     | Default   |
|-----------------|--------------------------------------------------|----------|-----------|
| project_id      | The GCP project ID.                              | string   | n/a       |
| sa_id           | The prefix of the VM service account (optional).     | string   | ""        |
| sa_description  | Description of the VM service account.           | string   | ""        |
| sa_roles        | List of roles to assign to the service account.  | list     | []        |
| vm_defaults     | Default config for VMs.                          | object   | n/a       |
| vms             | List of VMs to create (with optional overrides). | list     | []        |

## Outputs
- `sa_email`: VM service account email (if created)
- `sa_id`: VM service account id (if created)
- `sa_name`: VM service account fully-qualified name (if created)

## APIs and Service Account Prerequisites
To apply this module, the following are required:

### APIs
- Compute Engine API (`compute.googleapis.com`)

### Service Account Roles
The service account running Terraform must have at least:
- `roles/compute.instanceAdmin.v1`
- `roles/iam.serviceAccountUser` (if creating service accounts)
- `roles/compute.viewer`

## Changelog
See [CHANGELOG.md](./CHANGELOG.md) for release history.

## License
Apache 2.0 - See [LICENSE](./LICENSE)
