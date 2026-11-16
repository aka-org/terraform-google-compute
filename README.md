# terraform-google-compute

## Overview

This module provisions Google Compute Engine (GCE) instances and related resources, including optional service accounts and secrets. It is designed to be used after creating a GCP project and enabling required APIs/service accounts (such as with the [terraform-google-project](https://github.com/aka-org/terraform-google-project) module).

## Table of Contents
- Requirements
- Usage
- Module Variables
- Outputs
- Secrets
- APIs and Service Account Prerequisites
- Development
- Changelog
- License

## Requirements
- Terraform: >= 1.11.4
- Provider: hashicorp/google >= 6.23, < 8 (checked on 6.23.0 and the latest 7.x; 6.23.0 is the first release with write-only secret values)
- Prerequisites:
  - A GCP project must already exist.
  - Required APIs must be enabled (Compute Engine API at minimum).
  - A VPC network and subnetwork(s) must already exists.
  - A service account with sufficient permissions must be available.

## Usage
```hcl
module "compute" {
  source  = "aka-org/compute/google"
  version = "0.5.0"

  project_id   = var.project_id
  sa_id        = "my-vm-sa" # optional, creates a service account if set
  sa_roles     = ["roles/compute.viewer"] # optional
  sa_description = "My VM Service Account" # optional
  secrets        = [{ id = "my-secret", add_version = true }] # optional, creates a secret object for each list item
  secret_values  = var.secret_values # optional, an ephemeral map of secret id to value (see Secrets)

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
| secrets         | List of secret objects to be created (optional): `id`, `add_version`, `value_version` (default 1). | list(object) | [] |
| secret_values   | Map of secret id to value, ephemeral (optional; see Secrets). | map(string) | {} |
| sa_id           | The prefix of the VM service account (optional). | string   | ""        |
| sa_description  | Description of the VM service account.           | string   | ""        |
| sa_roles        | List of roles to assign to the service account.  | list     | []        |
| vm_defaults     | Default config for VMs.                          | object   | n/a       |
| vms             | List of VMs to create (with optional overrides). | list     | []        |

## Outputs
- `sa_email`: VM service account email (if created)
- `sa_id`: VM service account id (if created)
- `sa_name`: VM service account fully-qualified name (if created)

## Secrets
Each entry of `secrets` creates a Secret Manager secret. With `add_version = false` the secret is created empty, for a value added outside Terraform (`gcloud secrets versions add`). With `add_version = true` the module writes the value found under the secret's id in `secret_values` as a version.

Secret values never reach Terraform's state or a saved plan: `secret_values` is an ephemeral variable and the version is written through the provider's write-only argument (`secret_data_wo`). What follows from that:

- Pass the values from an ephemeral variable of your own, set through the environment, at plan and again at apply (a saved plan doesn't hold them):
  ```hcl
  variable "secret_values" {
    type      = map(string)
    sensitive = true
    ephemeral = true
  }
  ```
  ```sh
  export TF_VAR_secret_values='{"my-secret":"..."}'
  ```
- Terraform can't see a value change. To store a new value, raise the secret's `value_version` (`{ id = "my-secret", add_version = true, value_version = 2 }`).
- Don't read the value back with the `google_secret_manager_secret_version` data source: that puts it in state. Workloads read it from Secret Manager at run time.

**Upgrading from 0.4.0 or earlier.** Those releases wrote values with `secret_data`, which stores them in state. On upgrade Terraform replaces each such version (a new version with the same value, the old one destroyed). The values remain in every state file written before the upgrade, including the state bucket's older object versions: rotate the secrets, or remove those state versions.

## Development

What a machine needs to work on this module:

| Tool | Version | Used for |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.11.4 | `fmt`, `validate` |
| [TFLint](https://github.com/terraform-linters/tflint) | >= 0.50 | lint (`.tflint.hcl`) |
| git | any | |

Nothing here needs Google Cloud credentials: `validate` and `tflint` read only the configuration.

The checks CI runs (`.github/workflows/ci.yml`), from the repository root:

```sh
terraform fmt -check -recursive -diff
terraform init -backend=false && terraform validate
tflint --init && tflint --recursive
```

CI validates twice: on the lowest supported Google provider (6.23.0) and on the newest release the constraint allows. To validate on the lowest locally, change the `google` constraint in every `versions.tf` to `6.23.0`, run `terraform init -backend=false -upgrade && terraform validate`, and revert.

An untracked `testing/` directory is ignored by git, for a caller configuration and its `terraform.tfvars` when trying the module against a real project. `terraform fmt -recursive` and `tflint --recursive` walk into it.

Releasing: add the version's section to `CHANGELOG.md`, merge, tag `vX.Y.Z` on `main`. The Terraform Registry publishes the tag.

## APIs and Service Account Prerequisites
To apply this module, the following are required:

### APIs
- Compute Engine API (`compute.googleapis.com`)
- Secret manager API (`secretmanager.googleapis.com`) # optional, if creating secrets
- IAM API (`iam.googleapis.com`) # optional, if creating a service account

### Service Account Roles
The service account running Terraform must have at least:
- `roles/compute.instanceAdmin.v1`
- `roles/iam.serviceAccountUser` (if creating service accounts)
- `roles/secretmanager.admin` (if creating secrets)
- `roles/compute.viewer`

## Changelog
See [CHANGELOG.md](./CHANGELOG.md) for release history.

## License
Apache 2.0 - See [LICENSE](./LICENSE)
