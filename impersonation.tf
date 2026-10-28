locals {
  create_impersonation_resources = var.authentication_method == "impersonation" || var.authentication_method_migration == "prepare"
}

data "castai_impersonation_service_account" "gke" {
  count         = local.create_impersonation_resources ? 1 : 0
  provider_type = "gke"
}

resource "google_service_account_iam_member" "castai_token_creator" {
  count = local.create_impersonation_resources ? 1 : 0

  service_account_id = var.create_service_account ? google_service_account.castai_service_account[0].name : "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${data.castai_impersonation_service_account.gke[0].email}"
}
