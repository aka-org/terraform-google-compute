locals {
  secrets = {
    for secret in var.secrets : secret.id => secret
  }
  versioned_secrets = {
    for secret in var.secrets : secret.id => secret if secret.add_version
  }
}

resource "google_secret_manager_secret" "secret" {
  for_each = local.secrets

  project   = var.project_id
  secret_id = each.value.id
  replication {
    auto {}
  }
}

# The value goes through the write-only argument: Terraform sends it to
# Secret Manager and keeps nothing of it in state. A new value is stored
# only when the secret's value_version changes.
resource "google_secret_manager_secret_version" "secret_version" {
  for_each = local.versioned_secrets

  secret                 = google_secret_manager_secret.secret[each.value.id].id
  secret_data_wo         = var.secret_values[each.value.id]
  secret_data_wo_version = each.value.value_version
}
