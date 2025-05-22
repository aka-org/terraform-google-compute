output "sa_email" {
  description = "VM service account email"
  value       = google_service_account.vm_sa.email
}

output "sa_id" {
  description = "VM service account id"
  value       = google_service_account.vm_sa.account_id
}

output "sa_name" {
  description = "VM service account fully-qualified name"
  value       = google_service_account.vm_sa.name
}