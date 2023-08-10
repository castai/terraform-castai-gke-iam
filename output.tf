output "private_key" {
  value     = base64decode(google_service_account_key.castai_key.private_key)
  sensitive = true

  depends_on = [
    # Wait for binding and custom role creation
    # so Service Account will have proper permissions level
    google_project_iam_member.project,
    google_project_iam_member.scoped_project,
    google_project_iam_custom_role.castai_role
  ]
}

output "service_account_id" {
  value = google_service_account.castai_service_account.account_id
}

output "service_account_email" {
  value = google_service_account.castai_service_account.email
}
