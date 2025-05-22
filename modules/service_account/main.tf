resource "google_service_account" "vm_sa" {

  project      = var.project_id
  account_id   = var.sa_id
  display_name = var.sa_description
}

resource "google_project_iam_member" "vm_sa_roles" {
  for_each = toset(var.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}