## IAM user required for CAST.AI

locals {
  custom_role_id        = "castai.gkeAccess.${substr(sha1(var.gke_cluster_name), 0, 8)}.tf"
  condition_expression  = join("||", formatlist("resource.name.startsWith(\"projects/-/serviceAccounts/%s\")", var.service_accounts_unique_ids))
  default_permissions   = ["roles/iam.serviceAccountUser", "projects/${var.project_id}/roles/${local.custom_role_id}"]
  scoped_permissions    = ["projects/${var.project_id}/roles/${local.custom_role_id}"]

  compute_manager_project_ids = var.compute_manager_project_ids
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
  members = compact(["serviceAccount:${local.service_account_email}", var.setup_cloud_proxy_workload_identity ? local.workload_identity_sa : null])
}

