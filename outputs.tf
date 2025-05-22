output "sa_email" {
  description = "VM service account email"
  value       = var.sa_id != "" ? module.service_account[0].sa_email : null
}

output "sa_id" {
  description = "VM service account id"
  value       = var.sa_id != "" ? module.service_account[0].sa_id : null
}

output "sa_name" {
  description = "VM service account fully-qualified name"
  value       = var.sa_id != "" ? module.service_account[0].sa_name : null
}