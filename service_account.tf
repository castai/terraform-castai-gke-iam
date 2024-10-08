locals {
  service_account_id    = "castai-gke-tf-${substr(sha1(var.gke_cluster_name), 0, 8)}"
  service_account_email = "${local.service_account_id}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_service_account" "castai_service_account" {
  count        = var.create_service_account ? 1 : 0
  account_id   = local.service_account_id
  display_name = "Service account to manage ${var.gke_cluster_name} cluster via CAST"
  project      = var.project_id
}

resource "google_service_account_key" "castai_key" {
  count              = var.create_service_account ? 1 : 0
  service_account_id = google_service_account.castai_service_account[0].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "project" {
  for_each = (
    var.create_service_account && length(var.service_accounts_unique_ids) == 0 ?
    { for permission in local.default_permissions : permission => permission } :
    {}
  )

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.service_account_email}"
}

resource "google_project_iam_member" "scoped_project" {
  for_each = (
    var.create_service_account && length(var.service_accounts_unique_ids) > 0 ?
    { for permission in local.scoped_permissions : permission => permission } :
    {}
  )
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.service_account_email}"
}

resource "google_project_iam_member" "scoped_service_account_user" {
  count   = var.create_service_account && length(var.service_accounts_unique_ids) > 0 ? 1 : 0
  project = var.project_id

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${local.service_account_email}"

  condition {
    title       = "iam_condition"
    description = "IAM condition with limited scope"
    expression  = local.condition_expression
  }
}
