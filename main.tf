## IAM user required for CAST.AI

locals {
  service_account_id    = "castai-gke-tf-${substr(sha1(var.gke_cluster_name), 0, 8)}"
  service_account_email = "${local.service_account_id}@${var.project_id}.iam.gserviceaccount.com"
  custom_role_id        = "castai.gkeAccess.${substr(sha1(var.gke_cluster_name), 0, 8)}.tf"
  condition_expression  = join("||", formatlist("resource.name.startsWith(\"projects/-/serviceAccounts/%s\")", var.service_accounts_unique_ids))
  default_permissions   = ["roles/iam.serviceAccountUser", "projects/${var.project_id}/roles/${local.custom_role_id}"]
  scoped_permissions    = ["projects/${var.project_id}/roles/${local.custom_role_id}"]

  compute_manager_project_ids = var.compute_manager_project_ids
}

resource "google_service_account" "castai_service_account" {
  account_id   = local.service_account_id
  display_name = "Service account to manage ${var.gke_cluster_name} cluster via CAST"
  project      = var.project_id
}

data "castai_gke_user_policies" "gke" {}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_custom_role" "castai_role" {
  role_id     = local.custom_role_id
  title       = "Role to manage GKE cluster via CAST AI"
  description = "Role to manage GKE cluster via CAST AI"
  permissions = toset(data.castai_gke_user_policies.gke.policy)
  project     = var.project_id
  stage       = "GA"
}

resource "google_project_iam_member" "project" {
  for_each = (
    length(var.service_accounts_unique_ids) == 0 ?
    { for permission in local.default_permissions : permission => permission } :
    {}
  )

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.service_account_email}"
}

resource "google_project_iam_member" "scoped_project" {
  for_each = (
    length(var.service_accounts_unique_ids) > 0 ?
    { for permission in local.scoped_permissions : permission => permission } :
    {}
  )
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.service_account_email}"
}

resource "google_project_iam_member" "scoped_service_account_user" {
  count   = length(var.service_accounts_unique_ids) > 0 ? 1 : 0
  project = var.project_id

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${local.service_account_email}"

  condition {
    title       = "iam_condition"
    description = "IAM condition with limited scope"
    expression  = local.condition_expression
  }
}

resource "google_project_iam_custom_role" "compute_manager_role" {
  for_each = toset(local.compute_manager_project_ids)

  project = each.key

  role_id     = "castai.gkeAccess.${substr(sha1(each.key), 0, 8)}.tf"
  title       = "Role to manage GKE compute resources via CAST AI"
  description = "Role to manage GKE compute resources via CAST AI"
  permissions = toset(data.castai_gke_user_policies.gke.policy)
  stage       = "GA"
}

resource "google_project_iam_binding" "compute_manager_binding" {
  for_each = toset(local.compute_manager_project_ids)

  project = each.key
  role    = "projects/${each.key}/roles/castai.gkeAccess.${substr(sha1(each.key), 0, 8)}.tf"
  members = ["serviceAccount:${local.service_account_email}"]
}

resource "google_service_account_key" "castai_key" {
  service_account_id = google_service_account.castai_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
