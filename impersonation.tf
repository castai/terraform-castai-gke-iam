data "castai_impersonation_service_account" "gke" {
  count        = var.authentication_method == "impersonation" ? 1 : 0
  cluster_type = "gke"
}

resource "google_service_account_iam_member" "castai_token_creator" {
  count = var.authentication_method == "impersonation" ? 1 : 0

  service_account_id = var.create_service_account ? google_service_account.castai_service_account[0].name : "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${data.castai_impersonation_service_account.gke[0].email}"
}
